#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Stat functions "
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

wName2: "Image 8b"
i8B: cvCreateImage 512 512 IPL_DEPTH_8U 1
&i8B: as-pointer! i8B

p1: cvScalar 0 0 0 0
p2: cvScalar random 255  random 255 random 255 random 255
ptr: make struct! [float [decimal!]] reduce [random 255]

cvRandArr ptr &i8B CV_RAND_NORMAL p1/v0 p1/v1 p1/v2 p1/v3 p2/v0 p2/v1 p2/v2 p2/v3

cvShowImage wName2 &i8B

cvSetImageCOI &i8B 0 ; all channels 
print ["Non Zero values: " cvCountNonZero &i8B]
m: make struct! cvScalar! none
sd: make struct! cvScalar! none

cvAvgSdv &i8B m sd none
print ["Mean: " m/v0 ]
print ["STD: " sd/v0]

cvWaitKey 0
print "Done"
cvReleaseImage i8B