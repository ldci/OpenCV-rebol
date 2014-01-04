#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Pyramid Segmentation"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
isFile: false

threshold1: 255
threshold2: 30
level: 4
block_size: 1000


comp: make struct! CvSeq! none
&comp: struct-address? comp


ON_SEGMENT: does [
    ct1/text: to-string threshold1
    ct2/text: to-string threshold2
    show [ct1 ct2]
    if isFile [
    	cvPyrSegmentation image0 image1 storage &comp level threshold1 + 1 threshold2 + 1
    	cvtoRebol/fit image1 rimage2
    ]
    recycle
]


loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
		    ; load image
			image: cvLoadImage filename CV_LOAD_IMAGE_COLOR;CV_LOAD_IMAGE_UNCHANGED
			
			&&image: make struct! int-ptr! reduce [struct-address? image] 
			;show rebol image
			cvtoRebol/fit image rimage1 
			
			imSize/text: join image/width [ " " image/height] 
			show imSize
			
			image/width: image/width and negate shift/left 1 level
			image/height: image/height and negate shift/left 1 level
			
			imSizeC/text: join image/width [ " " image/height] 
			show imSizeC
			
			image0: cvCloneImage image
			&&image0: make struct! int-ptr! reduce [struct-address? image0]
			
			
			; better create output than cvCloneImage image
			image1: cvCreateImage image/width image/height IPL_DEPTH_8U 3
			&&image1: make struct! int-ptr! reduce [struct-address? image1]
			
			
			storage: cvCreateMemStorage block_size
			&&storage:  make struct! int-ptr! reduce [struct-address? storage] 
    		isFile: true
			sl1/data: 1
			sl2/data: .33
			show [sl1 sl2] 
			ON_SEGMENT
		]
		[Alert "Not an image" ]
	]
]


release: does [
	if isFile [
		cvReleaseImage &&image
		cvReleaseImage &&image0
		cvReleaseImage &&image1
		cvReleaseMemStorage &&storage 
	]
	
]



mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x2 
	btn 100 "Load Image" [loadImage]
	imSize: info 150 center
	imSizeC: info 150 center
	at 935x2 btn 100 "Quit" [release quit]
	space 0x0
	at 5x27 box blue 1030x2
	at 5x30 txt 100 "Threshold 1" 
	at 110x35 sl1: slider 812x15 [threshold1: round (sl1/data * 255) ON_SEGMENT] 
	at 932x30 ct1: info 100 to-string threshold1 center
	
	at 5x55 txt 100 "Threshold 2" 
	at 110x60 sl2: slider 812x15 [threshold2:  round (sl2/data * 255) ON_SEGMENT]
	at 932x55 ct2: info 100 to-string threshold2 center
	
    at 5x80 rimage1: image 512x512 frame blue
    pad 5 rimage2: image 512x512 frame blue
	] 1040x600

sl1/data: 1
sl2/data: .33
center-face mainwin
view mainwin