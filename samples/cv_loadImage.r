#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
lena:  to-string to-local-file join appDir "images/lena.tiff"


; function pointer that can be called by TrackBar callback 
trackEvent: func [ pos [integer!] ][print ["Trackbar position is : " pos]] 

; this is pointer  to the function  called by mouse callback
mouseEvent: func [
            event 	[integer!]
            x	    [integer!]
            y	    [integer!]
            flags	[integer!]
            param	[(int-ptr!)]
	] [
	print ["Mouse Position xy : " x " " y]
]
 
cvStartWindowThread  ; own's window thread 
&p: int-ptr! none  ; for trackbar position 


windowsName: "Lena: What a Wonderful World!"
print ["Loading a tiff image"]

lenaWin: cvNamedWindow windowsName CV_WINDOW_AUTOSIZE ; create window 
; for trackbar events 
cvCreateTrackbar "Track" windowsName &p 100 :trackEvent ; function as parameter
cvSetTrackBarPos "Track" windowsName 0

; for mouse events
cvSetMouseCallBack windowsName :mouseEvent none

;load image 

img: cvLoadImage lena CV_LOAD_IMAGE_COLOR
&img: struct-address? img

copie: cvCreateImage img/width img/height img/depth img/nChannels ;IPL_DEPTH_8U 1;
;cvZero copie
	
&step: make struct! int-ptr! reduce [0]
&size: make struct! cvSize! reduce [0 0]
		
data: make binary! img/imageSize * sizeof 'integer!
&data: string-address? data
&&data: make struct! int-ptr! reduce [&data]
cvGetRawData img &&data &step &size

data: to-binary address-to-string &&data/int
set-memory copie/imageData data
free-mem data

cvShowImage windowsName img ; show image
cvNamedWindow "copie" CV_WINDOW_AUTOSIZE
cvShowImage "copie" copie

cvWaitKey 500 ;wait 500 ms
cvResizeWindow windowsName 256 256 ; resize window
print [windowsName " is now 256x256 "]
cvWaitKey 500
print [windowsName " is now 512x512"]
cvResizeWindow windowsName 512 512
cvWaitKey 500
print [windowsName " is moved to 300x50 "]
cvMoveWindow windowsName 300 50  ;move window

cvWaitKey 0
print ["Saving the image in jpg"]
cvSaveImage to-string to-local-file join appDir "images/lena.jpg" img ; save tiff as jpg
print ["done! Bye "]

cvDestroyWindow windowsName       
free-mem &p	;release trackbar pointer
_cvReleaseImage img ; release image pointer





