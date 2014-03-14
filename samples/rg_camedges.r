#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Canny Detector"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

edge_thresh: 0
max_thresh: 255
smax: to-string max_thresh
isfile: false 

activateCam: does [
	capture: cvCreateCameraCapture CV_CAP_ANY  									; create a capture using default webcam
	cvGrabFrame	capture
	image: cvRetrieveFrame capture	
	imSize: length? third image
	
	;Create the color output image
	cedge: cvCreateImage image/width image/height IPL_DEPTH_8U 3
	&cedge: struct-address? cedge
	
	;// Convert to grayscale
    gray: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    
    edge: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    
	sl1/data: 0.0
	show sl1
	cam/data: true show cam
	isFile: true
]


filter: does [
    cvCvtColor image gray CV_BGR2GRAY
	cvSmooth gray edge CV_BLUR 3 3 0 0             		;filter
    cvNot gray edge									;element bit-wise inversion of array elements
    cvCanny gray edge edge_thresh edge_thresh * 3 3 	;Run the edge detector on grayscale
    cvZero cedge										;color edges window to black
    cvCopy image cedge edge							;copy edge points
    ; copy to rebol image
    either edge_thresh = 0 [cvtoRebol image rimage1] [cvtoRebol cedge rimage1]
    oct/text: to-string round/to edge_thresh 0.01
    show oct
]

showCam: does [
	cvGrabFrame capture
	image: cvRetrieveFrame capture    		  ; 24 bit webcam image
	filter
	image: none

]

hideCam: does [
	rimage1/rate: none 
	rimage1/image: load ""
	show rimage1
	cam/data: false show cam
]



mainWin: [
	at 1x0 
	cam: led pad 1
	button 38 "Activate cam" [activateCam]
	button 38 "Start" [cam/data: true show cam rimage1/rate: 60 show rimage1] 
	button 38 "Stop" [hideCam]
	button 38 "Quit" [if isFile [cvReleaseImage image cvReleaseImage cedge
					cvReleaseImage gray cvReleaseImage edge] 
					quit]
	at 1x8 field 20 "Threshold" options [info] sl1: slider 92x5 options [arrows][edge_thresh: sl1/data * max_thresh] 
	oct: field 12 "0.0" options [info] font [align: 'center]
	field 25 "Max Threshold" options [info]
	mxt: field 10 smax [if error? try [max_thresh: to-decimal mxt/text] [max_thresh: 100]]
	at 1x15 panel linen data [
		rimage1: black image 160x120
		feel [engage: make function! [face action event] [switch action [time [showCam]]]]
	]

]

display "OpenCV Tests: Cam Canny Detector" mainWin
do-events