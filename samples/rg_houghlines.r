#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Hough Lines"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 
guiDir: join appDir "RebGui/" 
do to-file join guiDir "rebgui.r"

isFile: false
rho: 0.0
theta: 0.0
pt1: make struct! CvPoint! [0 0]
pt2: make struct! CvPoint! [0 0]
a: 0.0
b: 0.0
x0: 0.0
y0: 0.0
bb: 0.0

distance: 1.0
angle: CV_PI / 180.0
threshold: 50
param1: 50.0
param2: 10.0

HProba: does [
   lines: cvHoughLines2 &dst storage CV_HOUGH_PROBABILISTIC distance angle threshold param1 param2
   i: 0
    until [
        line: cvGetSeqElem lines i ; line = pointeur address with 4 values ; increment 16 : 4 integers of sizeof 4
        ;data: get-memory &line 16 ; 
        pt1/x: to-integer reverse get-memory line + 0 4 ; OK  if not Using an Intel processor do not use reverse
        pt1/y: to-integer reverse get-memory line + 4 4  
        pt2/x: to-integer reverse get-memory line + 8 4
		pt2/y: to-integer reverse get-memory line + 12 4
        ;print [line i " : " pt1/x " " pt1/y " " pt2/x " " pt2/y]
        cvLine &colorDst pt1/x pt1/y pt2/x pt2/y 0.0 0.0 255.0 0.0 3 CV_AA 0
        i: i + 1
        i = lines/total
    ]   

]


HNormal: func [] [
    lines: cvHoughLines2 &dst storage CV_HOUGH_STANDARD distance angle threshold 0.0 0.0
    i: 0
    until [
        line: cvGetSeqElem lines i  ; line = pointeur address with 2 values ; increment  : 2 float of sizeof 4
        ;data: get-memory &line 8 ;
        v1: reverse get-memory line + 0 4 ; OK  if not Using an Intel processor do not use reverse
        v2: reverse get-memory line + 4 4 ; OK  if not Using an Intel processor do not use reverse
        rho: first bin-to-float v1				;cast to float OK
        theta:  first bin-to-float v2           ; cast to float! OK
        
        ; to-decimal trim to-string
      
      
        a: cosine/radians theta                  ;OK
        b: sine/radians theta
        x0: a * rho
        y0: b * rho
        pt1/x: cvRound (x0 + (1000 * negate b)) 
        pt1/y: cvRound (y0 + (1000 * a))
        pt2/x: cvRound (x0 - (1000 * negate b))
        pt2/y: cvRound (y0 - (1000 * a)) 
        ;print [i " "x0 " "y0  " " a " "  negate b" " pt1/x  " " pt1/y " " pt2/x " "  pt2/y lf]
        cvLine &colorDst pt1/x pt1/y pt2/x pt2/y 255.0 0.0 0.0 0.0 3 CV_AA 0
        i: i + 1
        i =  MIN to-integer lines/total 100  
    ]
]


loadImage: does [
	isFile: false
	temp: request-file 
	if not none? temp [
	 	filename: to-string to-local-file to-string temp
		if error? try [
			src: cvLoadImage filename CV_LOAD_IMAGE_GRAYSCALE ;
			&src: as-pointer! src 
			colorSrc: cvLoadImage filename  CV_LOAD_IMAGE_COLOR
			&colorSrc: as-pointer! colorSrc
			cvtoRebol  colorSrc rimage1 
			rimage2/image: load ""
			show rimage2
			isFile: true
			isFile: true
			set-text dtext to-string distance
			set-text atext to-string round/to angle .001
			set-text ttext to-string threshold
			set-text p1text to-string param1
			set-text p2text to-string param2
			processImage
		]
		[Alert "Problem in reading image" ]
	]
]


processImage: does [
	t1: now/time/precise
	&src: as-pointer! src
	dst: cvCreateImage src/width src/height IPL_DEPTH_8U 1
	&dst: as-pointer! dst
   	colorDst: cvCreateImage src/width src/height IPL_DEPTH_8U 3
   	&colorDst: as-pointer! colorDst
    cvCanny &src &dst 50.0 200.0 3
    cvCvtColor &dst &colorDst CV_GRAY2BGR
    storage: cvCreateMemStorage 0
    switch flag/text [
		"STANDARD" [HNormal]
		"PROBABILISTIC" [HProba]
	]
  	
    cvtoRebol  colorDst rimage2
    t2: now/time/precise
    sb/text: join " Done in " [to-string round/to t2 - t1 0.001 " sec"]
    show sb
    recycle
]





mainWin: [
	button 15 "Load" [loadImage]
	field 15 options [info] "Method"
	flag: drop-list 28 "STANDARD" data ["STANDARD" "PROBABILISTIC"] [processImage]
	field 31 options [info] "Distance resolution"
	dtext: field 10 [if error? try [distance: to-decimal dtext/text] [distance: 1.0]]
	field 22 options [info] "Angle/radian"
	atext: field 15 [if error? try [angle: to-decimal atext/text] [angle: CV_PI / 180.0]]
	field 18 options [info] "Threshold"ttext: field 10 [if error? try [threshold: to-integer ttext/text] [threshold: 50]]
	field 35 options [info] "Param Hough Proba"
	p1text: field 10  [if error? try [param1: to-decimal p1text/text] [param1: 50.0]]
	                        p2text: field 10 [if error? try [param2: to-decimal p2text/text] [param2: 10.0]]
	button 15 "Process" [if isFile [processImage]]
	button 10 "Quit" [if isFile [cvReleaseImage src cvReleaseImage dst 
	                          cvReleaseImage colorSrc cvReleaseImage colorDst
	                          cvReleaseMemStorage storage] 
	                          quit]
	return
	panel data [
			rimage1: image 128x128 
			splitter 2x128
			rimage2: image 128x128 
	
	]
	return
	sb: field 270 options [info]
	
]


display "OpenCV Tests: Morphology" mainWin
do-events