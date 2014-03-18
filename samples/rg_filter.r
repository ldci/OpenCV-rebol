#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"Francois Jouen"
	Rights:		"Copyright (c) 2012-2013 Francois Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;some improvements by Walid Yahia 2014 

do %../opencv.r
set 'appDir what-dir 
guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

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
		[Alert "Not an image" ]
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
   ;Sinon si c'est CV_MEDIAN, CV_GAUSSIAN ... on utilise les param par défauts.
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



MainWin: [
	at 1x1
	button 30 "Load Image" [loadImage]
	
	field 10 options [info] "Filter"
	flag: drop-list 30 "Blur No scale" data ["Blur No scale" "Blur" "Gaussian" "Median" "Bilateral"]
	sl1: slider 148x5 options[arrows] [setFilter]
	oct: field 10 "0" options [info] font [align: 'center]
	
	button 30 "Quit" [if isFile [
					cvReleaseImage src
					cvReleaseImage dst 
					free-mem src
					free-mem dst] Quit]
	at 1x8 bar 268
	at 1x10
	panel data [
		rimage1: image 128x128 
		splitter 1x128
		rimage2: image 128x128]
]



display "OpenCV Tests: Filtering" MainWin

do-events


