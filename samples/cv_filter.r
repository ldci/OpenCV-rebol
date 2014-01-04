#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

fileName: to-string to-local-file join appDir "images/lena.jpg"
probe fileName
srcWnd: "Using cvTrackbar: ESC to close"
dstWnd: "Filtering"
tBar: "Filtre"

; callback functions called by trackbar


{To summarize, in order to call cvCreateTrackbar  you need to declared a function with the signature void 
some_fun [pos [integer!]] to be able to be notified by OpenCV when the slider of the trackbar is updated. 
The argument  pos informs the new position of the slider.}


; CV_BLUR CV_GAUSSIAN CV_MEDIAN : OK 
; CV_BLUR_NO_SCALE CV_BILATERAL : TBT see documentation

trackEvent: func [pos] [ 
		;if odd? pos
		if (pos and 1) = 1
		 [
						cvSmooth src dst CV_GAUSSIAN pos 1 0.0 0.0 
						cvShowImage dstWnd dst
		]
]


loadImage: does [
	cvNamedWindow srcWnd CV_WINDOW_AUTOSIZE
	cvNamedWindow dstWnd CV_WINDOW_AUTOSIZE
	src: cvLoadImage fileName CV_LOAD_IMAGE_UNCHANGED 
	dst: cvCloneImage src
	&src: struct-address? src
	&dst: struct-address? dst
	&&src: make struct! int-ptr! reduce [struct-address? src]
	&&dst: make struct! int-ptr! reduce [struct-address? dst]
	
	cvMoveWindow srcWnd 25 100
	cvMoveWindow dstWnd 540 120
	
	&pos: make struct! int-ptr! [0]
	cvCreateTrackbar tBar srcWnd &pos 255 :trackEvent &pos
	cvShowImage srcWnd src
	cvShowImage dstWnd dst	
]

loadImage
cvwaitKey 0
free-mem &pos
cvReleaseImage &&src
cvReleaseImage &&dst
cvDestroyWindow srcWnd
cvDestroyWindow dstWnd

