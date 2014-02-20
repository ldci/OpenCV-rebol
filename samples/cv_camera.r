#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Camera"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
movie: to-string join appDir "images/camera.mov"

cvStartWindowThread 									; separate window thread
capture: cvCreateCameraCapture CV_CAP_ANY 				; create a capture using default webcam (iSight) ; change to n for other cam
if capture = none [print "error!"]

;set our movie properties
fps: 24.00
camW: 1280
camH: 1024
rec: false 												; no automatic movie recording (set rec to true for testing)

; creates a writer to record video if necessary
if rec [
	cc:  CV_FOURCC #"D" #"I" #"V" #"X"
	writer: cvCreateVideoWriter movie cc fps camW camH 1 ; 1: CV_DEFAULT (1)
	if writer = none [print "error"]
]

cvNamedWindow "Test Window" CV_WINDOW_AUTOSIZE 			; create window to show movie
handle: cvGetWindowHandle "Test Window" 				; not used  when using mac OSX without X 


key:  #"q"; 113 as integer!
foo: 0

; repeat until q keypress
print ["Memory before: " system/stats / (10 ** 6)]
while [foo <> 113] [
	    image:  cvQueryFrame capture					;get frame
		cvResizeWindow "Test Window" 640 480			; resize
        cvShowImage "Test Window"  image   				; show frame
        if rec [cvWriteFrame writer image]  			; write frame on disk if we want to record movie 
        foo: cvWaitKey 1
]
print ["Memory after : " system/stats / (10 ** 6)]
print "Done. Any key to quit" 
cvWaitKey 0
; releases structures and windows
cvDestroyAllWindows
_cvReleaseImage image 
_cvReleaseCapture capture
if rec [_cvReleaseVideoWriter writer]


