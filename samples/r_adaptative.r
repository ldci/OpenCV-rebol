#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Adaptative Threshold"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

Threshold: 127.00

threshold_type: CV_THRESH_BINARY ;  
adaptive_threshold_type: CV_THRESH_BINARY; or CV_THRESH_BINARY_INV;

adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C; CV_ADAPTIVE_THRESH_MEAN_C ; or 

block_size: 3 ; 3 5 7 ...

_offset: 5

isFile: false


loadImage: does [
	
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			;read src image
			src: cvLoadImage filename CV_LOAD_IMAGE_COLOR;  force 3 channels reading  
			;Create the grayscale output images
			Igray: cvCreateImage src/width src/height IPL_DEPTH_8U 1
			cvCvtColor src Igray CV_BGR2GRAY
			Iat: cvCreateImage Igray/width Igray/height IPL_DEPTH_8U 1
			;make a rebol image
			cvtoRebol  src rimage1
			isFile: true
			;cvNamedWindow "src" CV_WINDOW_AUTOSIZE 
			;cvShowImage "src" src 
		]
		[Alert "Not an image" ]
	]
]



showImages: does [
 	cvAdaptiveThreshold Igray Iat 255 adaptive_method adaptive_threshold_type block_size _offset
 	cvConvertImage iat src none
	cvtoRebol src rimage2
]

release: does [
	cvReleaseImage Igray
	cvReleaseImage Iat
	cvReleaseImage src
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
		
		if error? try [_offset: to-integer aParam/text] [_offset: 5]
		
	showImages
	]

]
 


mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Image" [loadImage if isFile [makeAdaptative]]
	txt "Adaptative Method" 
	aMethod: choice 230 data ["CV_ADAPTIVE_THRESH_MEAN_C" "CV_ADAPTIVE_THRESH_GAUSSIAN_C" ] [makeAdaptative]
	txt "Type"
	tType: choice 180 data [ "CV_THRESH_BINARY" "CV_THRESH_BINARY_INV" ] [makeAdaptative]
	txt "Bloc Size (odd)"
	aBlocSize: field 40 to-string block_size [makeAdaptative]
	txt "+/- Constant" 
	aParam: field 40 to-string _offset [makeAdaptative] 
	btn 50 "Quit" [if isFile [release] quit]
	space 0x0
    at 5x30 rimage1: image 512x512 frame blue
	at 525x30 rimage2: image 512x512 frame blue
	
	] 1045x560
center-face mainwin
view mainwin