#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: 4 WebCams"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]



do %../opencv.r
set 'appDir what-dir 
guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"
recycle/on

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
    	aled/data: true
    	if not isActive [
			if error? try [capture: cvCreateCameraCapture index] [quit]
		]
		if not none? capture [ 
				win/rate: none
				win/text: "Camera ready" isActive: true
				image: cvQueryFrame capture ; grab and retrieve image
				cvZero image
				toRebol
		]
		show [aled win]
    ]
    
	start: does [
		if isActive [
	    	win/rate: 24
	    	win/text: now/time/precise
			aled/data: true
			show [aled win]
		]
	]
	
	stop: does [
		if isActive[
	    	win/rate: none
			aled/data: none 
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
	]
	
	
	showVideo: does [
		if isActive [
		cvGrabFrame capture
		image: cvRetrieveFrame capture; 
		;cvQueryFrame capture ; grab and retrieve image
		win/text: now/time/precise
		torebol
		set-text mem join "Used memory " system/stats / (10 ** 6)
		]
		;recycle
	]
	release: does [if not none? image [cvReleaseImage image]]
	
]


; make 4 objects

camera1: make camera []
camera2: make camera []
camera3: make camera []
camera4: make camera []


quitRequested: does [
	if question "Quit this program ?" [
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



mainWin: [
	at 5x0 mem: field 128
	at 135x0 button "Quit" [quitRequested]
	
	at 1x7 
	panel data [
		visu1: image black 64x48  "Camera inactive"  
		rate 0
		font [color: green valign: 'bottom]
		feel [engage: make function! [face action event] [switch action [time [camera1/showVideo]]]]
		return
		field 17 "Camera 1"
		button 13 "Activate" 	[camera1/init 0 320 240 cam1 visu1]
		button 11 "Start"		[camera1/start]
		button 11 "Stop"		[camera1/stop]
		cam1: led
	]	
	
	panel data [
		visu2: image black 64x48 "Camera inactive"  
		rate 0
		font [color: green valign: 'bottom]
		feel [engage: make function! [face action event] [switch action [time [camera2/showVideo]]]]
		return
		field 17 "Camera 2"		
		button 13 "Activate"	[camera2/init 1 320 240 cam2 visu2]
		button 11 "Start"		[camera2/start]
		button 11 "Stop"		[camera2/stop]
		cam2: led
	]	
	return
	
	panel data [
		visu3: image black 64x48 "Camera inactive"  
		rate 0
		font [color: green valign: 'bottom]
		feel [engage: make function! [face action event] [switch action [time [camera3/showVideo]]]]
		return
		field 17 "Camera 3"
		button 13 "Activate"	[camera3/init 2 320 240 cam3 visu3]
		button 11 "Start"		[camera3/start]
		button 11 "Stop"		[camera3/stop]
		cam3: led
	]	
	
	panel data [
		visu4: image black 64x48 "Camera inactive"  
		rate 0
		font [color: green valign: 'bottom]
		feel [engage: make function! [face action event] [switch action [time [camera4/showVideo]]]]
		return
		field 17 "Camera 4"
		button 13 "Activate"	[camera4/init 3 320 240 cam4 visu4]
		button 11 "Start"		[camera4/start]
		button 11 "Stop"		[camera4/stop]
		cam4: led
	]			
]



display/close "OpenCV: 4 WebCams" mainWin [quitRequested]
do-events
