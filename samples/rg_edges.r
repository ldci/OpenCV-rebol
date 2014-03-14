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
max_thresh: 100
smax: to-string max_thresh
isfile: false 

;when moving slider
onTrackbar: does [
    edge_thresh: sl1/data * max_thresh					;update threshold with slider
    cvSmooth gray edge CV_BLUR 3 3 0 0             	;filter
    cvNot gray edge									;element bit-wise inversion of array elements
    cvCanny gray edge edge_thresh edge_thresh * 3 3 	;Run the edge detector on grayscale
    cvZero cedge										;color edges window to black
    cvCopy image cedge edge							;copy edge points
    ; copy to rebol image
    either edge_thresh = 0 [cvtoRebol image rimage1] [cvtoRebol cedge rimage1]
    
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
			;Create the color output image
			cedge: cvCreateImage image/width image/height IPL_DEPTH_8U 3
			;// Convert to grayscale
    		gray: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    		edge: cvCreateImage image/width image/height IPL_DEPTH_8U 1
    		cvCvtColor image gray CV_BGR2GRAY
    		;show rebol image
    		cvtoRebol image rimage1 
			isFile: true
			sl1/data: 0
			show sl1
		]
		[Alert "Not an image" ]
	]
]





mainWin: [
	at 1x0 button 25 "Load Image" [loadImage] 
	at 112x1 button 25 "Quit" [if isFile [cvReleaseImage image cvReleaseImage cedge
					cvReleaseImage gray cvReleaseImage edge] 
					quit]
	at 1x8 field 20 "Threshold" options [info] sl1: slider 60x5 options [arrows][if isFile [onTrackbar]] 
	oct: field 12 "0.0" options [info] font [align: 'center]
	field 25 "Max Threshold" options [info]
	mxt: field 10 smax [if error? try [max_thresh: to-decimal mxt/text] [max_thresh: 100]]
	at 1x15 panel data [
		rimage1: image 128x128
	]

]

display "OpenCV Tests: Canny Detector" mainWin
do-events