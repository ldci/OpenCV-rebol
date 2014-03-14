#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Arithmetic, logic and comparison operations "
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
;picture:  to-string to-local-file join appDir "images/lena.tiff"

temp: request-file 
picture: to-string to-local-file to-string temp

wName1: "Image 1 [ESC to Quit]"
wName2: "Image 2 "
wName3: "Result" 

src: cvLoadImage picture CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_GRAYSCALE; 
clone: cvCreateImage src/width src/height src/depth src/nChannels ;IPL_DEPTH_8U 1;
sum: cvCreateImage src/width src/height src/depth src/nChannels ;IPL_DEPTH_8U 1;

cvCopy src clone none


cvNamedWindow wName1 CV_WINDOW_AUTOSIZE 
cvNamedWindow wName2 CV_WINDOW_AUTOSIZE
cvNamedWindow wName3 CV_WINDOW_AUTOSIZE

; Adding images
cvAdd src clone sum none
cvShowImage wName1 src 
cvShowImage wName2 clone 
cvShowImage wName3 sum 
cvMoveWindow wName1  100 40
cvMoveWindow wName2  140 100
cvMoveWindow wName3  180 200
print "cvAdd Hit a key!"
cvWaitKey 0
cvWaitKey 0
; Sub Images
cvSub sum clone sum none
cvShowImage wName3 sum 
print "cvSub Hit a key!"
cvWaitKey 0

; Adding Scalar
value: cvScalar 255 0 0 0
cvAddS src value sum none
cvShowImage wName3 sum 
print "cvAddS Hit a key!"
cvWaitKey 0

; Substract  scalar
value: cvScalar 0 255 0 0
cvSubS src value sum none
cvShowImage wName3 sum 
print "cvSubS Hit a key!"
cvWaitKey 0

value: cvScalar 255 0 0 0
cvSubRS src value sum none
cvShowImage wName3 sum 
print "cvSubS Hit a key!"
cvWaitKey 0

; multiplication
cvMul src clone sum 1.0
cvShowImage wName3 sum 
print "cvMul Hit a key!"
cvWaitKey 0

;division
cvDiv clone src sum 255.0
cvShowImage wName3 sum 
print "cvDiv Hit a key!"
cvWaitKey 0

; add scale
scale: cvScalar 0.0 0.0 0.0 0.0
;cvScaleAdd src scale mask sum 
cvShowImage wName3 sum 
print "Pb cvScaleAdd Hit a key!"
cvWaitKey 0

cvAddWeighted src 1 / 3.0  clone 1 / 3.0 0.0 sum
cvShowImage wName3 sum 
print "cvAddWeighted Hit a key!"
cvWaitKey 0

cvAnd src sum sum none
cvShowImage wName3 sum 
print "cvAnd Hit a key!"
cvWaitKey 0

value: cvScalar 0 0 0 0 
cvAndS clone value sum none
cvShowImage wName3 sum 
print "cvAndS Hit a key!"
cvWaitKey 0

cvOr src sum sum none
cvShowImage wName3 sum 
print "cvOr Hit a key!"
cvWaitKey 0

value: cvScalar 0 255 0 0
cvOrS clone value sum none
cvShowImage wName3 sum 
print "cvOrS Hit a key!"
cvWaitKey 0

cvXor src clone sum none
cvShowImage wName3 sum 
print "cvXor Hit a key!"
cvWaitKey 0

value: cvScalar 0 255 0 0
cvXorS clone value sum none
cvShowImage wName3 sum 
print "cvXorS Hit a key!"
cvWaitKey 0

cvNot src sum 
cvShowImage wName3 sum 
print "cvNot Hit a key!"





print ["cvDotProduct : "  cvDotProduct src clone  " Hit a key"]
cvWaitKey 0

print "All tests done. Hit a key!"
cvWaitKey 0

cvDestroyAllWindows 

; release image pointer

cvReleaseImage src 
cvReleaseImage clone
cvReleaseImage sum

