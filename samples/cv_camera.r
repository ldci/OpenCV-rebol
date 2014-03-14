#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Camera"
	Author:		"Francois Jouen"
	Rights:		"Copyright (c) 2012-2014 Francois Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
movie: to-string join appDir "images/camera.mov"
wName: "Test Window [q to Quit]" 
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

cvNamedWindow wName CV_WINDOW_AUTOSIZE 			; create window to show movie
handle: cvGetWindowHandle wName 				;  


key:  #"q"; 113 as integer!
foo: 0

; repeat until q keypress
while [foo <> 113] [
	    image:  cvQueryFrame capture					;get frame
		cvResizeWindow wName 640 480			; resize
        cvShowImage wName  image   				; show frame
        if rec [cvWriteFrame writer image]  			; write frame on disk if we want to record movie 
        foo: cvWaitKey 1
]
print "Done. Any key to quit" 
cvWaitKey 0
; releases structures and windows
cvDestroyAllWindows
cvReleaseImage image 
cvReleaseCapture capture
if rec [cvReleaseVideoWriter writer]


