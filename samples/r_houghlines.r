#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Hough Lines"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

do %../opencv.r
set 'appDir what-dir 
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
   lines: cvHoughLines2 dst storage CV_HOUGH_PROBABILISTIC distance angle threshold param1 param2
   i: 0
    until [
        line: cvGetSeqElem lines i ; line = pointeur address with 4 values ; increment 16 : 4 integers of sizeof 4
        ;data: get-memory &line 16 ; 
        pt1/x: to-integer reverse get-memory line + 0 4 ; OK  if not Using an Intel processor do not use reverse
        pt1/y: to-integer reverse get-memory line + 4 4  
        pt2/x: to-integer reverse get-memory line + 8 4
		pt2/y: to-integer reverse get-memory line + 12 4
        ;print [&line i " : " pt1/x " " pt1/y " " pt2/x " " pt2/y]
        cvLine colorDst pt1/x pt1/y pt2/x pt2/y 0.0 0.0 255.0 0.0 3 CV_AA 0
        i: i + 1
        i = lines/total
    ]   

]


HNormal: func [] [
    lines: cvHoughLines2 dst storage CV_HOUGH_STANDARD distance angle threshold 0.0 0.0
    i: 0
    until [
        line: cvGetSeqElem lines i  ; line = pointeur address with 2 values ; increment  : 2 float of sizeof 4
        ;data: get-memory &line 8 ;
        v1: reverse get-memory line + 0 4 ; OK  if not Using an Intel processor do not use reverse
        v2: reverse get-memory line + 4 4 ; OK  if not Using an Intel processor do not use reverse
        rho: first bin-to-float v1				;cast to float OK
        theta:  first bin-to-float v2           ; cast to float! OK
      
        a: cosine/radians theta                  ;OK
        b: sine/radians theta
        x0: a * rho
        y0: b * rho
        pt1/x: cvRound (x0 + (1000 * negate b)) 
        pt1/y: cvRound (y0 + (1000 * a))
        pt2/x: cvRound (x0 - (1000 * negate b))
        pt2/y: cvRound (y0 - (1000 * a)) 
        ;print [i " "x0 " "y0  " " a " "  negate b" " pt1/x  " " pt1/y " " pt2/x " "  pt2/y lf]
        cvLine colorDst pt1/x pt1/y pt2/x pt2/y 255.0 0.0 0.0 0.0 3 CV_AA 0
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
			&&src: make struct! int-ptr! reduce [struct-address? src] 
			colorSrc: cvLoadImage filename  CV_LOAD_IMAGE_COLOR
			&&colorSrc: make struct! int-ptr! reduce [struct-address? colorSrc]
			cvtoRebol/fit  colorSrc rimage1 
			rimage2/image: load ""
			show rimage2
			isFile: true
			processImage
		]
		[Alert "Not an image" ]
	]
]

processImage: does [
	t1: now/time/precise
	dst: cvCreateImage src/width src/height IPL_DEPTH_8U 1
    &&dst: make struct! int-ptr! reduce [struct-address? dst]
    
    colorDst: cvCreateImage src/width src/height IPL_DEPTH_8U 3
    &&colorDst: make struct! int-ptr! reduce [struct-address? colorDst]
    
    cvCanny src dst 50.0 200.0 3
    cvCvtColor dst colorDst CV_GRAY2BGR
    
    storage: cvCreateMemStorage 0
    &&storage: make struct! int-ptr! reduce [struct-address? storage]
   
    switch flag/text [
		"STANDARD" [HNormal]
		"PROBABILISTIC" [HProba]
	]
  	

    cvtoRebol/fit  colorDst rimage2
    t2: now/time/precise
    sb/text: join " Done in " [to-string round/to t2 - t1 0.001 " sec"]
    show sb
    recycle
]


mainwin: layout/size [
	across
	origin 0X0
	space 4x0
	at 5x5 
	btn 80 "Load Image" [loadImage]
	btn 60 "Process" [if isFile [processImage]]
	txt 60 "Method" flag: choice 100 data ["STANDARD" "PROBABILISTIC"]
	txt "Distance resolution" dtext: field 40 to-string distance [if error? try [distance: to-decimal dtext/text] [distance: 1.0]]
	txt "Angle/radian" atext: field 60 to-string round/to angle .001 [if error? try [angle: to-decimal atext/text] [angle: CV_PI / 180.0]]
	txt "Threshold" ttext: field 40 to-string threshold [if error? try [threshold: to-integer ttext/text] [threshold: 50]]
	txt "Param Hough Proba" p1text: field 40 to-string param1 [if error? try [param1: to-decimal p1text/text] [param1: 50.0]]
	                        p2text: field 40 to-string param2 [if error? try [param2: to-decimal p2text/text] [param2: 10.0]]
	
	
	
	at 985x5 btn 50 "Quit" [if isFile [cvReleaseImage &&src cvReleaseImage &&dst 
	                          cvReleaseImage &&colorSrc cvReleaseImage &&colorDst] 
	                          quit]
	space 0x0
    at 5x30 rimage1: image 512x512 frame blue
	at 525x30 rimage2: image 512x512 frame blue
	at 5x545 sb: info 1035
	
	] 1045x580
center-face mainwin
view mainwin

