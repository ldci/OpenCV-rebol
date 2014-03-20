#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Binary Threshold"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

Thresh: 127
threshold_type: CV_THRESH_BINARY
isFile: false
tType: [CV_THRESH_BINARY CV_THRESH_BINARY_INV CV_THRESH_TRUNC CV_THRESH_TOZERO CV_THRESH_TOZERO_INV]

sumRGB: func [src dst] [
	&src: as-pointer! src
	&dst: as-pointer! dst
	;Allocate individual image planes: great!
	&r: as-pointer! cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&g: as-pointer! cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&b: as-pointer! cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	
	; Split image onto the color planes. 
	cvSplit &src &r &g &b none ; 
	
	
	; for split test 
	{cvNamedWindow "r" 1
	cvNamedWindow "g" 1
	cvNamedWindow "b" 1
	cvShowImage "r" &r
	cvShowImage "g" &g
	cvShowImage "b" &b}
	
	;Temporary storage.
	&s: as-pointer! cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	
	;Add equally weighted rgb values.
	cvAddWeighted &r 1 / 3.0  &g 1 / 3.0 0.0 &s
	cvAddWeighted &s 2 / 3.0 &b 2 / 3.0 0.0 &s
    ;Truncate values above threshold value
	cvThreshold &s &dst Thresh Thresh threshold_type
	; for rebol who have difficulties with image channel = 1 
	cvConvertImage &dst &clone 0
	cvtoRebol clone rimage2
	
	cvReleaseImage &r
	cvReleaseImage &g
	cvReleaseImage &b
	cvReleaseImage &s
]





loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			src: cvLoadImage filename CV_LOAD_IMAGE_COLOR
			&src: as-pointer! src 
			;print [src/depth " " src/nchannels]
			clone: cvCloneImage &src
			&clone: as-pointer! clone
			dst: cvCreateImage src/width src/height src/depth 1
			&dst: as-pointer! dst
			cvtoRebol src rimage1
			cvtoRebol src rimage2
			isFile: true
			sl1/data: 0.5
			oct/text: "127"
			show [sl1 oct]
			makeThresh
		]
		[Alert "Not an image" ]
	]
]

makeThresh: does [
	if isFile [
		Thresh: to-integer (sl1/data * 255) 
		oct/text: thresh 
		show oct 
		sumRGB src dst
	]
]


mainWin: [
	at 1x1 
	button 25 "Load Image" [loadImage]
	;cb: check " Fits image" data true 
	text 20 options [info] "Threshold"
	sl1: slider 72x5 [ makeThresh] oct: field 10 "127" options [info] font [align: 'center]
	tType: drop-list 45 "CV_THRESH_BINARY" data tType [threshold_type:  get to word! face/text makeThresh]
	pad 59
	button 25 "Quit" [if isFile [cvReleaseImage src cvReleaseImage dst] quit]
	return
	panel data [
		rimage1: image 128x128 tip "Source Image"
		splitter 1x128
		rimage2: image 128x128 tip "Processed Image"
		return
		mem: field 260 options [info]
	]
]




display "OpenCV: Binary Threshold" mainWin
do-events