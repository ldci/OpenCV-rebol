#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Hough Circles"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 
isFile: false


dp: 36.0 ; image resolution
minDist: 25.0
param1: 50.0 ; default 100 ; for canny detector
param2: 100.0 ; default 100 ; for canny detector
minRadius: 10
maxRadius: 200
maxSize: 512
w: h: 0
lowThresh: 0
highThresh: 0
edge_thresh: 10
threshold: 50
threshold_max: 512

loadImage: does [
    
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			picture: cvLoadImage filename  CV_LOAD_IMAGE_COLOR
			w: picture/width 
			h: picture/height 
			
			greyImg: cvCreateImage w h IPL_DEPTH_8U 1
			cannyImg: cvCreateImage w h IPL_DEPTH_8U 1
			drawnImg: cvCreateImage w h IPL_DEPTH_8U 3
			contrastImg: cvCreateImage w h IPL_DEPTH_8U 1
			storage: cvCreateMemStorage 0
    		
			cvNamedWindow "Canny" CV_WINDOW_AUTOSIZE
			cvNamedWindow "Threshold" CV_WINDOW_AUTOSIZE
			cvNamedWindow "Image" CV_WINDOW_AUTOSIZE
	
			cvEqualizeHist greyImg greyImg
			cvCvtColor picture greyImg CV_BGR2GRAY
			
			cvCopy picture drawnImg none
			
			cvMoveWindow "Canny" 100  picture/height + 100
			cvMoveWindow "Threshold" 300  picture/height + 100
			cvShowImage "Threshold" contrastImg
			cvShowImage "Canny" cannyImg
			cvShowImage "Image" drawnImg
			
			if error? try [maxSize: max picture/height picture/width] [maxSize: 512] 
			
			sl1/data: dp /  (maxSize * 1.0)
			sl2/data: minDist /  (maxSize * 1.0)
			sl3/data: minRadius /  maxSize 
			sl4/data: maxRadius /  maxSize
			
			isFile: true
			
		]
		[Alert "Pbs" isFile: false]
	]
	updateDP
	updateminD
	updateminR
	updatemaxR
	
	
	show [sl1 sl2 sl3 sl4]
]


processImage: does [
	if isFile [
	pt1: make struct! CvPoint! [0 0]
	pt2: make struct! CvPoint! [0 0]
	cvZero cannyImg
	i: 0
	
	cvThreshold greyImg contrastImg threshold threshold_max  CV_THRESH_TOZERO_INV
	cvCanny contrastImg cannyImg  lowThresh highThresh * 3 3
	circles: cvHoughCircles cannyImg storage CV_HOUGH_GRADIENT dp minDist param1 param2  minRadius maxRadius
		
	for i 1 circles/total 1 [
		p: cvGetSeqElem circles i
		;data: get-memory &line 16  4 float 
		v1: reverse get-memory p + 0 4; OK  if not Using an Intel processor do not use reverse
       	v2: reverse get-memory p + 4 4 
        v3: reverse get-memory p + 8 4
		v4: reverse get-memory p + 12 4
		; on cast en float et en integer 
		pt1/x: to-integer first bin-to-float v1
		pt1/y: to-integer first bin-to-float v2
		pt2/x: to-integer first bin-to-float v3
		pt2/y: to-integer first bin-to-float v4
        cvCircle cannyImg pt1/x pt1/y pt2/x pt2/y 0.0 255.0 0.0 0.0 -1 CV_AA 0 
	]
	
	cvShowImage "Threshold" contrastImg
	cvShowImage "Canny" cannyImg
	cvShowImage "Image" drawnImg
	]		
]


updateDP: does [
	if isFile [dp: round 1.0 + ( sl1/data * 10) dpText/text: dp 0.1 show dpText]
]

updateminD: does [
	if isFile [minDist: round 1.0 + ( sl2/data * maxSize) minDistText/text: minDist 0.1 show minDistText]
]

updateminR: does [
	if isFile [minRadius: to-integer 1 +  ( sl3/data * maxSize) minRText/text:  minRadius show minRText]
]

updatemaxR: does [
if isFile [maxRadius: to-integer 1 +  ( sl4/data * maxSize) maxRText/text:  maxRadius show maxRText]
]


updateH: does [
	if isFile [highThresh: to-integer  sl5/data * 512 cHText/text: highThresh show cHText]
]

updateL: does [
	if isFile [lowThresh: to-integer  sl6/data * 512 cLText/text: lowThresh show cLText]
]

updateF: does [
	if isFile [threshold:  to-integer  sl7/data * threshold_max fHText/text: threshold show fHText]
]



updatemaxF: does [
	if isFile [threshold_max:  to-integer  sl8/data * 512 fLText/text:  threshold_max show fLText]
]

mainwin: layout/size [
	across
	origin 0X0
	space 4x0
	at 5x5 
	btn 100 "Load Image" [loadImage]
	btn 100 "Process Image" [processImage]
	at 5x30 
		info 100 "Resolution" sl1: scroller 100x23 [updateDP]  dpText: info 50 
		info 100 "Distance mini"  sl2: scroller 100x23 [updateminD]  minDistText: info 50 
	
	at 5x55 
		info 100 "Rayon mini" sl3: scroller 100x23 [updateminR]  minRText: info 50  
		info 100 "Rayon maxi" sl4: scroller 100x23 [updatemaxR]  maxRText: info 50 
		
	at 5x80 
	info 100 "Canny Haut" sl5: scroller 100x23 [updateH]  cHText: info 50 
	info 100 "Canny Bas" sl6: scroller 100x23 [updateL]  cLText: info 50 
	
	at 5x105 
	info 100 "Filtre " sl7: scroller 100x23 [updateF]  fHText: info 50 
	info 100 "Filtre Maxi" sl8: scroller 100x23 [updatemaxF]  fLText: info 50 
	
	
    
    
	
	at 460x5 btn 50 "Quit" [if isFile [cvReleaseImage picture cvReleaseImage greyImg 
							cvReleaseImage cannyImg cvReleaseImage drawnImg 
							cvReleaseImage contrastImg] 
	                          quit]
	] 535x600
center-face mainwin
view mainwin

