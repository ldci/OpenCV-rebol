#! /usr/bin/rebol
REBOL [
	title: "4 Cameras with Rebol"
]
do %../opencv.r
camOn: false

camera: make object![
	; properties
	isActive: make logic! false
	isDate: make logic! false
	index: make integer! 0
	x: make integer! 0
	y: make integer! 0
	height: make integer! 0
	width: make integer! 0
	windowsName: make string! ""
	capture: none
	image: none
	pt1: make struct! CvPoint! [0 0]
	&font: make struct! cvFont! none
    &text_size: make struct! CvSize! reduce [0 0]
	&ymin: make struct! int-ptr! reduce [0]
	
	;methods
	;initializes camera object
    initCamera: make function! [v1 v2 v3 v4 v5 v6] [
    	index: 	v1
    	x: 		v2
    	y: 		v3
    	height: v4
    	width: 	v5
    	isDate:	v6
    	windowsName: join "Camera " to-string index
    	cvInitFont &font CV_FONT_HERSHEY_SIMPLEX 1.0 1.0 0 2 CV_AA
    	cvGetTextSize to-string now/time &font &text_size &ymin
		pt1/x: 0; (width - &text_size/width) / 2
		pt1/y: &text_size/height + &ymin/int 	
    ]
    
    
    ;initializes video driver
	activateCamera: does [
		&capture: as-pointer! cvCreateCameraCapture index
		cvNamedWindow windowsName CV_WINDOW_AUTOSIZE
		cvResizeWindow windowsName height width
		cvMoveWindow windowsName x y
		isActive: true	
	]
	;grabs and shows frame in reference to object fps [frame/sec]
	showVideo: does [
		image: cvQueryFrame  &capture ; grab and retrieve image
		&image: as-pointer! image
		if isDate [cvPutText &image to-string now/time/precise pt1/x pt1/y &font 0.0 0.0 255.0 0.0]
		cvResizeWindow windowsName height width
		cvShowImage windowsName &image
	]
	; hides video
	hideVideo: does [
		cvZero &image
		cvShowImage windowsName &image
	]
	; releases all created pointer 
	releaseVideo: does [
		isActive: false
		cvDestroyWindow windowsName
		cvReleaseCapture &capture
	]
] ; end of object


stopVideo: does [
	visu/rate: none show visu
	if camera1/isActive [camera1/hideVideo]
	if camera2/isActive [camera2/hideVideo]
	if camera3/isActive [camera3/hideVideo]
	if camera4/isActive [camera4/hideVideo]
]

showVideo: does [ 
	visu/text: join now/time [" : Used memory: " round/to stats / 1024 0.1 " KB"]
	show visu
	if camera1/isActive [camera1/showVideo] 
	if camera2/isActive [camera2/showVideo] 
	if camera3/isActive [camera3/showVideo] 
	if camera4/isActive [camera4/showVideo] 
	;ret: cvWaitKey 1
	;if (ret = 112) [stopVideo] ; p key
]

quitVideo: does [
	if camera1/isActive [camera1/releaseVideo]
	if camera2/isActive [camera2/releaseVideo]
	if camera3/isActive [camera3/releaseVideo]
	if camera4/isActive [camera4/releaseVideo]
]


camera1: make camera []
camera1/initCamera 0 100 100 640 480 true;

camera2: make camera []
camera2/initCamera 1 200 200 640 480 true;

camera3: make camera []
camera3/initCamera 2 300 300 320 240 true;

camera4: make camera []
camera4/initCamera 3 400 400 320 240 true;

mainwin: layout/size [
	across
	origin 0X0
	at 5x5 
	text "Camera 1 " cb1: check 
	text "Camera 2 " cb2: check 
	text "Camera 3 " cb3: check 
	text "Camera 4 " cb4: check 
	btn  100 #"a" "Activate" [
			visu/color: orange
			if not camera1/isActive [if cb1/data = true [camera1/activateCamera]] 
			if not camera2/isActive [if cb2/data = true [camera2/activateCamera]] 
			if not camera3/isActive [if cb3/data = true [camera3/activateCamera]] 
			if not camera4/isActive [if cb4/data = true [camera4/activateCamera]]
			if any [camera1/isActive camera2/isActive camera3/isActive camera4/isActive]
			[visu/text: "Cameras on" camOn: true show visu]
	]
	btn 70 "Start" #"s" [if camOn [visu/color: green visu/rate: 24 show visu]]
	btn 70 "Pause" #"p" [if camOn [visu/color: orange stopVideo]]
	btn 70 "Quit" #"q" [Quit]
	
	at 5x30 visu: box silver 740x50 "Cameras off"
		with [rate: none]
		feel [engage: func [face action event]
	     [switch action [time [showVideo]]]
	    ] 
	
] 755x100

center-face mainwin
view mainwin


