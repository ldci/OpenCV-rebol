#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Reading Video Files"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;some improvements by Walid Yahia 2014 

do %../opencv.r
set 'appDir what-dir 
isFile: false



loadImage: does [
	isFile: false
	nbFrames: position: 0
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
			capture: cvCreateFileCapture filename
			&capture: struct-address? capture
			isFile: true
			sl1/data: 0.0
			m1/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_WIDTH
		    m2/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_HEIGHT
		    m3/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_COUNT
		    m4/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FPS
		    nbFrames: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_COUNT
		   if error? try [step: 1 / nbFrames] [step: 0.01]
			show [sl1 m1 m2 m3 m4]
			showMovie
	]
]

gotoFrame: 
func [pos][
;Definition de CV_CAP_PROP_POS_AVI_RATIO =1 sinon =2 erreur
CV_CAP_PROP_POS_AVI_RATIO: 1
	switch pos [
		"first" [current: 0.0]
		"last" [current: to-decimal (round(1.0 - (step * 2.0)))] ; 0.985should be 1.0 in fact 1.0 - step -> arrondir à 1.0
		"next" [current: position * step ]
		"previous" [current: (position - 2) * step] 
	]
	cvSetCaptureProperty capture CV_CAP_PROP_POS_AVI_RATIO current 
	showMovie
]

showPosition: does [
	position: to-integer cvGetCaptureProperty capture CV_CAP_PROP_POS_FRAMES
	m5/text: position
	ratio: round/to cvGetCaptureProperty capture CV_CAP_PROP_POS_AVI_RATIO 0.001
	m6/text: to-string ratio
  	m7/text: join to-integer cvGetCaptureProperty capture CV_CAP_PROP_POS_MSEC " ms"
  	sl1/data: ratio
	show [m5 m6  m7 sl1]
]

showMovie: does [
	if isFile [
		;CvGrabFrame
		image: cvQueryFrame capture
		&&image: make struct! int-ptr! reduce [struct-address? image ]	
		; PROBLEME cvGrabFrame & cvRetrieveFrame
		cvtoRebol/fit image rimage
		show rimage
		showPosition
		]
]

mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Movie" [loadImage]
	text 50 "Height" m1: info 100
	text 50 "Width" m2: info 100
	text 50 "Frames " m3: info 100
	text 50 "fps" m4: info 100
	;ajout en plus de cvReleaseImage, cvGetWindowHandle (erreur lorsqu'on utilise que cette fct)
	at 925x5 btn 100 "Quit" [ if isFile [cvReleaseImage &&image free-mem image] quit]
	space 0x0
    at 5x30 rimage: image 1024x512 
    with [rate: none]
		feel [engage: func [face action event] [switch action[time[showMovie]]]
	]
    frame blue
	
	at 5x545
	b1: btn "<<" 	[if isFile [gotoFrame "first"]]
	b2: btn "< "	[if isFile [gotoFrame "previous"]]
	b3: btn "Start" [rimage/rate: 24 show rimage]
	b4: btn "Stop"  [rimage/rate: none show rimage]
	b5: btn "> " 	[if isFile [gotoFrame "next"]]
	b6: btn ">>"	[if isFile [gotoFrame "last"]]
	
	txt 100 "Frame" sl1: progress 375x20 [if isFile []] m5: info 100 "0" m6: info 100 m7: info 100

	] 1045x580

sl1/data: 0.0 
center-face mainwin
view mainwin