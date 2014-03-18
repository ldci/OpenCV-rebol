#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Find Faces"
	Author:		"Francois Jouen"
	Rights:		"Copyright (c) 2012-2014 Francois Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;some improvements by Walid Yahia 2014 

do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

isImage: false
classifier: to-string to-local-file join appDir "cascades/haarcascades/haarcascade_frontalface_alt_tree.xml"
cascade: make struct! CvHaarClassifierCascade! none
&cascade: struct-address? cascade
clname: "haarcascade_frontalface_alt_tree.xml"


; load cascade of Haar classifiers to find face
loadObjectDetector: func [cascade_path [string!] memo ][
	;cascade: cvLoad cascade_path none none none ; this is not running????
	cvLoadHaarClassifierCascade cascade_path 20 20
]
cascade: loadObjectDetector classifier 0 
&cascade: struct-address? cascade

scale: 2
lineType: CV_AA;
thickness: 2

scaleFactor: 1.1
minNeighbors: 3
wsize: 0

flags: CV_HAAR_DO_CANNY_PRUNING; CV_HAAR_FIND_BIGGEST_OBJECT ; CV_HAAR_DO_ROUGH_SEARCH; CV_HAAR_SCALE_IMAGE

findFaces: does [
	; looks for n faces in image  use the fastest variant
	if isImage [
		;cvZero isource 
		isource: cvLoadImage file CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_UNCHANGED  
		&isource: as-pointer! isource
		cvShowImage "Input" &isource 
		;Walid Probleme cvHaarDetectObjects : 
		;Erreur de parametrage dans minNeighbors (par défaut = 3)
		faces: cvHaarDetectObjects &babyface cascade storage scaleFactor minNeighbors flags wsize wsize
		for i 1 faces/total 1
		[
			faceRect: cvGetSeqElem faces i 0 ; we get a pointer to 4 integers
	    	x: to-integer reverse get-memory faceRect + 0 4 
			y: to-integer reverse get-memory faceRect + 4 4
			wd: to-integer reverse get-memory faceRect + 8 4
	    	hg: to-integer reverse get-memory faceRect + 12 4	
	    	roi: cvRect (x * scale) (y * scale) ((x + wd) * scale) ((y + hg) * scale)
	    	cvRectangle &isource roi/x roi/y roi/width roi/height  0 255 0 0 thickness lineType 0
		]
		cvShowImage "Input" &isource	
	]
]



selectClassifier: does [
	temp: request-file 
	if not none? temp [
		clname: second split-path to-file temp
		classifier: to-string to-local-file to-string temp
		cascade: loadObjectDetector classifier 0
		set-text info1 clname
	]
]


showImage: does [
	cvNamedWindow "Input" CV_WINDOW_AUTOSIZE
    cvMoveWindow "Input" 100 200
    cvSmooth &isource &isource CV_GAUSSIAN 3 3 0.0 0.0  ;gaussian smoothing
    cvPyrDown &isource &babyface CV_GAUSSIAN_5x5 		  ;reduce original size to improve speed 
    cvShowImage "Input" &isource	
    {cvNamedWindow "Face" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Face" 900 300
	cvShowImage "Face" babyface}
]
    
   
loadImage: does [
	temp: request-file 
	if not none? temp [
	    file: to-string to-local-file to-string temp
		isource: cvLoadImage file CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_UNCHANGED CV_LOAD_IMAGE_GRAYSCALE; 
		&isource: as-pointer! isource
		&babyface: as-pointer! cvCreateImage isource/width / 2  isource/height / 2 IPL_DEPTH_8U 3
		storage: cvCreateMemStorage 0
	    &storage: struct-address? storage
	    faces: make struct! cvSeq! none
	    showImage
	    isImage: true
	]
]
	
mainWin: [
	at 1x1 
	button 25 "Load Image" [loadImage]
	info1: field options [info]  66 clname
	button 20 "Classifier" [selectClassifier]
	field 10 options [info] "Flags" 
	flag: drop-list 65 "CV_HAAR_DO_CANNY_PRUNING" 
	      data [CV_HAAR_DO_CANNY_PRUNING CV_HAAR_FIND_BIGGEST_OBJECT CV_HAAR_DO_ROUGH_SEARCH CV_HAAR_SCALE_IMAGE] 
	      [flags: get to word! face/text findFaces]
	
	at 1x7 field 25 "Scale Increase" options [info] sl1: slider 28x5 options [arrows] [set-text tscale to-string round/to 0.1 + sl1/data 0.01 scaleFactor: 1.1 + round/to sl1/data 0.01 ]
	tscale: field 10 "0.1" options [info] font [align: 'center]
	field 25 "Min nb of rect" options [info] 
	field 10 "0" [minNeighbors: to-integer face/text] 
	field 25 "Min Win Size" field 10 "0" [wsize: to-integer face/text ]
	button 25 "Find Faces"  [findFaces] 
	button 20 "Quit" [ if isImage [
					cvReleaseImage isource
					cvReleaseImage &babyface
					free-mem storage
					free-mem cascade
					free-mem faces]
					quit
					]	
]

display/position "Find Faces in Image" mainWin 100x100
do-events 
