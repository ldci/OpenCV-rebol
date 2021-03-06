#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"Fran�ois Jouen"
	Rights:		"Copyright (c) 2012-2013 Fran�ois Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;some improvements by Walid Yahia 2014 
do %../opencv.r
set 'appDir what-dir 

;picture: to-string to-local-file join appDir "images/lena.jpg"

print "Select a picture"

temp: request-file 
picture: to-string to-local-file to-string temp


srcWnd: "Using cvTrackbar: ESC to close"
dstWnd: "Filtering"
tBar: "Filtre"

; callback functions called by trackbar


{To summarize, in order to call cvCreateTrackbar  you need to declared a function with the signature void 
some_fun [pos [integer!]] to be able to be notified by OpenCV when the slider of the trackbar is updated. 
The argument  pos informs the new position of the slider.}


; CV_BLUR CV_GAUSSIAN CV_MEDIAN : OK 
; CV_BLUR_NO_SCALE CV_BILATERAL : OK;

trackEvent: func [pos] [ 
		;if odd? pos
		if (pos and 1) = 1 [
			cvSmooth &src &dst CV_MEDIAN pos 1 0.0 0.0 
			cvShowImage dstWnd &dst
		]
]


loadImage: does [
	cvNamedWindow srcWnd CV_WINDOW_AUTOSIZE
	cvNamedWindow dstWnd CV_WINDOW_AUTOSIZE
	src: cvLoadImage picture CV_LOAD_IMAGE_UNCHANGED 
	&src: as-pointer! src
	&dst: as-pointer! cvCloneImage &src
	
	
	cvMoveWindow srcWnd 25 100
	cvMoveWindow dstWnd 540 120
	
	&pos: make struct! int-ptr! [0]
	cvCreateTrackbar tBar srcWnd &pos 255 :trackEvent &pos
	cvShowImage srcWnd &src
	cvShowImage dstWnd &dst	
	cvwaitKey 0
]

loadImage

cvwaitKey 0
free-mem &pos
cvReleaseImage src
cvReleaseImage &src
cvReleaseImage &dst
cvDestroyWindow srcWnd
cvDestroyWindow dstWnd

