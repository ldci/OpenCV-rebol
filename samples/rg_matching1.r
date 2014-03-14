#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Matching"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
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
template: match: false

max_val: 0.0
&min_val: float-ptr! none
&max_val: float-ptr! none

&min_loc: make struct! cvPoint! [0 0]
&max_loc: make struct! cvPoint! [0 0]

coeff: [CV_TM_CCOEFF_NORMED  CV_TM_CCOEFF CV_TM_CCORR_NORMED CV_TM_CCORR CV_TM_SQDIFF_NORMED CV_TM_SQDIFF] 

method: CV_TM_CCOEFF_NORMED

activate: does [
	;activate cam
	capture: cvCreateCameraCapture CV_CAP_ANY 
	cvGrabFrame capture
	;show cam image
	src: cvRetrieveFrame capture
	
	;we need 
	w: 640 / 4 ;src/width / 4 
	h: 480 / 2 ;src/height / 2
	
	tsize: as-pair w / 4 h / 4
	
	
	pos3: as-pair 165 h / 4
	templ: cvCreateImage  w h 8 3
	
	;ftmp size
	iwidth: src/width - templ/width + 1
	iheight: src/height - templ/height + 1
	ftmp: cvCreateImage iwidth iheight IPL_DEPTH_32F 1
	
	
	; for rectangle template
	cadre_pt1: make struct! CvPoint! reduce [((src/width - templ/width) / 2)  ((src/height - templ/height) / 2)]
	cadre_pt2: make struct! CvPoint! reduce [(cadre_pt1/x + templ/width)  (cadre_pt1/y + templ/height)]
	; for test
	;cvNamedWindow "template" CV_WINDOW_AUTOSIZE
]

start: does [
isFile: true
	cam/data: true  
	rimage1/rate: 48 
	show [rimage1 cam]
]

stop: does [
	cam/data: false
	rimage1/rate: none 
	rimage1/image/rgb: rimage2/image/rgb: rimage3/image/rgb: 0.0.0 
	show [rimage1 rimage2 rimage3 cam]

]

release: does [
	if isFile [
		cvReleaseImage src
		cvReleaseImage templ
		cvReleaseImage ftmp
	]
	
]

updateMethod: does [
	switch mType/text [
	 "CV_TM_CCOEFF_NORMED" [method: CV_TM_CCOEFF_NORMED]
	 "CV_TM_CCOEFF" [method: CV_TM_CCOEFF]
	 "CV_TM_CCORR_NORMED" [method: CV_TM_CCORR_NORMED]
	 "CV_TM_CCORR" [method: CV_TM_CCORR]
	 "CV_TM_SQDIFF_NORMED" [method: CV_TM_SQDIFF_NORMED]
	 "CV_TM_SQDIFF" [method: CV_TM_SQDIFF]
	]
]


; to test what are the values associated to IplImage Pointeur
getValues: does [
	str: copy third src ; values changed by routines are here
	i: 0
	while [not tail? str] [
	i: i + 1
	p: to-integer reverse copy/part str 4
	print [ i " : " p]
	str: skip str 4
	]
]


showCamera: does [
	
	src: cvRetrieveFrame capture; 
	;applique le filtre médian pour réduire le bruit
	cvSmooth src src CV_GAUSSIAN 1 3 0.0 0.0 
	if cb/data [cvRectangle src cadre_pt1/x cadre_pt1/y cadre_pt2/x cadre_pt2/y 0 0 255 0 thickness lineType 0]
	
	if template [
	    cvZero templ
		cvZero ftmp
		;getValues 
		
		;ROI definition
		roi: cvRect cadre_pt1/x cadre_pt1/y templ/width templ/height
		cvSetImageROI src roi/x roi/y roi/width roi/height
		;getValues
		;copy ROI from src to templ
        cvCopy src templ none
        ;cvShowImage "template" templ 
        cvtoRebol templ rimage2
        ;free ROI of src
        cvResetImageROI src
        template: false
       
	]
	if match [
		;match the content of templ in src provide by cam  and put result in ftemp image
		
    	;CV_TM_CCOEFF_NORMED
    	
    	
		cvMatchTemplate src templ ftmp method ;OK
		
		;retrouver dans 'ftmp' les coordonnées du point ayant une valeur maximale
		cvMinMaxLoc ftmp &min_val &max_val &min_loc &max_loc 0 ;OK
		
	
		
		;défnir un deuxième point à partir du premier point et de la taille de 'ftmp'
		max_loc2: make struct! cvPoint! reduce [&max_loc/x + templ/width &max_loc/y + templ/height]
		
		max_val: &max_val/float 
		;si la valeur maximale de 'ftmp' est supérieure au 'seuil'
        ;dessiner un rectangle bleu utilisant les coordonnées des deux points 'max_loc' et 'max_loc2'
        
        
		if max_val < 1 [
			if( max_val > seuil) [
		     cvRectangle src &max_loc/x &max_loc/y max_loc2/x max_loc2/y 255 0 0 0 thickness lineType 0
			]
		]
	
	    
		cvtoRebol ftmp rimage3
		
		;cvShowImage "template" templ 

		;match: false
	]
	cvtoRebol src rimage1
	free-mem src
	
	cvGrabFrame capture	
]




activate


mainWin: [
	at 1x1 
	  cam: led
	  button 30 "Start" [start]
	  cb: check "Show Template "
	  button 30 "Make Template" [template: true]
	  cb2: check "Match Template" [match: face/data]
	  button 30 "Stop" [stop]
	  pad 15 
	  button 30 "Quit" [release quit]
	at 1x8
	 field 25 options [info] "Method" mType: drop-list 45 "CV_TM_CCOEFF_NORMED" data coeff [updateMethod]
	 field 25 options [info] "Threshold"
	 sl: slider 90x5 [seuil: round/to sl/data 0.01 set-text ct seuil]
	
	 ct: field 18 options [info] font [align: 'center] "0.0"
	
	at 1x15 
	panel data [
		at 0x0 rimage1: image black 160x120
		feel [engage: make function! [face action event] [switch action [time [showCamera]]]]
		at 165x0 rimage2: image black tsize
		at pos3 rimage3: image black tsize
	]
]


display "OpenCV: Matching" mainWin 
do-events
