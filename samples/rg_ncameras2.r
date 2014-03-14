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


camera: make object![
	; properties
	isInitialized: make logic! false
	isActive: make logic! false
	isnotVideo: make logic! false
	isDate: make logic! false
	index: make integer! 0
	x: make integer! 0
	y: make integer! 0
	height: make integer! 0
	width: make integer! 0
	fps: make integer! 0
	windowsName: handle: make string! ""
	capture: none
	image: none
	pt1: make struct! CvPoint! [0 0]
	&font: make struct! cvFont! none
    &text_size: make struct! CvSize! reduce [0 0]
	&ymin: make struct! int-ptr! reduce [0]
	cvInitFont &font CV_FONT_HERSHEY_SIMPLEX 1.0 1.0 0 2 CV_AA
    cvGetTextSize to-string now/time &font &text_size &ymin
	;methods
	;initializes camera object
    initCamera: make function! [v1 v2 v3 v4 v5 v6 v7] [
    	index: 	v1
    	x: 		v2
    	y: 		v3
    	height: v4
    	width: 	v5
    	fps:	v6
    	isDate:	v7
    	cvStartWindowThread
    	windowsName: join "Camera " to-string index
    	handle: to-string cvGetWindowHandle windowsName 
		pt1/x: 0; (width - &text_size/width) / 2
		pt1/y: &text_size/height + &ymin/int 
		isInitialized: true	
		isActive: true
    ]
    
    
    ;initializes video driver
	activateCamera: does [
		capture: cvCreateCameraCapture index
		cvNamedWindow windowsName CV_WINDOW_AUTOSIZE
		cvResizeWindow windowsName height width
		cvMoveWindow windowsName x y
		isActive: true	
		isnotVideo: true
		
	]
	;grabs and shows frame in reference to object fps [frame/sec]
	showVideo: does [
		image: cvQueryFrame  capture ; grab and retrieve image
		if isDate [cvPutText image to-string now/time/precise pt1/x pt1/y &font 0.0 0.0 255.0 0.0]
		cvResizeWindow windowsName height width
		cvShowImage windowsName image
		isnotVideo: false
	]
	; hides video
	hideVideo: does [
		cvZero image
		cvShowImage windowsName image
		isnotVideo: true
	]
	; releases all created pointer 
	releaseVideo: does [
		isActive: false
		cvDestroyWindow handle ; cvDestroyWindow windowsName does not remove the window
		cvReleaseCapture capture
	]
] ; end of object


camera1: make camera []
camera2: make camera []
camera3: make camera []
camera4: make camera []

mem: does [
	set-text visu join now/time [" : Used memory: " round/to stats / 1024 0.1 " KB"]
	show visu
]


quitRequested: does [
	if question "Quit this program ?" [
		if camera1/isActive [camera1/releaseVideo]
		if camera2/isActive [camera2/releaseVideo]
		if camera3/isActive [camera3/releaseVideo]
		if camera4/isActive [camera4/releaseVideo]
	
	quit]

]


mainWin: [
	at 5x1 visu: field silver 145x5 
	button 25 "Quit" #"q" [quitRequested]
	at 5x7 
	panel data[
		b1: box 1x5 silver 
		;rate 0
		feel [engage: make function! [face action event] [switch action [time [ camera1/showVideo mem]]]]
		field options [info] 20 "Camera 1"  
		text "FPS" fps1: field 8 "24"
		cb1: check "TimeStamp" data true
		led1: led 
		button 20  "on"  [ if not camera1/isInitialized [camera1/initCamera 0 30 100 320 240 to-integer fps1/text cb1/data 
		  				  camera1/activateCamera] camera1/isActive: true led1/data: true show [b1 led1]] 
		button 20 "start" [ if camera1/isActive [b1/rate: to-integer fps1/text b1/color: orange show b1]]
		button 20 "pause" [if camera1/isActive [b1/rate: none b1/color: silver show b1 camera1/hideVideo]]
		button 20 "off"   [if camera1/isnotVideo [camera1/releaseVideo led1/data: none b1/rate: none show led1]]
		
		return 
		b2: box 1x5 silver 
		;rate 0
		feel [engage: make function! [face action event] [switch action [time [camera2/showVideo mem]]]]
		field options [info] 20 "Camera 2"  
		text "FPS" fps2: field 8 "24"
		cb2: check "TimeStamp" data true
		led2: led 
		button 20  "on"  [ if not camera2/isInitialized [camera2/initCamera 1 360 100 320 240 to-integer fps2/text cb2/data 
		  				  camera2/activateCamera]  camera2/isActive: true led2/data: true show [b2 led2]]
		button 20 "start" [ if camera2/isActive [b2/rate: to-integer fps2/text b2/color: orange show b2]]
		button 20 "pause" [if camera2/isActive [b2/rate: none b2/color: silver show b2 camera2/hideVideo]]
		button 20 "off"   [if camera2/isnotVideo [camera2/releaseVideo led2/data: none b2/rate: none show led2]]
		
		return
		b3: box 1x5 silver 
		;rate 0
		feel [engage: make function! [face action event] [switch action [time [camera3/showVideo mem]]]]
		field options [info] 20 "Camera 3"  
		text "FPS" fps3: field 8 "24"
		cb3: check "TimeStamp" data true
		led3: led 
		button 20  "on"  [ if not camera3/isInitialized [camera3/initCamera 2 30 370 320 240 to-integer fps3/text cb3/data 
		  				  camera3/activateCamera]  camera3/isActive: true led3/data: true show [b3 led3]]
		button 20 "start" [ if camera3/isActive [b3/rate: to-integer fps3/text b3/color: orange show b3]]
		button 20 "pause" [if camera3/isActive [b3/rate: none b3/color: silver show b3 camera3/hideVideo]]
		button 20 "off"   [if camera3/isnotVideo [camera3/releaseVideo led3/data: none b3/rate: none show led3]]
		
		return
		b4: box 1x5 silver 
		;rate 0
		feel [engage: make function! [face action event] [switch action [time [camera4/showVideo mem]]]]
		field options [info] 20 "Camera 4"  
		text "FPS" fps4: field 8 "24"
		cb4: check "TimeStamp" data true
		led4: led 
		button 20  "on"  [if not camera4/isInitialized [camera4/initCamera 3 360 370 320 240 to-integer fps4/text cb4/data 
		  				  camera4/activateCamera]  camera4/isActive: true led4/data: true show [b4 led4]]
		button 20 "start" [ if camera4/isActive [b4/rate: to-integer fps4/text b4/color: orange show b4]]
		button 20 "pause" [if camera4/isActive [b4/rate: none b4/color: silver show b4 camera4/hideVideo]]
		button 20 "off"   [if camera4/isnotVideo [camera4/releaseVideo led4/data: none b4/rate: none show led4]]
	]
]



display/close/position "OpenCV: 4 WebCams" mainWin [quitRequested] 685x100
do-events

