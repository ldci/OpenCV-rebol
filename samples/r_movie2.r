#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Reading Video Files"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012-2013 Franois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
isFile: false



loadImage: does [
	isFile: false
	nbFrames: position: 0
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		;if error? try [
			capture: cvCreateFileCapture filename
			&capture: struct-address? capture 
			isFile: true
			sl1/data: 0.0
			m1/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_WIDTH
		    m2/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_HEIGHT
		    m3/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_COUNT
		    m4/text: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FPS
		    nbFrames: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_COUNT
		    step: 1 / nbFrames
			show [sl1 m1 m2 m3 m4]
			numberOfVDImages: to-integer cvGetCaptureProperty capture CV_CAP_PROP_FRAME_COUNT
			ratioVD: 1 / numberOfVDImages
			getFrame "first"
		;]
		;[Alert "Not a movie" ]
	]
	
]



getFrame: func [pos][
	if isFile [
		switch pos [
			"image" [position: to-integer sl1/data * numberOfVDImages  if (sl1/data = 1.0) [ position: numberOfVDImages current: 1 - (ratioVD * 2) ] current: position * ratioVD ]
			"first" [position: 1 current: 0.0 + ratioVD  ] ;should be 10.0 in fact 0.0 + ratioVD
			"last" [position: numberOfVDImages current: 1 - (ratioVD * 2)] ;should be 1.0 in fact 1.0 - ratioVD
			"next" [position: position + 1 if position >= (numberOfVDImages) [position: numberOfVDImages]  current: ratioVD * position ]
			"previous" [ position: position - 1 if position <= 1 [position: 1] current: ratioVD * position]
		]
		cvSetCaptureProperty capture CV_CAP_PROP_POS_AVI_RATIO current ; le ratio
		image: cvQueryFrame capture
		&&image: make struct! int-ptr! reduce [struct-address? image ]	
		cvtoRebol/fit image rimage
		show rimage
		showPosition
	]
	
]




showPosition: does [
	;position: to-integer cvGetCaptureProperty capture CV_CAP_PROP_POS_FRAMES
	m5/text: position
	ratio: round/to cvGetCaptureProperty capture CV_CAP_PROP_POS_AVI_RATIO 0.001
	m6/text: to-string ratio
  	m7/text: join to-integer cvGetCaptureProperty capture CV_CAP_PROP_POS_MSEC " ms"
  	sl1/data: ratio
	show [m5 m6  m7 sl1]

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
	
	at 925x5 btn 100 "Quit" [ if isFile [cvReleaseImage &&image] quit]
	space 0x0
    at 5x30 rimage: image 640x480 ; 1024x512 
    with [rate: none]
		feel [engage: func [face action event] [switch action [time [getFrame "next"]]]
	] 
    frame blue
	
	at 5x545
	b1: btn "<<" 	[if isFile [getFrame "first"]]
	b2: btn "< "	[if isFile [getFrame "previous"]]
	b3: btn "Start" [rimage/rate: 24 show rimage]
	b4: btn "Stop"  [rimage/rate: none show rimage]
	b5: btn "> " 	[if isFile [getFrame "next"]]
	b6: btn ">>"	[if isFile [getFrame "last"]]
	
	txt 100 "Frame" sl1: slider 375x20 [if isFile [getFrame "image"]] m5: info 100 "0" m6: info 100 m7: info 100

	] 1045x580

sl1/data: 0.0 
center-face mainwin
view mainwin