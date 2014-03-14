#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Image Comaraison"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
picture:  to-string to-local-file join appDir "images/lena.tiff"
windowsName: "Original Image [ESC to Quit]"
print ["Loading an image"]


cvNamedWindow windowsName CV_WINDOW_AUTOSIZE ; create window 
cvNamedWindow "Destination" CV_WINDOW_AUTOSIZE
; we use 3 channels 8-bit image !

img: cvLoadImage picture CV_LOAD_IMAGE_COLOR


; creates 3 images for RGB planes since we don't use alpha channel
s0: cvCreateImage img/width img/height IPL_DEPTH_8U 1
s1: cvCreateImage img/width img/height IPL_DEPTH_8U 1
s2: cvCreateImage img/width img/height IPL_DEPTH_8U 1
dst: cvCreateImage img/width img/height IPL_DEPTH_8U 1
cvSplit img  s0 s1 s2 none

cvShowImage windowsName img
cvMoveWindow "Destination"  620 100

print lf
cvCmp s0 s1 dst CV_CMP_EQ

cvShowImage "Destination" dst
print "cvCmp Hit key" 
cvWaitKey 0

cvCmpS s0 64 dst CV_CMP_EQ
cvShowImage "Destination" dst
print "cvCmpS Hit key" 
cvWaitKey 0

cvMin s0 s1 dst CV_CMP_EQ
cvShowImage "Destination" dst
print "cvMin Hit key" 
cvWaitKey 0

cvMax s0 s1 dst CV_CMP_EQ
cvShowImage "Destination" dst
print "cvMax Hit key" 
cvWaitKey 0

cvMinS s0 128 dst 
cvShowImage "Destination" dst
print "cvMinS Hit key" 
cvWaitKey 0

cvMaxS s0 64 dst 
cvShowImage "Destination" dst
print "cvMaxS Hit key" 
cvWaitKey 0

cvAbsDiff s0 s1 dst 
cvShowImage "Destination" dst
print "cvAbsDiff Hit key" 
cvWaitKey 0

cvAbsDiffS s0 dst 64 64 64 64  
cvShowImage "Destination" dst
print "cvAbsDiffS Hit key" 
cvWaitKey 0

cvAbs s1 dst 
cvShowImage "Destination" dst
print "cvAbs Hit key" 
cvWaitKey 0

cvPow s0 dst 2.0
cvShowImage "Destination" dst
print "cvPow Hit key" 
cvWaitKey 0



cvDestroyAllWindows 

cvReleaseImage img ; release image pointer
cvReleaseImage s0
cvReleaseImage s1
cvReleaseImage s2
cvReleaseImage dst
print "Done"