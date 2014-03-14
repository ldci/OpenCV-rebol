#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Drawing"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]


do %../opencv.r
	

wndname: "OpenCV drawing and text output functions"
number: 100
delay: 5
lineType: CV_AA; // change it to 8 to see non-antialiased graphics
i: 0 
width: 1000 
height: 700
width3: width * 3
height3: height * 3;

x1: negate width / 2
x2: (width * 3) / 2 
y1: negate height / 2 
y2: (height * 3) / 2

cvRNG #FFFFFFFF ; random generator 
CV_RGB 255 255 0

; ipl_depth * nchannels : donne le nbre de bits de l'image : ex 8X3 : 24 bits color
; IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16U, IPL_DEPTH_16S, IPL_DEPTH_32F, IPL_DEPTH_64F
; use tocvByteRGB, tocvIntRGB or tocvFloatRGB according to depth image to get nice colors! 

image: cvCreateImage width height IPL_DEPTH_32F 3; 


pt1: make struct! CvPoint! none
pt2: make struct! CvPoint! none

&font: make struct! cvFont! none
cvInitFont &font CV_FONT_HERSHEY_SIMPLEX 1.0 1.0 0 1 lineType
_font: 0
vs: 0.0
hs: 0.0
&text_size: make struct! CvSize! reduce [0 0]

&ymin: make struct! int-ptr! reduce [0]

cvGetTextSize "Any key to start" &font &text_size &ymin
pt1/x: (width - &text_size/width) / 2
pt1/y: (height + &text_size/height) / 2


cvPutText image "Any key to start" pt1/x pt1/y &font 0.0 56.0 -56.0 0.0
cvNamedWindow wndname CV_WINDOW_AUTOSIZE
cvShowImage wndname image

print ["Focus the window and hit any key to start "]

cvwaitKey 0
t1: t2: now/time/precise
print t1

cvZero image
print ["Drawing Lines"]
	
for i 1 number 1  [
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	pt1: random to-pair reduce [(x) (y)]
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	pt2: random to-pair reduce [(x) (y)]
	;color: random 255.255.255
	color: tocvFloatRGB random 255.255.255 
	thickness: random 10
	cvLine image pt1/x pt1/y pt2/x pt2/y color/1 color/2 color/3 0 thickness 8 0
    cvShowImage wndname image
]

print ["Drawing Rectangles"]
cvZero image
; draw rectangles
for i 1 number 1  [
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	pt1: random to-pair reduce [(x) (y)]
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	pt2: random to-pair reduce [(x) (y)]
	color: tocvFloatRGB random 255.255.255 
	thickness: random 10 
	if thickness  < 2 [thickness: -1] ; -1 for filled form
	cvRectangle image pt1/x pt1/y pt2/x pt2/y color/1 color/2 color/3 0 thickness lineType 0
    cvShowImage wndname image
]

print ["Drawing Elipses"]
cvZero image
; draw ellipses
for i 1 number 1  [
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	center: random to-pair reduce [(x) (y)]
	rwidth: random 200
	rheigh: random 200
	axes: random to-pair reduce [(rwidth) (rheigh)]
	angle: random 180
	thickness: random 9 
	if thickness  < 2 [thickness: -1]
	color: tocvFloatRGB random 255.255.255 
	cvEllipse image center/x center/y axes/x axes/y angle angle - 180 angle + 200 color/1 color/2 color/3 0 thickness lineType 0
	cvShowImage wndname image
]

print ["Drawing Polygons"]
cvZero image
; draw polygons
for i 1 number 1  [
    pts: copy []
    for i 1 4 1 [
        bloc: copy []
		x: random/only reduce [(x1) (x2)]
		y: random/only reduce [(y1) (y2)]
		pt: random to-pair reduce [(x) (y)]
		append bloc pt
		append/only pts bloc
	]
	thickness: random 10
	color: random 255.255.255
	either random 2 = 1 [closed: true] [closed: false] ; true: closes form
	rcvPolyLine image pts closed color thickness lineType 0
	cvShowImage wndname image
]

print ["Fill Polygons"]
cvZero image
; fill polygons
for i 1 number 1  [
	pts: copy []
	bloc: copy []
	for i 1 3 1 [
		x: random/only reduce [(x1) (x2)]
		y: random/only reduce [(y1) (y2)]
		pt: random to-pair reduce [(x) (y)]
		append bloc pt
	]
	append/only pts bloc
	
	bloc: copy []
	for i 1 4 1 [
		x: random/only reduce [(x1) (x2)]
		y: random/only reduce [(y1) (y2)]
		pt: random to-pair reduce [(x) (y)]
		append bloc pt
	]
	append/only pts bloc
	color: random 255.255.255
	rcvFillPoly image pts color lineType 0 ; revoir 
	cvShowImage wndname image
]

print ["Drawing Circles"]
cvZero image
; draw circles

for i 1 number 1  [
	x: random/only reduce [(x1) (x2)]
	y: random/only reduce [(y1) (y2)]
	pt: random to-pair reduce [(x) (y)]
	radius: random 300
	color: tocvFloatRGB random 255.255.255 
	thickness: random 9 
	if thickness  < 2 [thickness: -1]
	cvCircle image pt/x pt/y radius color/1 color/2 color/3 0 thickness lineType 0
	cvShowImage wndname image
]

print ["Testing Fonts"]
cvZero image

for i 1 number 1  [
    pt1/x: random width3 - width
    pt1/y: random height3 - height
	color: tocvByteRGB/signed random 255.255.255 
	thickness: random 3 
	_font: random 8 if _font = 8 [_font: 0]
	vs: random 5.0
	hs: random 3.0
	cvInitFont &font _font hs vs 0 thickness CV_AA
	cvPutText image "Testing text rendering" pt1/x pt1/y &font color/1 color/2 color/3 0
	cvShowImage wndname image
]


cvInitFont &font CV_FONT_HERSHEY_SIMPLEX 3.0 3.0 0 5 lineType
cvGetTextSize "OpenCV forever!" &font &text_size &ymin

pt1/x: (width - &text_size/width) / 2
pt1/y: (height + &text_size/height) / 2

image2: cvCloneImage image


print ["Testing Images substraction "]
for i 1 255 1 [
    v: cvScalarAll i
    cvAddS image2 v image none
    color: tocvFloatRGB to-tuple reduce [i  i  255]
    cvPutText image "OpenCV forever!" pt1/x pt1/y &font color/1 color/2 color/3  0
    cvShowImage wndname image
    cvWaitKey delay
]

cvZero image
cvPutText image "Any key to close" pt1/x pt1/y &font 255 0 0 0
cvShowImage wndname image

t2: now/time/precise
print [t2]
print ["All tests done in " t2 - t1 " sec"]
print ["Any key to close"]

cvwaitKey 0
cvReleaseImage image
cvReleaseImage image2
cvDestroyWindow wndname





