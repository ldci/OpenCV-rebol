#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Adaptative Threshold"
	Author:		"Francois Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"


Threshold: 127.00

threshold_type: CV_THRESH_BINARY ;  
adaptive_threshold_type: CV_THRESH_BINARY; or CV_THRESH_BINARY_INV;

adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C; CV_ADAPTIVE_THRESH_MEAN_C ; or 

block_size: 3 ; 3 5 7 ...

offset: 5

isFile: false


loadImage: does [
	
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
		    ;Read in gray image
			Igray: cvLoadImage filename CV_LOAD_IMAGE_GRAYSCALE
			clone: cvLoadImage filename CV_LOAD_IMAGE_COLOR ; pour avoir 3 channels
			
			cvtoRebol clone rimage1
			
			;Create the grayscale output images
			Iat: cvCreateImage Igray/width Igray/height IPL_DEPTH_8U 1
			isFile: true
		]
		[Alert "Not an image" ]
	]
]



showImages: does [
 	cvAdaptiveThreshold Igray Iat 255 adaptive_method adaptive_threshold_type block_size offset
 	cvConvertImage iat clone 0
	cvtoRebol clone rimage2
	recycle
]

release: does [
	cvReleaseImage Igray
	cvReleaseImage Iat
	cvReleaseImage clone
]



makeAdaptative: does [
	if isFile [
		switch aMethod/text [
			"CV_ADAPTIVE_THRESH_MEAN_C"  [adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C]
			"CV_ADAPTIVE_THRESH_GAUSSIAN_C"  [adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C]
		]
		
		switch tType/text [
		"CV_THRESH_BINARY" [adaptive_threshold_type: CV_THRESH_BINARY]
		"CV_THRESH_BINARY_INV"  [adaptive_threshold_type: CV_THRESH_BINARY_INV]
		]
		
		if error? try [block_size: to-integer aBlocSize/text
			if not odd? block_size [block_size: block_size - 1]
			if block_size <= 1 [block_size: 3]
		] [block_size: 3]
		
		if error? try [offset: to-integer aParam/text] [offset: 5]
		
	showImages
	]

]

mainWin: [
	at 1x1 
	button 22 "Load Image" [loadImage if isFile [makeAdaptative]]
	text options [info] "Adaptative Method"
	aMethod: drop-list 60 "CV_ADAPTIVE_THRESH_MEAN_C" data ["CV_ADAPTIVE_THRESH_MEAN_C" "CV_ADAPTIVE_THRESH_GAUSSIAN_C" ] [makeAdaptative]
	text options [info] "Type"
	tType: drop-list 42 "CV_THRESH_BINARY" data [ "CV_THRESH_BINARY" "CV_THRESH_BINARY_INV" ] [makeAdaptative]
	text options [info] "Bloc Size (odd)"
	aBlocSize: field 10 "3" font [align: 'center] [makeAdaptative] 
	text options [info] "+/- Constant"
	aParam: field 10 "5" font [align: 'center] [makeAdaptative] 
	button 18 "Quit" [if isFile [release] quit]
	return
	panel data [
		rimage1: image 128x128 tip "Source Image"
		splitter 1x128
		rimage2: image 128x128 tip "Destination Image"
	]
]

display "OpenCV: Adaptative Threshold" mainWin
do-events