#! /usr/bin/rebol
REBOL [
	title: "Load Images with OpenCV "
]
do %../opencv.r
set 'appDir what-dir 


set 'appDir what-dir 

guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"


isImage: false
iscolor: CV_LOAD_IMAGE_UNCHANGED
isTest: false ; use true for testing copy function

bloc: copy []


cvImage: make object![
	;variables
	x: make integer! 0
	y: make integer! 0
	windowsName: make string! ""
	img: none
	
	;methodes
    init: make function! [v1 v2 v3] [
    	x: 		v1
    	y: 		v2
    	windowsName: v3
    ]
    cvload: func [color] [
    	img: cvLoadImage windowsName color 
    	&img: as-byte-ptr! img
    	; we use a copie to test cvGetRawData
    	
    	if isTest [
			copie: cvCreateImage img/width img/height img/depth img/nChannels ;IPL_DEPTH_8U 1;
			&copie: as-byte-ptr! 
			cvZero &copie
	    	&step as-int-ptr! img/widthStep
	    	&data: as-int-ptr! img/imageSize
	    	roi: make struct! cvSize! reduce [0 0]
			cvGetRawData &img &data &step roi
	    	data: get-memory  &data img/imageSize		;get the data
			set-memory copie/imageData data]	
	]
    
    cvShow: does [
    	cvNamedWindow windowsName CV_WINDOW_AUTOSIZE
    	cvResizeWindow windowsName 512 512
    	cvMoveWindow windowsName x y
    	cvShowImage windowsName &img
    	if isTest [
    		cvNamedWindow "copie" CV_WINDOW_AUTOSIZE
    		cvShowImage "copie" &copie
    	]
    ]
    
    
    
    cvInfo: func [console] [
        str: copy third img ; values changed by routines are here
        str: skip str 48 ; looking for an eventual modification of roi address
        ptr: to-integer reverse copy/part str 4
        ;Roi exists
        if ptr <> 0 [roiValues: get-memory to-integer p 20
        	coi: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	xOffset: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	yOffset: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	width: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	height: to-integer copy/part roiValues 4
        ]
        ; No Roi 
        if ptr = 0 [
            img/roi: none
        	coi: 0
        	xOffset: 0
        	yOffset: 0
        	width: img/width 
        	height: img/height 
        
        ]
        ;  Image/tileInfo changed? 
        str: skip str 8
        ptr: to-integer reverse copy/part str 4
        tileInfo: ptr 
      	if tileInfo = 0 [img/tileInfo: none ]
      	if tileInfo <> 0 [
      		iplCallback: none
      		id: none
      		tileData: none
      		width: 0
      		height: 0
      	]
      	
        
    	console/text: ""
		console/text:  rejoin [ "image size: " img/nSize newline]
		append console/text rejoin [ "image ID: " img/ID newline]
		append console/text rejoin [ "image nChannels: " img/nChannels newline]
		append console/text rejoin [ "image alphaChannel: " img/alphaChannel newline]
		append console/text rejoin [ "image depth: " img/depth newline]
		append console/text rejoin [ "image color model: " img/cm0 img/cm1 img/cm2 img/cm3 newline] ; img/ColorModel Ignored by OpenCV
		append console/text rejoin [ "image channel Seq: " img/cs0 img/cs1 img/cs2 img/cs3 newline] ; img/channelSeq Ignored by OpenCV 
		append console/text rejoin [ "image data order: " img/dataOrder newline]
		append console/text rejoin [ "image origin: " img/origin newline]
		append console/text rejoin [ "image align: " img/align newline]
		append console/text rejoin [ "image width: " img/width newline]
		append console/text rejoin [ "image height: " img/height newline]
		append console/text rejoin [ "image roi: "  img/roi newline]
		append console/text rejoin [ "image ROI/coi: "    coi newline]
		append console/text rejoin [ "image ROI/xOffset: "    xOffset newline]
		append console/text rejoin [ "image ROI/yOffset: "    yOffset newline]
		append console/text rejoin [ "image ROI/width: "    width newline]
		append console/text rejoin [ "image ROI/height: "    height newline]
		append console/text rejoin [ "image mask ROI: " img/maskROI newline]
		append console/text rejoin [ "image imageID: " img/imageID newline]
		append console/text rejoin [ "image tileInfo: " img/tileInfo newline]
		append console/text rejoin [ "image size: " img/imageSize newline]
		append console/text rejoin [ "image data: " img/imageData newline]
		append console/text rejoin [ "image widthStep: " img/widthStep newline]
		append console/text rejoin [ "image borderMode: "  img/bm0 img/bm1 img/bm2 img/bm3 newline] ;img/borderMode Ignored by OpenCV" 
		append console/text rejoin [ "image borderConst: " img/bc0  img/bc1 img/bc2 img/bc3 newline] ;img/borderConstIgnored by OpenCV" 
		append console/text rejoin [ "image imageDataOrigin: " img/imageDataOrigin newline]
		show console
    ]
    
    cvtoRebol: func [dest] [
       t1: now/time/precise
        data: get-memory img/imageData img/imageSize  
       
        cimg: make image! as-pair  (img/width) (img/height) 
        ; cv grayscale image must be converted to rgb rebol image
        if img/nChannels = 1 [
        	bit8: make binary! 0
            foreach v data [ insert/dup bit8 to-char v 3] ; create 3 bytes for 1 channel cvImage
            data: reverse bit8 
        ]  
        cimg/rgb: reverse data ; 3 bytes for rgb 
      	cimg/alpha: 0 ; append byte for transparence in rebol; perfect too if &img/nChannels = 4
        dest/image: copy cimg
        dest/effect: [fit flip 1x1] ; rgb data order
		show dest
		t2: now/time/precise
		sb/text: join "Conversion done in " [round/to t2 - t1 0.001 " sec"]
	show sb
    ]  
]



loadImage: does [
    cvDestroyAllWindows
	temp: request-file 
	if not none? temp [
		fl: flash "Converting cvImage to Rebol image"
		wait 0.1
		ima: make cvImage []
		ima/init 300 300 to-string to-local-file to-string temp
		ima/cvLoad iscolor
		ima/cvShow
		ima/cvInfo console
		rimage/image: load ""
		show rimage
		
		
		ima/cvtoRebol rimage
		unview/only fl
		]
]


setColor: does [
	switch flag/text [
		"As is" [iscolor: CV_LOAD_IMAGE_UNCHANGED]
		"3-channel color"  [iscolor: CV_LOAD_IMAGE_COLOR]
		"Grayscale" [iscolor: CV_LOAD_IMAGE_GRAYSCALE]
	]
]

	
mainWin: [
	at 1x1 
	button 25 "Load Image" [loadImage]
	flag: drop-list 30 "As is" data [ "As is" "3-channel color" "Grayscale"] [setColor]
	button 25 "Quit" [quit]
	at 1x10 
	console: area 75x128 options []
	rimage: image 128x128 black
	return
	sb: field options [info] 206
]



display "Load Images with OpenCV" mainWin
do-events 
