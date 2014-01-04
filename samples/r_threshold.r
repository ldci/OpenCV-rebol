#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: Binary Threshold"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

Thresh: 127
threshold_type: CV_THRESH_BINARY
isFile: false


sumRGB: func [src dst] [
	;Allocate individual image planes: great!
	r: cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&r: struct-address? r
	g: cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&g: struct-address? g
	b: cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&b: struct-address? b
	
	&&r: make struct! int-ptr! reduce [&r] 
	&&g: make struct! int-ptr! reduce [&g] 
	&&b: make struct! int-ptr! reduce [&b] 
	
	; Split image onto the color planes. 
	cvSplit &src &r &g &b none ; cvSplit wants really integer pointer and not structures pointers ! 
	
	; we can also use &&variable/int
	
	; for split test 
	{cvNamedWindow "r" 1
	cvNamedWindow "g" 1
	cvNamedWindow "b" 1
	cvShowImage "r" r
	cvShowImage "g" g
	cvShowImage "b" b}
	
	;Temporary storage.
	s: cvCreateImage src/width src/height IPL_DEPTH_8U 1 
	&s: struct-address? s
	&&s: make struct! int-ptr! reduce [&s] 
	
	;Add equally weighted rgb values.
	cvAddWeighted &r 1 / 3.0  &g 1 / 3.0 0.0 &s
	cvAddWeighted &s 2 / 3.0 &b 2 / 3.0 0.0 &s
    ;Truncate values above threshold value
	cvThreshold s dst Thresh Thresh threshold_type
	; for rebol who have difficulties with image channel = 1 
	cvConvertImage dst clone 0
	either cb/data [cvtoRebol/fit clone rimage2] [cvtoRebol clone rimage2]
	
	
	r: g: b: s: none
	&r: &g: &b: none
	cvReleaseImage &&r
	cvReleaseImage &&g
	cvReleaseImage &&b
	cvReleaseImage &&s
	recycle
]





loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			src: cvLoadImage filename CV_LOAD_IMAGE_COLOR
			;print [src/depth " " src/nchannels]
			clone: cvCloneImage src
			&src: struct-address? src
			&&src: make struct! int-ptr! reduce [struct-address? src] 
			dst: cvCreateImage src/width src/height src/depth 1
			&&dst: make struct! int-ptr! reduce [struct-address? dst] 
			either cb/data [cvtoRebol/fit src rimage1] [cvtoRebol src rimage1] 
			either cb/data [cvtoRebol/fit src rimage2] [cvtoRebol src rimage2]
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



mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Image" [loadImage]
	txt "Threshold" 
	sl1: slider 102x25 [ makeThresh] oct: info 40 "127" 
	tType: choice 180 data [CV_THRESH_BINARY CV_THRESH_BINARY_INV CV_THRESH_TRUNC CV_THRESH_TOZERO CV_THRESH_TOZERO_INV] [threshold_type: get to word! face/text makeThresh]
	txt "Fits Image" cb: check 20x20 true
	at 935x5 btn 100 "Quit" [if isFile [cvReleaseImage &&src cvReleaseImage &&dst] quit]
	space 0x0
    at 5x30 rimage1: image 512x512 frame blue
	at 525x30 rimage2: image 512x512 frame blue
	
	] 1045x560
sl1/data: 0.5
center-face mainwin
view mainwin