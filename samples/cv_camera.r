#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Camera"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
movie: to-string join appDir "images/camera.mov"

cvStartWindowThread ; separate window thread
capture: cvCreateCameraCapture CV_CAP_ANY ; create a capture using default webcam (iSight) ; change to n for other cam
&&capture:  make struct! int-ptr! reduce [struct-address? capture]
if capture = none [print "error!"]

;set our movie properties
fps: 24.00
camW: 1280
camH: 1024
rec: false ; no automatic movie recording (set rec to true for testing)

; creates a writer to record video if necessary
if rec [
	cc:  CV_FOURCC #"D" #"I" #"V" #"X"
	writer: cvCreateVideoWriter movie cc fps camW camH 1 ; 1: CV_DEFAULT (1)
	&&writer: make struct! int-ptr! reduce [struct-address? writer]; make a double pointer to structure
	if &&writer = null [print "error"]
]

cvNamedWindow "Test Window" CV_WINDOW_AUTOSIZE 			; create window to show movie
handle: cvGetWindowHandle "Test Window" 				; not used  when using mac OSX without X 
;image: cvRetrieveFrame capture	
;&image: struct-address? image					; get the first image 
;&&image: make struct! int-ptr! reduce [&image] 	; make a double pointer to &image structure


key:  #"q"; 113 as integer!
foo: 0

; repeat until q keypress
print ["before: " system/stats / (10 ** 6)]
while [foo <> 113] [
	     image:  cvQueryFrame capture

		;&image: struct-address? image
		;&&image: make struct! int-ptr! reduce [&image]
		cvResizeWindow "Test Window" 320 240
        cvShowImage "Test Window"  image   ; show frame
        ;print ["pendant : " system/stats / (10 ** 6)]
        image: none
        if rec [cvWriteFrame writer image]  ; write frame on disk if we want to record movie 
        foo: cvWaitKey 1
]
recycle 
print ["after : " system/stats / (10 ** 6)]
print "Done. Any key to quit" 
cvWaitKey 0
; releases structures and windows
cvDestroyAllWindows
;cvReleaseImage &&image 

cvReleaseCapture &&capture
if rec [cvReleaseVideoWriter &&writer]