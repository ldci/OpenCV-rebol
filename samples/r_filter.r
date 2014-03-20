#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
;some improvements by Walid Yahia 2014 

do %../opencv.r

isFile: false
filter: CV_BLUR
max_iters: 255
pos: 0.0 


; Self explanatory

loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			src: cvLoadImage filename CV_LOAD_IMAGE_COLOR ;CV_LOAD_IMAGE_UNCHANGED 
			&src: as-pointer! src
			dst: cvCloneImage &src
			&dst: as-pointer! dst
			cvtoRebol src rimage1 
			cvtoRebol dst rimage2
			isFile: true
			sl1/data: 0
			show [sl1]
		]
		[Alert "Problem in reading image" ]
	]
]

setFilter:  does [
	switch flag/text [
		"Blur No scale" [filter: CV_BLUR_NO_SCALE]
		"Blur" 			[filter: CV_BLUR]
		"Gaussian"  	[filter: CV_GAUSSIAN]
		"Median" 		[filter: CV_MEDIAN]
		"Bilateral"		[filter: CV_BILATERAL]
	]
	if isFile [trackEvent]
]

trackEvent: does [  
   pos: round (sl1/data * max_iters)
   if odd? pos [
   ;Si on choisit CV_BILATERAL alors on utilise cvSmooth avec parametres pos = sigma1 et sigma2
   ;Sinon si c'est CV_MEDIAN, CV_GAUSSIAN ... on utilise les param par dÈfauts.
		either (filter = CV_BILATERAL) 
					[cvSmooth &src &dst CV_BILATERAL 10 10 pos pos]
					[cvSmooth &src &dst filter pos 0 0 0]		
		]	
	cvtoRebol dst rimage2	
	oct/text: pos
	show oct
]
release: does [
	cvReleaseImage &src
	cvReleaseImage &dst
]


mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Image" [loadImage]
	txt 50 "Filter" 
	flag: choice black 100 data [ "Blur No scale" "Blur" "Gaussian" "Median" "Bilateral"] [setFilter]
	sl1: slider 202x25 [if isFile [trackEvent]] 
	
	
	oct: info 40 "0" 
	at 935x5 btn 100 "Quit" [if isFile [release] quit]
	space 0x0
    at 5x30 rimage1: image 512x512 frame blue
	at 525x30 rimage2: image 512x512 frame blue
	
	] 1045x560



sl1/data: pos
center-face mainwin
view mainwin
