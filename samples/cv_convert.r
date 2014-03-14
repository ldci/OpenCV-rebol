#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Image Conversions"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
;picture:  to-string to-local-file join appDir "images/lena.tiff"

print "Select a picture"

temp: request-file 
picture: to-string to-local-file to-string temp



wName1: "Original 8-bit Image [ESC to Quit]"
wName2: "Grayscale Image"
wName3: "Converted 32-bit Image" 
wName4: "Converted 8-bit Image" 
print ["Loading an image"]




; we use 3 channels 8-bit image a source

src: cvLoadImage picture  CV_LOAD_IMAGE_ANYDEPTH OR CV_LOAD_IMAGE_ANYCOLOR; CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_GRAYSCALE; 

; for test in grayscale
gray: cvCreateImage src/width src/height IPL_DEPTH_8U 1
;to transform to 32-bit image
dst: cvCreateImage src/width src/height IPL_DEPTH_32F 3
dst2: cvCreateImage src/width src/height IPL_DEPTH_8U 3

cvNamedWindow wName1 CV_WINDOW_AUTOSIZE 
cvNamedWindow wName2 CV_WINDOW_AUTOSIZE
cvNamedWindow wName3 CV_WINDOW_AUTOSIZE
cvNamedWindow wName4 CV_WINDOW_AUTOSIZE

cvShowImage wName1 src 

;convert to  a gray image
cvCvtColor src gray CV_BGR2GRAY 



cvShowImage wName2 gray 

;convert to a 32-bit image [0.0..1.0]
scale: 1 / 255 ; 0.003921568627451
cvConvertScale src dst scale 0.0


;now convert 32 to 8-bit image [0..255]
cvConvertScaleAbs dst dst2 255.0 0.0

cvShowImage wName3 dst 
cvShowImage wName4 dst2 
print lf
print "Converted to gray image"
print "Converted to 32-bit image"
print "Converted to 8-bit image"

cvMoveWindow wName1  100 40
cvMoveWindow wName2  120 100
cvMoveWindow wName3  140 190
cvMoveWindow wName4  160 280
cvWaitKey 0
print "All tests done. Hit a key!"
cvWaitKey 0
cvDestroyAllWindows 

; release image pointer

cvReleaseImage src 
cvReleaseImage gray
cvReleaseImage dst
cvReleaseImage dst2

