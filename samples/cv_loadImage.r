#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
picture:  to-string to-local-file join appDir "images/lena.tiff"

;print "Select a picture"

;temp: request-file 
;picture: to-string to-local-file to-string temp

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
&p: as-int! 0  ; for trackbar position 

windowsName: "What a Wonderful World!"
print "Loading a tiff image"
print newline

lenaWin: cvNamedWindow windowsName CV_WINDOW_AUTOSIZE ; create window 
; for trackbar events 
cvCreateTrackbar "Track" windowsName &p 100 :trackEvent ; function as parameter
cvSetTrackBarPos "Track" windowsName 0

; for mouse events
cvSetMouseCallBack windowsName :mouseEvent none

;load image 

img: cvLoadImage picture CV_LOAD_IMAGE_COLOR
&img: as-pointer! img
cvShowImage windowsName &img ; show image
copie: cvCreateImage img/width img/height img/depth img/nChannels ;IPL_DEPTH_8U 1;
&copie: as-pointer! copie
cvZero &copie
; to get data from orginal image wit rawdata	
step: make struct! int-ptr! reduce [img/widthStep]
&step: as-pointer! step
data: make struct! int-ptr! reduce [img/imageSize]
&data: as-pointer! data 
roi: make struct! cvSize! reduce [img/width img/height]

cvGetRawData &img &data &step roi
&data: data/int          					; get the pointer adress in return
data: get-memory  &data img/imageSize		;get the data
cvSetData &copie &data img/widthStep			;now use SetData to make a copy of image !
;set-memory copie/imageData data			; this can also be done but slower (rebol)
free-mem data								; free memory


cvNamedWindow "copie" CV_WINDOW_AUTOSIZE
cvShowImage "copie" &copie

print ["" newline]
print "Use cvGetRawData to make a new image"


; test cvCopy OK
copie2: cvCreateImage img/width img/height img/depth img/nChannels ;IPL_DEPTH_8U 1;
&copie2: as-pointer! copie2
cvCopy &img &copie2 none

cvNamedWindow "copie2" CV_WINDOW_AUTOSIZE
cvShowImage "copie2" &copie2
print ["" newline]
print "Use cvCopy to make a new image"

cvWaitKey 1000
; tout en white: OK
print "Copy image is white"

cvSet &copie2 255 255 255 255 0

cvShowImage "copie2" &copie2
cvWaitKey 1000
; tout en noir OK
cvSetZero &copie2
cvShowImage "copie2" &copie2
print "Copy image is black"

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
cvSaveImage to-string to-local-file join appDir "images/image.jpg" &img ; save tiff as jpg
print ["done! Bye "]

cvDestroyWindow windowsName       
free-mem &p	;release trackbar pointer
cvReleaseImage img ; release istructures
cvReleaseImage copie
cvReleaseImage copie2
{cvReleaseImage &img
cvReleaseImage &copie
cvReleaseImage &copie2}




