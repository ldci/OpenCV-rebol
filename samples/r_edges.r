#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Canny Detector"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 FranÁois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 

edge_thresh: 0
max_thresh: 100
isfile: false 

;when moving slider
onTrackbar: does [
    edge_thresh: sl1/data * max_thresh					;update threshold with slider
    cvSmooth gray edge CV_BLUR 3 3 0 0             	;filter
    cvNot &gray &edge									;element bit-wise inversion of array elements
    cvCanny gray edge edge_thresh edge_thresh * 3 3 	;Run the edge detector on grayscale
    cvZero cedge										;color edges window to black
    cvCopy image cedge &edge							;copy edge points
    ; copy to rebol image
    either edge_thresh = 0 [cvtoRebol/fit image rimage1]
    [cvtoRebol/fit cedge rimage1] 
    oct/text: to-string round/to edge_thresh 0.01
    show oct
    recycle
]


loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
		    ; load image
			image: cvLoadImage filename CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_UNCHANGED 
			&image: struct-address? image
			&&image: make struct! int-ptr! reduce [&image] 
			;Create the color output image
			cedge: cvCreateImage image/width image/height IPL_DEPTH_8U 3
			&cedge: struct-address? cedge
			&&cedge: make struct! int-ptr! reduce [&cedge]
			;// Convert to grayscale
    		gray: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    		&gray: struct-address? gray
    		&&gray: make struct! int-ptr! reduce [&gray] 
    		edge: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    		&edge: struct-address? edge
    		&&edge: make struct! int-ptr! reduce [&edge] 
    		cvCvtColor image gray CV_BGR2GRAY
    		;show rebol image
			cvtoRebol/fit image rimage1 
			isFile: true
			sl1/data: 0
			show sl1
		]
		[Alert "Not an image" ]
	]
]




mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x2 
	btn 100 "Load Image" [loadImage]
	btn 100 "Quit" [if isFile [cvReleaseImage &&image cvReleaseImage &&cedge
					cvReleaseImage &&gray cvReleaseImage &&edge] 
					quit]
	space 0x0
	at 5x27 box blue 510x2
	at 5x30 txt 100 "Threshold" 
	at 110x35 sl1: slider 212x15 [if isFile [onTrackbar]] 
	at 327x30 oct: txt 50 "0.0"
	txt left "Max Treshold" 
	mxt: field 45 to-string max_thresh [if error? try [max_thresh: to-decimal mxt/text] [max_thresh: 100]]
    at 5x60 rimage1: image 512x512 frame blue
	] 520x580

sl1/data: 0
center-face mainwin
view mainwin