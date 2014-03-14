#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Patch Matching"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

; inspired by  Amine M. Azzaoui's sample (http://opencvblogger.wordpress.com/)

do %../opencv.r
set 'appDir what-dir 
guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

isFile: false 
seuil: 0.0
lineType: CV_AA;
thickness: 2
istemplate: ismatch: false

max_val: 0.0
&min_val: float-ptr! none
&max_val: float-ptr! none

&min_loc: make struct! cvPoint! [0 0]
&max_loc: make struct! cvPoint! [0 0]

coeff: [CV_TM_CCOEFF_NORMED CV_TM_CCORR_NORMED CV_TM_SQDIFF_NORMED CV_TM_CCOEFF CV_TM_CCORR CV_TM_SQDIFF] 

method: CV_TM_CCOEFF_NORMED

activate: does [
	;activate cam
	capture: cvCreateCameraCapture CV_CAP_ANY 
	cvGrabFrame capture
	;show cam image
	isource: cvRetrieveFrame capture
	
	
	w: isource/width / 4  ; 640 /4
	h: isource/height / 2 ; 480 / 4
	
	template: cvCreateImage  w  h 8 3
	
	;imaxmin size
	iwidth: isource/width - template/width + 1
	iheight: isource/height - template/height + 1
	imaxmin: cvCreateImage iwidth iheight IPL_DEPTH_32F 1
	
	; for rectangle istemplate
	cadre_pt1: make struct! CvPoint! reduce [((isource/width - template/width) / 2)  ((isource/height - template/height) / 2)]
	cadre_pt2: make struct! CvPoint! reduce [(cadre_pt1/x + template/width)  (cadre_pt1/y + template/height)]
	; for test
	
	cvNamedWindow "Camera" CV_WINDOW_AUTOSIZE
	cvResizeWindow "Camera" 640 480
	cvMoveWindow "Camera" 5 200
	cvNamedWindow "Template" 0; CV_WINDOW_AUTOSIZE
	cvMoveWindow "Template" 650 200
	cvNamedWindow "Max Min" CV_WINDOW_AUTOSIZE
	cvMoveWindow "Max Min" 650 450
        
]

start: does [
isFile: true
	cam/data: true  
	cam/rate: 24 
	show cam
]

stop: does [
	cam/data: false
	cam/rate: none 
	show cam

]

release: does [
	if isFile [
		cvReleaseImage isource
		cvReleaseImage template
		cvReleaseImage imaxmin
	]
	
]

updateMethod: does [
	switch mType/text [
	 "CV_TM_CCOEFF_NORMED" [method: CV_TM_CCOEFF_NORMED]
	 "CV_TM_CCORR_NORMED" [method: CV_TM_CCORR_NORMED]
	 "CV_TM_SQDIFF_NORMED" [method: CV_TM_SQDIFF_NORMED]
	 "CV_TM_CCOEFF" [method: CV_TM_CCOEFF]
	 "CV_TM_CCORR" [method: CV_TM_CCORR]
	 "CV_TM_SQDIFF" [method: CV_TM_SQDIFF]
	]
]


; to test what are the values associated to IplImage Pointeur
getValues: does [
	str: copy third isource ; values changed by routines are here
	i: 0
	while [not tail? str] [
	i: i + 1
	p: to-integer reverse copy/part str 4
	print [ i " : " p]
	str: skip str 4
	]
]


showCamera: does [
	
	isource: cvRetrieveFrame capture; 
	;applique le filtre médian pour réduire le bruit
	cvSmooth isource isource CV_GAUSSIAN 1 3 0.0 0.0 
	;affiche istemplate
	if cb/data [cvRectangle isource cadre_pt1/x cadre_pt1/y cadre_pt2/x cadre_pt2/y 0 0 255 0 thickness lineType 0]
	
	if istemplate [
	    cvZero template
		cvZero imaxmin
		;ROI definition
		roi: cvRect cadre_pt1/x cadre_pt1/y template/width template/height
		cvSetImageROI isource roi/x roi/y roi/width roi/height
		;getValues
		;copy ROI from isource to template
        cvCopy isource template none
        cvShowImage "Template" template 
        ;free ROI of isource
        cvResetImageROI isource
        istemplate: false
       
	]
	
	if ismatch [
		;ismatch the content of template in isource provide by cam  and put result in ftemp image
		cvMatchTemplate isource template imaxmin method ;OK
		;retrouver dans 'imaxmin' les coordonnées du point ayant une valeur maximale
		cvMinMaxLoc imaxmin &min_val &max_val &min_loc &max_loc 0 ;OK
		;défnir un deuxième point à partir du premier point et de la taille de 'imaxmin'
		max_loc2: make struct! cvPoint! reduce [&max_loc/x + template/width &max_loc/y + template/height]
		max_val: &max_val/float 
		;si la valeur maximale de 'imaxmin' est supérieure au 'seuil'
        ;dessiner un rectangle vert utilisant les coordonnées des deux points 'max_loc' et 'max_loc2'  
        set-text mval to-string round/to max_val 0.01
        ; just for normalized max values ;
		if max_val < 1 [
			if( max_val > seuil) [
		     cvRectangle isource &max_loc/x &max_loc/y max_loc2/x max_loc2/y 0 255 0 0 thickness lineType 0
			]
		]
		
		;tests for not normalized max  rvalues
		if max_val >= 1 [
			cvRectangle isource &max_loc/x &max_loc/y max_loc2/x max_loc2/y 0 255 255 0 thickness lineType 0
		]
		;cvShowImage "istemplate" template 
		cvShowImage "Max Min" imaxmin
		;ismatch: false
	]
	cvShowImage "Camera" isource
	cvResizeWindow "Camera" 640 480 
	cvGrabFrame capture	
]


activate

mainWin: [
	at 1x1 
	  cam: led
	  feel [engage: make function! [face action event] [switch action [time [showCamera]]]]
	  button 30 "Start" [start]
	  cb: check "Show Template "
	  button 30 "Make Template" [istemplate: true]
	  cb2: check "Match Template" [ismatch: face/data]
	  button 30 "Stop" [stop]
	  pad 15 
	  button 30 "Quit" [release quit]
	at 1x8
	 field 25 options [info] "Method" mType: drop-list 45 "CV_TM_CCOEFF_NORMED" data coeff [updateMethod]
	 field 25 options [info] "Threshold"
	 sl: slider 70x5 [seuil: round/to sl/data 0.01 set-text ct seuil]
	 ct: field 10 options [info] font [align: 'center] "0.0"
	 mval: field 28 options [info] font [align: 'center] "0.0"
	
]
display/position  "OpenCV: Patch Matching" mainWin 5x50
do-events
