#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Eye Tracking for Kids"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2014 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]


do %../opencv.r
set 'appDir what-dir 
guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"


w: 640
h: 480
x: y: wd: hg: 10
faceWidth: faceHeight: 0
eyesWidth: eyesHeight: 0

; for drawing rectangles
lineType: CV_AA;
thickness: 2
scale: 2

isActive: false
isFace: false
isGlasses: false

flags: CV_HAAR_FIND_BIGGEST_OBJECT
minNeighbors: 1
capture: make struct! CvCapture! none

; default faceClassifier

faceClassifier: to-local-file join appDir "cascades/haarcascades/haarcascade_frontalface_alt_tree.xml"

faceCascade: make struct! CvHaarClassifierCascade! none
&faceCascade: struct-address? faceCascade
&&faceCascade: make struct! int-ptr! reduce [struct-address? faceCascade]
clname: "haarcascade_frontalface_alt_tree.xml"

; for the eyes
;cascades/haarcascades/haarcascade_eye_tree_eyeglasses.xml or cascades/haarcascades/haarcascade_mcs_eyepair_big.xml
eyesClassifier: to-local-file join appDir "cascades/haarcascades/haarcascade_mcs_eyepair_big.xml"
eyesCascade: make struct! CvHaarClassifierCascade! none
&eyesCascade: struct-address? eyesCascade
&&eyesCascade: make struct! int-ptr! reduce [struct-address? eyesCascade]

; load cascade of Haar classifiers to find Reduced
loadObjectDetector: func [cascade_path [string!] memo ][
	;cvLoad cascade_path memo none none ; this is not running????
	cvLoadHaarClassifierCascade cascade_path 20 20
]


faceCascade: loadObjectDetector faceClassifier none 
eyesCascade: loadObjectDetector eyesClassifier none 

selectClassifier: does [
	temp: request-file 
	if not none? temp [
		clname: second split-path to-file temp
		faceClassifier: to-string to-local-file to-string temp
		faceCascade: loadObjectDetector faceClassifier 0
		set-text info1 clname
	]
]


activate: does [
	;activate cam
	&capture: as-pointer! cvCreateCameraCapture CV_CAP_ANY 
    ;get first cam image
	cvGrabFrame &capture
	isource: cvRetrieveFrame &capture
	&isource: as-pointer! isource
	; calculate size for face window
    faceWidth: isource/width * .35
    faceHeight: isource/height * .30
    ; we need some limitation in order to avoid cvCopy pbs
	leftLimit: faceWidth / 2
	rightLimit: isource/width - faceWidth
	upLimit: 0 
	downLimit:  isource/height - faceHeight
	
	
	
	; make a reduce view to improve face detection
	&reducedInput: as-pointer! cvCreateImage isource/width / 2  isource/height / 2 IPL_DEPTH_8U 3
	
	&iface: as-pointer! cvCreateImage faceWidth  faceHeight IPL_DEPTH_8U 3
	
	;for eyes
	eyesWidth: isource/width * .20 ; 128 pixels for 640 width pixels image
	eyesHeight: isource/height * .05 ; 24 pixels for 480 height pixels image
	
	&leftEye: as-pointer! cvCreateImage  eyesWidth / 2  eyesHeight IPL_DEPTH_8U 3
	
	&rightEye: as-pointer! cvCreateImage eyesWidth / 2  eyesHeight IPL_DEPTH_8U 3
	
	cvNamedWindow "Input" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Input" 5 170
	cvZero &isource
	cvShowImage "Input" &isource
	
	;we don't need to show reduced view of input
	; reducde view is used to improve face detection 
	;cvNamedWindow "Reduced" CV_WINDOW_AUTOSIZE
	;cvMoveWindow "Reduced" w + 10 150
	;cvZero &reducedInput
	;cvShowImage "Reduced" &reducedInput
	
	;
	cvNamedWindow "Face" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Face" w + 10 170
	cvZero &iface
	cvShowImage "Face" &iface
	
	cvNamedWindow "Left Eye" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Left Eye" w + 10 455
	cvZero &leftEye
	cvShowImage "Left Eye" &leftEye
	
	cvNamedWindow "Right Eye" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Right Eye" w + (w / 4) + 15 455
	cvZero &rightEye
	cvShowImage "Right Eye" &rightEye

	cvResizeWindow "Input" w h 
	;cvResizeWindow "Reduced" w / 2 h / 2
	cvResizeWindow "Face" faceWidth  faceHeight
	cvResizeWindow "Right Eye" eyesWidth   eyesHeight * 2
	cvResizeWindow "Left Eye" eyesWidth   eyesHeight * 2 
	
	; dynamical structures we need for faces and eyes 
	faceStorage: cvCreateMemStorage 0
	&&faceStorage: make struct! int-ptr! reduce [struct-address? faceStorage]
	
	eyesStorage: cvCreateMemStorage 0
	&&eyesStorage: make struct! int-ptr! reduce [struct-address? eyesStorage]
	
	faces: make struct! cvSeq! none
	eyes:  make struct! cvSeq! none
	isActive: true
]

release: does [
	if isActive [
		cvReleaseImage isource
		cvReleaseImage &reducedInput
		cvReleaseImage &iface
		cvReleaseImage &leftEye
		cvReleaseImage &rightEye
		; tbc
		;cvReleaseHaarClassifierCascade &&faceCascade
		;cvReleaseHaarClassifierCascade &&eyesClassifier
		cvReleaseMemStorage &&faceStorage
		cvReleaseMemStorage &&eyesStorage
		free-mem clone
		free-mem eyesClone
	]
]

start: does [
isActive: true
	cam/data: true  
	cam/rate: 24 
	show cam
]

stop: does [
	cam/data: false
	cam/rate: none 
	show cam
	cvZero &isource
	cvShowImage "Input" &isource
	cvZero &reducedInput
	;cvShowImage "Reduced" &reducedInput
	cvZero &iface
	cvShowImage "Face" &iface
	cvZero &leftEye
	cvShowImage "Left Eye" &leftEye
	cvZero &rightEye
	cvShowImage "Right Eye" &rightEye
]


findFaces: does [
	; looks for n faces in image  use the fastest variant
	faces: cvHaarDetectObjects &reducedInput faceCascade faceStorage 1.1 minNeighbors flags 20 20
	set-text total faces/total
	; on traque 1 seul visage  sinon for i 1 faces/total 1
	; when using CV_HAAR_FIND_BIGGEST_OBJECT flag cvHaarDetectObjects returns 0 or 1 object 
	if faces/total > 0 [ 
		for i 1 faces/total 1 [
			faceRect: cvGetSeqElem faces i 0 ; we get a pointer to rect coordinates and size
	    	x: (to-integer reverse get-memory faceRect + 0 4) * scale
			y: (to-integer reverse get-memory faceRect + 4 4) * scale
			wd: (to-integer reverse get-memory faceRect + 8 4) * scale
	    	hg: (to-integer reverse get-memory faceRect + 12 4) * scale	
	    	roi: cvRect x y x + wd y + hg
			cvRectangle &isource roi/x roi/y roi/width roi/height 0 255 0 0 thickness lineType 0   ;
			cvSetImageROI &clone roi/x roi/y faceWidth faceHeight ;roi/width roi/height
			; head can move inside these limits
			if (y > upLimit) and (y < downLimit) and (x > leftLimit) and (x < rightLimit) 
				[cvCopy &clone &iface none  &eyesClone: as-pointer! cvCloneImage &iface findEyes]
		]
	]
]

findEyes: does [
	either isGlasses 
	       [eyesClassifier: to-local-file join appDir "cascades/haarcascades/haarcascade_eye_tree_eyeglasses.xml"] 
	       [eyesClassifier: to-local-file join appDir "cascades/haarcascades/haarcascade_mcs_eyepair_big.xml"]
	
	eyes: cvHaarDetectObjects &iface eyesCascade eyesStorage 1.2 2 CV_HAAR_DO_CANNY_PRUNING 20 20
	
	if eyes/total > 0 [
		eyesRect: cvGetSeqElem eyes 1 0 ; we get a pointer 
		x: to-integer reverse get-memory eyesRect + 0 4 
		y: to-integer reverse get-memory eyesRect + 4 4
		wd: to-integer reverse get-memory eyesRect + 8 4
	    hg: to-integer reverse get-memory eyesRect + 12 4	
	    roi: cvRect x y (x + wd) (y + hg)
		cvRectangle &iface roi/x roi/y roi/width roi/height  0 0 255 0 thickness lineType 0
		cvSetImageROI &eyesClone roi/x roi/y eyesWidth / 2 eyesHeight
		cvCopy &eyesClone &leftEye none 
		cvSetImageROI &eyesClone roi/x + eyesWidth / 2 roi/y eyesWidth / 2 eyesHeight
		cvCopy &eyesClone &rightEye none
	]
]


showCamera: does [
    isource: cvRetrieveFrame &capture ;  get current image
    &isource: as-pointer! isource
    &clone: as-pointer! cvCloneImage &isource ; really necessary 
	cvSmooth &isource &isource CV_GAUSSIAN 3 3 0.0 0.0 
	;Downsamples the input image by 2 to get a performance boost w/o loosing quality
	cvPyrDown &isource &reducedInput CV_GAUSSIAN_5x5 
	if isFace [findFaces]
	cvShowImage "Input" &isource
	; cvShowImage "Reduced" &reducedInput
	cvShowImage "Face" &iface
	cvShowImage "Left Eye" &leftEye
	cvShowImage "Right Eye" &rightEye
	cvGrabFrame &capture	 ; new image
	set-text mem stats
]



activate

mainWin: [
	at 9x1 
	  button 20 "faceClassifier" [selectClassifier]
	  info1: field options [info]  60 clname
	  field 10 options [info] "Flags" 
	  flag: drop-list 60 "CV_HAAR_FIND_BIGGEST_OBJECT" 
	        data [CV_HAAR_FIND_BIGGEST_OBJECT CV_HAAR_DO_CANNY_PRUNING CV_HAAR_DO_ROUGH_SEARCH CV_HAAR_SCALE_IMAGE] 
	  	    [flags: get to word! face/text]
	  field 25 "Min nb of rect" options [info] 
	  mn: field 10 "0" [minNeighbors: to-integer face/text] 		    
	  	    
	  button 20 "Quit" [release quit]
	  at 1x10
	  cam: led
	  feel [engage: make function! [Reduced action event] [switch action [time [showCamera]]]]
	  button 20 "Start Camera" [start]
	  button 20 "Stop Camera" [stop]
	  button 20 "Find Object" [either isFace [isface: false] [isface: true] cb1/data: isface show cb1]
	  cb1: check "" data false
	  cb2: check "Glasses" data false [either isGlasses [isGlasses: false] [isGlasses: true] cb2/data: isGlasses show cb2] 
	  
	  mem: field options [info]
	  total: field 10 options [info]
	  do [cb1/data: false set-text mn minNeighbors]
	
]


display/position  "OpenCV: Eye Tracking for Kids" mainWin 5x50
do-events