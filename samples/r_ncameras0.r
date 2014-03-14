#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: 4 WebCams"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]



do %../opencv.r
set 'appDir what-dir 

; generic object for webcam

camera: make object![
	; variables
	index: make integer! 0
	height: make integer! 0
	width: make integer! 0
	aled: none 
	win: make image! 320x240
	capture: 0
	image: cvCreateImage 320 240 IPL_DEPTH_8U 3
	isActive: false
	;methodes
    init: make function! [v1 v2 v3 v4 v5] [
    	index: 	v1
    	weight: v2
    	width: 	v3
    	aled:   v4
    	win: 	v5
    	aled/colors/1: red
    	aled/colors/2: orange 
    	if not isActive [
			if error? try [capture: cvCreateCameraCapture index] [quit]
			
		]
		if not none? capture [ 
				win/text: "Camera ready" isActive: true
				image: cvQueryFrame capture ; grab and retrieve image
				cvZero image
				toRebol
		]
		show [aled win]
    ]
    
	start: does [
		if isActive [
	    	win/rate: 15
	    	win/text: now/time/precise
			aled/colors/2: green 
			show [aled win]
		]
	]
	
	stop: does [
		if isActive[
	    	win/rate: none
			aled/colors/2: orange 
			cvZero image
			toRebol
			win/text: "Camera ready"
			show [aled win]
		]
	]
	
	toRebol: does [
		data: reverse get-memory image/imageData image/imageSize
		copie: make image! reduce [as-pair (image/width) (image/height) data]
		win/image: copie
		win/effect: [fit flip 1x1]
		show win
		copie: none
		recycle
	]
	
	
	showVideo: does [
		if isActive [
		cvGrabFrame capture
		frame: cvRetrieveFrame capture; 
		;cvQueryFrame capture ; grab and retrieve image
		win/text: now/time/precise
		torebol
		frame: none
		recycle
		mem/text: system/stats / (10 ** 6) show mem
		]
		
		
	]
	release: does [if not none? image [cvReleaseImage image]]
	
]


; make 4 objects

camera1: make camera []
camera2: make camera []
camera3: make camera []
camera4: make camera []


quitRequested: does [
	if confirm "Quit this program ?" [
		if camera1/isActive [camera1/release]
		if camera2/isActive [camera2/release]
		if camera3/isActive [camera3/release]
		if camera4/isActive [camera4/release]
	
	quit]

]

;crashes when we get the last cam!
countCamera: does [
    count: 0;
	until [
		cam: cvCreateCameraCapture count
		probe cam
		count: count + 1
        cam/int = 0
	]
	print count

]


mainwin: layout/size [
	across
	origin 0X0
	at 5x5 mem: info 
	at 605x5 Btn "Quit" [quitRequested]
	at 5x35  
	visu1: box 320x240 "Camera inactive"  
	with [rate: none font/shadow: none font/color: red font/align: 'left font/valign: 'bottom]
		feel [engage: func [face action event] [switch action [time [camera1/showVideo]]]
		] 
	frame blue
	at 5x280 info "Camera 1" 100 
	         btn 55 "Activate" 	[camera1/init 0 320 240 cam1 visu1]
	         btn 55 "Start"		[camera1/start]
	         btn 55 "Stop"		[camera1/stop]
			 cam1: led 20x20 green red
	at 330x35 visu2: box 320x240  "Camera inactive"
	with [rate: none font/shadow: none font/color: red font/align: 'left font/valign: 'bottom]
		feel [engage: func [face action event] [switch action [time [camera2/showVideo]]]
		] 
	frame blue
	at 330x280 info "Camera 2" 100 
	         btn 55 "Activate" 	[camera2/init 1 320 240 cam2 visu2]
	         btn 55 "Start"		[camera2/start]
	         btn 55 "Stop"		[camera2/stop]
	         cam2: led 20x20 green red
	
	at 5x320 
	visu3: box 320x240  "Camera inactive"
	with [rate: none font/shadow: none font/color: red font/align: 'left font/valign: 'bottom]
		feel [engage: func [face action event] [switch action [time [camera3/showVideo]]]
		] 
	frame blue
	at 5x565 info "Camera 3" 100 
	         btn 55 "Activate"  [camera3/init 2 320 240 cam3 visu3]
	         btn 55 "Start"		[camera3/start]
	         btn 55 "Stop"		[camera3/stop]
	         cam3: led 20x20 green red
	
	at 330x320
	visu4: box 320x240 "Camera inactive"
	with [rate: none font/shadow: none font/color: red font/align: 'left font/valign: 'bottom]
		feel [engage: func [face action event] [switch action [time [camera4/showVideo]]]
		] 
	frame blue
	at 330x565 info "Camera 4" 100 
	         btn 55 "Activate" 	[camera4/init 3 320 240 cam4 visu4]
	         btn 55 "Start"		[camera4/start]
	         btn 55 "Stop"		[camera4/stop]
	         cam4: led 20x20 green red
	         
] 660x600

center-face mainwin
view mainwin

insert-event-func [
	if all [event/type = 'close event/face = mainwin] [quitRequested] 
	event
]

do-events
