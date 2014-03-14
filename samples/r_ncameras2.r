#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV: 4 WebCams"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r

camera: make object![
	; properties
	isInitialized: make logic! false
	isActive: make logic! false
	isDate: make logic! false
	isnotVideo: make logic! false
	index: make integer! 0
	x: make integer! 0
	y: make integer! 0
	height: make integer! 0
	width: make integer! 0
	fps: make integer! 0
	windowsName: make string! ""
	capture: none
	image: none
	pt1: make struct! CvPoint! [0 0]
	&font: make struct! cvFont! none
    &text_size: make struct! CvSize! reduce [0 0]
	&ymin: make struct! int-ptr! reduce [0]
	
	cvInitFont &font CV_FONT_HERSHEY_SIMPLEX 1.0 1.0 0 2 CV_AA
    cvGetTextSize to-string now/time &font &text_size &ymin
	;methods
	;initialize camera object
    initCamera: make function! [v1 v2 v3 v4 v5 v6 v7] [
    	index: 	v1
    	x: 		v2
    	y: 		v3
    	height: v4
    	width: 	v5
    	fps:	v6
    	isDate:	v7
    	windowsName: join "Camera " to-string index
		pt1/x: 0; (width - &text_size/width) / 2
		pt1/y: &text_size/height + &ymin/int 
		cvStartWindowThread
		handle: to-string cvGetWindowHandle windowsName 
		isInitialized: true	
		isActive: true	
    ]
    
    
    ;initialize video driver
	activateCamera: does [
		capture: cvCreateCameraCapture index
		cvNamedWindow windowsName CV_WINDOW_AUTOSIZE
		cvResizeWindow windowsName height width
		cvMoveWindow windowsName x y
		isActive: true	
		isnotVideo: true
		
	]
	;grab and show frame in reference to object fps [frame/sec]
	showVideo: does [
		image: cvQueryFrame  capture ; grab and retrieve image
		if isDate [cvPutText image to-string now/time/precise pt1/x pt1/y &font 0.0 0.0 255.0 0.0]
		cvResizeWindow windowsName height width
		cvShowImage windowsName image
		isnotVideo: false
	]
	; hide video
	hideVideo: does [
		cvZero image
		cvShowImage windowsName image
		isnotVideo: true
	]
	; release all created pointer 
	releaseVideo: does [
		isActive: false
		cvDestroyWindow handle ; windowsName does not close the window
		windowsName: make string! ""
		cvReleaseCapture capture
	]
] ; end of object


camera1: make camera []
camera2: make camera []
camera3: make camera []
camera4: make camera []

mem: does [
	visu/text: join now/time [" : Used memory: " round/to stats / 1024 0.1 " KB"]
	show visu
]


mainwin: layout/size [
	across
	origin 0X0
	at 20x5 visu: box silver 430x25 
	btn 125 "Quit" #"q" [Quit]
	
	at 5x45 
	    b1: box 8x24 silver with [rate: none]
		feel [engage: func [face action event]
	     [switch action [time [camera1/showVideo mem]]]
	    ]
		info 80 "Camera 1"  
		text "FPS" fps1: field 35 "24"
		txt "TimeStamp" cb1: check 20x20 true
		led1: led 10x20
		btn 60  "on"  
			[if not camera1/isInitialized [
				camera1/initCamera 0 100 100 320 240 to-integer fps1/text cb1/data 
		  		camera1/activateCamera]
		  	camera1/isActive: true	
		  	led1/colors/2: green 
		    show [b1 led1]
		]
		btn 60 "start" [if camera1/isActive [b1/rate: to-integer fps1/text  b1/color: orange show b1]]
		btn 60 "pause" [if camera1/isActive [b1/rate: none b1/color: silver show b1 camera1/hideVideo]]
		btn 60 "off"   [if camera1/isnotVideo [camera1/releaseVideo led1/colors/2: red b1/rate: none show [b1 led1]]]
	
	
	at 5x75 
		b2: box 8x24 silver with [rate: none]
		feel [engage: func [face action event]
	     [switch action [time [camera2/showVideo mem]]]
	    ] 
		info 80 "Camera 2" 
		text "FPS" fps2: field 35 "24"
		txt "TimeStamp" cb2: check 20x20 true
		led2: led 10x20
		btn 60  "on"
		    [if not camera2/isInitialized [
		    	camera2/initCamera 1 430 100 320 240 to-integer fps2/text cb2/data 
		  		camera2/activateCamera]
		  	camera2/isActive: true	
		  	led2/colors/2: green
		    show [b2 led2]
		]
		btn 60 "start" [if camera2/isActive [b2/rate: to-integer fps2/text b2/color: orange show b2]]
		btn 60 "pause" [if camera2/isActive [b2/rate: none b2/color: silver show b2 camera2/hideVideo]]
		btn 60 "off"   [if camera2/isnotVideo [camera2/releaseVideo led2/colors/2: red b2/rate: none show [b2 led2]]]
	
	at 5x105 
		b3: box 8x24 silver with [rate: none]
		feel [engage: func [face action event]
	     [switch action [time [camera3/showVideo mem]]]
	    ] 
		info 80 "Camera 3"  
		text "FPS" fps3: field 35 "24"
		txt "TimeStamp" cb3: check 20x20
		led3: led 10x20
		tog 60  "on" "off"
		[if not camera3/isInitialized 
			[camera3/initCamera 2 100 370 320 240 to-integer fps3/text cb3/data 
		  	camera3/activateCamera]
		  	camera3/isActive: true
		  	led3/colors/2: green 
		    show [b3 led3]
		]  
		btn 60 "start" [if camera3/isActive [b3/rate: to-integer fps3/text b3/color: orange show b3]]
		btn 60 "pause" [if camera3/isActive [b3/rate: none b3/color: silver show b3 camera3/hideVideo]]
		btn 60 "off"   [if camera3/isnotVideo [camera3/releaseVideo led3/colors/2: red b3/rate: none show [b3 led3]]]
	
		
	at 5x135
		b4: box 8x24 silver with [rate: none]
		feel [engage: func [face action event]
	     [switch action [time [camera4/showVideo mem]]]
	    ] 
		info 80 "Camera 4"  
		text "FPS" fps4: field 35 "24"
		txt "TimeStamp" cb4: check 20x20
		led4: led 10x20
		btn 60  "on"
		  	[if not camera2/isInitialized [camera4/initCamera 3 430 370 320 240 to-integer fps4/text cb4/data 
		  	camera4/activateCamera]
		  	camera4/isActive: true
		  	led4/colors/2: green 
		    show [b4 led4]
		]
		btn 60 "start" [if camera4/isActive [b4/rate: to-integer fps4/text b4/color: orange show b4]]
		btn 60 "pause" [if camera4/isActive [b4/rate: none b4/color: silver show b4 camera4/hideVideo]]
		btn 60 "off"   [if camera4/isnotVideo [camera4/releaseVideo led4/colors/2: red b4/rate: none show [b4 led4]]]
	
	
] 595x185

view/offset mainwin 800X100


