#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Morphology"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2014 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

filename: to-string to-local-file join appDir"images/baboon.jpg"

max_iters: 10;
element_shape: CV_SHAPE_RECT;
isFile: false

;Open/close morphology operators

openClose: does [
	&src: as-pointer! src
    &dst: as-pointer! dst
    n: (round sl1/data * max_iters * 2) - max_iters
    either n > 0 [an: n] [an: negate n]
    element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	&&element: make struct! int-ptr! reduce [struct-address? element]  ; a double pointer
	either n < 0 [cvErode &src &dst element 1 cvDilate &dst &dst element 1] 
	             [cvDilate &src &dst element 1 cvErode &dst &dst element 1]
	cvReleaseStructuringElement &&element
	cvtoRebol dst rimage1
	oct/text: n
	show oct
]

;Erode/dilate morphology operators

erodeDilate: does [
	 &src: as-pointer! src
    &dst: as-pointer! dst
	 n: (round sl2/data * max_iters * 2) - max_iters
     either n > 0 [an: n] [an: negate n]
     element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	 &&element: make struct! int-ptr! reduce [struct-address? element]  ; a double pointer
	 either n < 0 [cvErode &src &dst element 1] 
	             [cvDilate &src &dst element 1]
	 cvReleaseStructuringElement &&element
	 cvtoRebol dst rimage2 
	 edt/text: n
	 show edt
	
]

; set shape for operators 
setShape: does [
	switch flag/text [
		"Rectangle" [element_shape: CV_SHAPE_RECT]
		"Elipse"  	[element_shape: CV_SHAPE_ELLIPSE]
		"Cross" 	[element_shape: CV_SHAPE_CROSS]
	]
	if isFile [
			openClose cvtoRebol dst rimage1
			erodeDilate cvtoRebol dst rimage2
	]
]

; Self explanatory

loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			src: cvLoadImage filename CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_UNCHANGED 
			&src: as-pointer! src
			dst: cvCloneImage &src
			&dst: as-pointer! dst
			cvtoRebol src rimage1
			cvtoRebol src rimage2
			isFile: true
			sl1/data: sl2/data: .5
			show [sl1 sl2]
		]
		[Alert "Not an image" ]
	]
]



mainWin: [
at 1x1 
	button 25 "Load Image" [loadImage]
	
	flag: drop-list 45 "Rectangle" data  [ "Rectangle" "Elipse" "Cross"] [setShape]
at 245x1 
	button 25 "Quit" [if isFile [cvReleaseImage src cvReleaseImage dst] quit]
at 1x10
	panel data [
		at 0x0 
			rimage1: image 128x128 tip "Source Image"
			splitter 1x128
			rimage2: image 128x128 tip "Source Image"
	]
	at 1x150  
		field 25 "Open/Close" options [info] sl1: slider 93x5  [if isFile [openClose]] oct: field options [info] 10 "0"
		splitter 1x5
		field 25 "Erode/Dilate" options [info] sl2: slider 93x5 [if isFile [erodeDilate]] edt: field options [info] 10 "0"
]




display "OpenCV Tests: Morphology" mainWin
do-events