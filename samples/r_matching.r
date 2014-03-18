#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Patch Matching"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

; inspired by  Amine M. Azzaoui's sample (http://opencvblogger.wordpress.com/)
; start btn for activate webcam
; use show template to create rectangle
; place your face inside the red rectangle
; make template button to create the pattern
; activate Match Template check
; move your face
; green rectangle follows your face :) 
 
do %../opencv.r

isFile: false 
thresHold: 0.0
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
	&capture: as-pointer! capture
	cvGrabFrame &capture
	;show cam image
	isource: cvRetrieveFrame &capture
	&isource: as-pointer! isource
	
	w: isource/width / 4  ; 640 /4
	h: isource/height / 2 ; 480 / 4
	template: cvCreateImage  w  h 8 3
	&template: as-pointer! template
	;imaxmin size
	iwidth: isource/width - template/width + 1
	iheight: isource/height - template/height + 1
	&imaxmin: as-pointer! cvCreateImage iwidth iheight IPL_DEPTH_32F 1
	
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
		cvReleaseImage &isource
		cvReleaseImage template
		cvReleaseImage &template
		cvReleaseImage &imaxmin
	]
]



showCamera: does [
	isource: cvRetrieveFrame &capture; 
	&isource: as-pointer! isource
	;applique le filtre mŽdian pour rŽduire le bruit
	cvSmooth &isource &isource CV_GAUSSIAN 1 3 0.0 0.0 
	;affiche istemplate
	if cb/data [cvRectangle &isource cadre_pt1/x cadre_pt1/y cadre_pt2/x cadre_pt2/y 0 0 255 0 thickness lineType 0]
	
	if istemplate [
	    cvZero &template
		cvZero &imaxmin
		;ROI definition
		roi: cvRect cadre_pt1/x cadre_pt1/y template/width template/height
		cvSetImageROI &isource roi/x roi/y roi/width roi/height
		;copy ROI from isource to template
        cvCopy &isource &template none
        cvShowImage "Template" &template 
        ;free ROI of isource
        cvResetImageROI &isource
        istemplate: false
       
	]
	
	if ismatch [
		;ismatch the content of template in isource provide by cam  and put result in ftemp image
		cvMatchTemplate &isource &template &imaxmin method ;OK
		;find 'imaxmin' coordinates of pixel with max value [correlations 0..1]
		cvMinMaxLoc &imaxmin &min_val &max_val &min_loc &max_loc 0 ;OK
		;define second cvpoint  with 'imaxmin' size
		max_loc2: make struct! cvPoint! reduce [&max_loc/x + template/width &max_loc/y + template/height]
		max_val: &max_val/float 
		;if max val  > thresHold then draw green rectangle  
        mval/text to-string round/to max_val 0.01
        ; just for normalized max values ;
		if max_val < 1 [
			if( max_val > thresHold) [
		     cvRectangle &isource &max_loc/x &max_loc/y max_loc2/x max_loc2/y 0 255 0 0 thickness lineType 0
			]
		]
		;tests for not normalized max  rvalues
		if max_val >= 1 [
			cvRectangle &isource &max_loc/x &max_loc/y max_loc2/x max_loc2/y 0 255 255 0 thickness lineType 0
		]
		;cvShowImage "istemplate" template 
		cvShowImage "Max Min" &imaxmin
		;ismatch: false
	]
	show mval
	cvShowImage "Camera" &isource
	cvResizeWindow "Camera" 640 480 
	cvGrabFrame &capture	
]



mainWin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5  
	  cam: led
	  feel [engage: make function! [face action event] [switch action [time [showCamera]]]]
	  btn 70 "Start" [start]
	  txt "Show Template " cb: check 20x25
	  btn 120 "Make Template" [istemplate: true]
	  txt "Match Template" cb2: check 20x25 [ismatch: face/data]
	  btn 70 "Stop" [stop]
	  
	  btn 70 "Quit" [release quit]
	at 5x35
	 info 70 "Method" mType: rotary black 200 data coeff [flags: get to word! face/text]
	 info 80  "Threshold"
	 sl: slider 150x25 [thresHold: round/to sl/data 0.01 ct/text: thresHold show ct]
	 ct: info 50  "0.0"
	 mval: info 50 "0.0"
	
] 640x70

activate
view mainwin