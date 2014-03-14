#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Edge Camera"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
img1: img2: none 
isShow: false

cvStartWindowThread ; separate window thread
nbhsize: [7 5 3 1]
neighbourhoodSize: 7 ; for laplace odd and max = 7 

capture: cvCreateCameraCapture CV_CAP_ANY 							; create a capture using default webcam
image: make struct! IplImage! second cvQueryFrame capture 			; get the first image 
;for cvLaplace only IPL_DEPTH_32F IPL_DEPTH_16S as destination image
laplace: cvCreateImage image/width image/height IPL_DEPTH_32F image/nChannels


showCamera: has [frame] [
	isShow: true
	while [isShow] [
		frame: cvQueryFrame capture  
		rimage1/image: cam2Rebol frame
		cvLaplace frame laplace neighbourhoodSize ; 32 bit image
		cvConvertImage laplace frame 0    		  ; 32 -> 24 bit image
		rimage2/image: cam2Rebol frame
		mem/text: round/to stats / (10 ** 6) 0.01
		show [rimage1 rimage2 mem] 
		wait 0.025
	]	
]

hideCamera: does [
	rimage1/image/rgb: 0
	rimage2/image/rgb: 0
	show [rimage1 rimage2]
	isShow: false
	recycle
]


mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x10
	cam: led red green
	at 20x5
	btn 100 "Start" #"s" [cam/colors/2: red show cam  showCamera ]
	btn 100 "Pause" #"p" [cam/colors/2: green show cam hideCamera ]
	choice silver 30 data nbhsize [neighbourhoodSize: to-integer face/text]
	mem: info 100 
	pad 170
	btn 100 "Quit"  #"q" [cvReleaseImage laplace cvReleaseCapture capture quit]
	space 0x0
    at 5x30 rimage1: image 320x240 black effect [fit flip 1x1] frame white
    pad 2
	rimage2: image 320x240 black effect [fit flip 1x1] frame white
] 650x280

center-face mainwin
view mainwin
