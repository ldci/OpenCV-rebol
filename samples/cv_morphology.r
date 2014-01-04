#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 
filename: to-string to-local-file join appDir"images/baboon.jpg"
element_shape: CV_SHAPE_RECT;
max_iters: 10;
openClosePos: erodeDilatePos: max_iters 



;the address of variable which receives trackbar position update
; we need this structure 
&openClosePos: make struct! int-ptr! reduce [openClosePos]
&erodeDilatePos: make struct! int-ptr! reduce [erodeDilatePos]





n: 0
;callback function for open/close trackbar

OpenClose: func [pos][
	n: &openClosePos/int - max_iters
	either n > 0 [an: n] [an: negate n]
	element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	&&element: make struct! int-ptr! reduce [struct-address? element] ; a double pointer
	either n < 0 [cvErode src dst element 1 cvDilate dst dst element 1] 
	             [cvDilate src dst element 1 cvErode dst dst element 1]
	
	cvReleaseStructuringElement &&element
	cvShowImage "Open/Close" dst
]

;callback function for erase/dilate trackbar
ErodeDilate: func [pos][
	n: &erodeDilatePos/int - max_iters
	either n > 0 [an: n] [an: negate n]
	element: cvCreateStructuringElementEx (an * 2) + 1 (an * 2) + 1 an an element_shape 0 
	&&element: make struct! int-ptr! reduce [struct-address? element]  ; a double pointer
	either n < 0 [cvErode src dst element 1] 
	             [cvDilate src dst element 1]
	cvReleaseStructuringElement &&element
    cvShowImage "Erode/Dilate" dst
]


helpF: does [
	print newline
	print form {
	This program demonstrated the use of the morphology operator, especially open, close, erode, dilate operations
    Morphology operators are built on max (close) and min (open) operators as measured by pixels covered by small structuring elements.
	These operators are very efficient.
    This program also allows you to play with elliptical, rectangluar and cross structure elements
    Hot keys
    tESC - quit the program
    tr - use rectangle structuring element
    te - use elliptic structuring element
    tc - use cross-shaped structuring element
    tSPACE - loop through all the options}
]


src: cvLoadImage filename CV_LOAD_IMAGE_UNCHANGED 
dst: cvCloneImage src

&&src: make struct! int-ptr! reduce [struct-address? src] 
&&dst: make struct! int-ptr! reduce [struct-address? dst] 

;create windows for output images
cvNamedWindow "Open/Close" CV_WINDOW_AUTOSIZE
cvNamedWindow "Erode/Dilate" CV_WINDOW_AUTOSIZE
cvMoveWindow "Erode/Dilate" 630 100

; trackbars

cvCreateTrackbar  "iterations" "Open/Close" &openClosePos max_iters * 2 + 1 :OpenClose 
cvCreateTrackbar "iterations" "Erode/Dilate" &erodeDilatePos max_iters * 2 + 1 :ErodeDilate

cvShowImage "Open/Close" dst
cvShowImage "Erode/Dilate" dst

helpF

c: 0
until [
		OpenClose &openClosePos
		ErodeDilate &erodeDilatePos 
        if c = 101 [element_shape: CV_SHAPE_ELLIPSE] ; e
		if c = 114 [element_shape: CV_SHAPE_RECT] ; r
		if c = 32 [element_shape: modulo element_shape + 1 3]; space
		c: cvWaitKey 1
		c = 27 
]

free-mem &openClosePos	;release trackbar pointer
free-mem  &erodeDilatePos	;release trackbar pointer
cvReleaseImage &&src 		;release image pointer
cvReleaseImage &&dst 		;release image pointer
    

