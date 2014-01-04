#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
lena:  to-string to-local-file join appDir "images/lena.tiff"
probe lena
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
&&img: make struct! int-ptr! reduce [&img] 


;print [windowsName " is " img/width  "x" img/height]

cvShowImage windowsName img ; show image

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
cvReleaseImage &&img ; release image pointer





