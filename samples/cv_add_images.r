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

wName1: "Image 1 [space to continue]"
wName2: "Image 2 "
wName3: "Result" 

src: cvLoadImage picture CV_LOAD_IMAGE_COLOR; CV_LOAD_IMAGE_GRAYSCALE; 
&src: as-pointer! src
&clone: as-pointer! cvCreateImage src/width src/height src/depth src/nChannels ;IPL_DEPTH_8U 1;
&sum:  as-pointer! cvCreateImage src/width src/height src/depth src/nChannels ;IPL_DEPTH_8U 1;



cvCopy &src &clone none


cvNamedWindow wName1 CV_WINDOW_AUTOSIZE 
cvNamedWindow wName2 CV_WINDOW_AUTOSIZE
cvNamedWindow wName3 CV_WINDOW_AUTOSIZE

; Adding images
cvAdd &src &clone &sum none
cvShowImage wName1 &src 
cvShowImage wName2 &clone 
cvShowImage wName3 &sum 
cvMoveWindow wName1  100 40
cvMoveWindow wName2  140 100
cvMoveWindow wName3  180 200
print "cvAdd Hit a key!"
cvWaitKey 0
cvWaitKey 0
; Sub Images
cvSub &sum &clone &sum none
cvShowImage wName3 &sum 
print "cvSub Hit a key!"
cvWaitKey 0

; Adding Scalar
v: cvScalar 255 0 0 0

cvAddS &src v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvAddS Hit a key!"
cvWaitKey 0

; Substract  scalar
v: cvScalar 0 255 0 0
cvSubS &src v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvSubS Hit a key!"
cvWaitKey 0

v: cvScalar 255 0 0 0
cvSubRS &src v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvSubS Hit a key!"
cvWaitKey 0

; multiplication
cvMul &src &clone &sum 1.0
cvShowImage wName3 &sum 
print "cvMul Hit a key!"
cvWaitKey 0

;division
cvDiv &clone &src &sum 255.0
cvShowImage wName3 &sum 
print "cvDiv Hit a key!"
cvWaitKey 0

; add scale 
; for 1-D mat??
{scale: cvScalar 0.0 0.0 0.0 0.0
cvScaleAdd &src 0.0 0.0 0.0 0.0 &clone &sum 
cvShowImage wName3 &sum 
print "Pb cvScaleAdd Hit a key!"
cvWaitKey 0}

cvAddWeighted &src 1 / 3.0  &clone 1 / 3.0 0.0 &sum
cvShowImage wName3 &sum 
print "cvAddWeighted Hit a key!"
cvWaitKey 0

cvAnd &src &sum &sum none
cvShowImage wName3 &sum 
print "cvAnd Hit a key!"
cvWaitKey 0

v: cvScalar 0 0 0 0 
cvAndS &clone  v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvAndS Hit a key!"
cvWaitKey 0

cvOr &src &sum &sum none
cvShowImage wName3 &sum 
print "cvOr Hit a key!"
cvWaitKey 0

v: cvScalar 0 255 0 0
cvOrS &clone v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvOrS Hit a key!"
cvWaitKey 0

cvXor &sum &clone &sum none
cvShowImage wName3 &sum 
print "cvXor Hit a key!"
cvWaitKey 0

v: cvScalar 0 255 0 0
cvXorS &clone v/v0 v/v1 v/v2 v/v3 &sum none
cvShowImage wName3 &sum 
print "cvXorS Hit a key!"
cvWaitKey 0

cvNot &src &sum 
cvShowImage wName3 &sum 
print "cvNot Hit a key!"


print ["cvDotProduct : "  cvDotProduct &src &clone  " Hit a key"]
cvWaitKey 0

print "All tests done. Hit a key!"
cvWaitKey 0

cvDestroyAllWindows 

; release image structures and pointers

cvReleaseImage src cvReleaseImage &src
cvReleaseImage &clone cvReleaseImage &sum

