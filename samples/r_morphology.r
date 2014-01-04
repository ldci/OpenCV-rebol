#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Morphology"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 

; default 
filename: to-string to-local-file join appDir"images/baboon.jpg"


max_iters: 10;
element_shape: CV_SHAPE_RECT;
isFile: false


;Open/close morphology operators

openClose: does [
    n: (round sl1/data * max_iters * 2) - max_iters
    either n > 0 [an: n] [an: negate n]
    element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	&&element: make struct! int-ptr! reduce [struct-address? element]  ; a double pointer
	either n < 0 [cvErode src dst element 1 cvDilate dst dst element 1] 
	             [cvDilate src dst element 1 cvErode dst dst element 1]
	cvReleaseStructuringElement &&element
	either cb/data [cvtoRebol/fit dst rimage1] [cvtoRebol dst rimage1] 
	oct/text: n
	show oct
]

;Erode/dilate morphology operators

erodeDilate: does [
	 n: (round sl2/data * max_iters * 2) - max_iters
     either n > 0 [an: n] [an: negate n]
     element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	 &&element: make struct! int-ptr! reduce [struct-address? element]  ; a double pointer
	 either n < 0 [cvErode src dst element 1] 
	             [cvDilate src dst element 1]
	 cvReleaseStructuringElement &&element
	 either cb/data [cvtoRebol/fit dst rimage2] [cvtoRebol dst rimage2] 
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
			openClose either cb/data [cvtoRebol/fit dst rimage1] [cvtoRebol dst rimage1]
			erodeDilate either cb/data [cvtoRebol/fit dst rimage2] [cvtoRebol dst rimage2]
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
			&&src: make struct! int-ptr! reduce [struct-address? src] 
			dst: cvCloneImage src
			&&dst: make struct! int-ptr! reduce [struct-address? dst] 
			either cb/data [cvtoRebol/fit src rimage1] [cvtoRebol src rimage1] 
			either cb/data [cvtoRebol/fit src rimage2] [cvtoRebol src rimage2]
			isFile: true
			sl1/data: sl2/data: .5
			show [sl1 sl2]
		]
		[Alert "Not an image" ]
	]
]


mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Image" [loadImage]
	txt 50 "Shape" 
	flag: choice 150 data [ "Rectangle" "Elipse" "Cross"] [setShape]
	txt "Fits Image" cb: check 20x20 true
	at 935x5 btn 100 "Quit" [if isFile [cvReleaseImage &&src cvReleaseImage &&dst] quit]
	space 0x0
    at 5x30 rimage1: image 512x512 frame blue
	at 525x30 rimage2: image 512x512 frame blue
	at 5x545 txt 100 "Open/Close" sl1: slider 362x25 [if isFile [openClose]] oct: info 50 "0"
	at 525x545 txt 100 "Erode/Dilate" sl2: slider 362x25 [if isFile [erodeDilate]] edt: info 50 "0"
	] 1045x580

sl1/data: sl2/data: .5
center-face mainwin
view mainwin
