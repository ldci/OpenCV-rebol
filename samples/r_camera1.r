#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Edge Camera"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

cvStartWindowThread ; separate window thread
nbhsize: [7 5 3 1]
neighbourhoodSize: 7 ; for laplace odd and max = 7 

; create a capture using default webcam							
&capture: as-pointer! cvCreateCameraCapture CV_CAP_ANY  
; get the first image 
image: cvQueryFrame &capture 			
;for cvLaplace only IPL_DEPTH_32F IPL_DEPTH_16S as destination image
&laplace: as-pointer! cvCreateImage image/width image/height IPL_DEPTH_32F image/nChannels
&image: as-pointer! image


showCamera: has [frame] [
	frame: cvQueryFrame &capture   
	&frame: as-pointer! frame
	cvtoRebol frame rimage1					; transform to REBOL
	cvLaplace &frame &laplace neighbourhoodSize ; 32 bit image
	cvConvertImage &laplace  &frame 0    		  ; 32 -> 24 bit image
	cvtoRebol  frame rimage2					; transform to REBOL
	frame: none
	mem/text: round/to stats / (10 ** 6) 0.01
	show mem 
]

hideCamera: does [
	rimage1/rate: none 
	rimage1/image/rgb: 0
	rimage2/image/rgb: 0
	show [rimage1 rimage2]
	recycle
]


mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x10
	cam: led red green
	at 20x5
	btn 100 "Start" #"s" [cam/colors/2: red show cam rimage1/rate: 24 show rimage1 ]
	btn 100 "Pause" #"p" [cam/colors/2: green show cam hideCamera ]
	choice black 30 data nbhsize [neighbourhoodSize: to-integer face/text]
	mem: info 100 
	pad 170
	btn 100 "Quit"  #"q" [cvReleaseImage &laplace cvReleaseCapture &capture quit]
	space 0x0
    at 5x30 rimage1: image 320x240 black
		with [rate: none]
		feel [engage: func [face action event] [switch action [time [recycle showCamera]]]
		] 
    frame white
    pad 2
	rimage2: image 320x240 black frame white
] 650x280

center-face mainwin
view mainwin
