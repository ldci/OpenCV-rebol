#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Edge Camera"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2014 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"



nbhsize: reverse [1 3 5 7]
neighbourhoodSize: 7 ; for laplace odd and max = 7 

capture: cvCreateCameraCapture CV_CAP_ANY 							; create a capture using default webcam

image: make struct! IplImage! second cvQueryFrame capture 			; get the first image 
;for cvLaplace only IPL_DEPTH_32F IPL_DEPTH_16S as destination image

laplace: cvCreateImage image/width image/height IPL_DEPTH_32F image/nChannels




showCamera: does [
	frame: cvQueryFrame capture  
	cvtoRebol frame rimage1					; transform to REBOL
	cvLaplace frame laplace neighbourhoodSize ; 32 bit image
	cvConvertImage laplace  frame none   		  ; 32 -> 24 bit image
	cvtoRebol  frame rimage2					; transform to REBOL
	frame: none
	mem/text: stats / (10 ** 6) 
	show mem 
]


mainWin: [
	at 
	1x1 cam: led
	button 35 "Start" #"s" [cam/data: true show cam rimage1/rate: 60 show rimage1 ]
	button 35 "Pause" #"p" [cam/data: false show cam rimage1/rate: none show rimage1 recycle]
	pad 8
	text 17 options [info] "Threshold"
	edit-list "7" data nbhsize [neighbourhoodSize: to-integer face/text]
	mem: field 20 options [info] 
	
	button 18 "Quit"  #"q"[ cvReleaseImage laplace cvReleaseCapture capture quit]
	return
	panel data [
		rimage1: image black 80x60 
		feel [engage: make function! [face action event] [switch action [time [showCamera]]]]
	]
	
	panel data [
		rimage2: image black 80x60 	
	]

]

display "OpenCV Tests: Edge Camera" mainWin
do-events

