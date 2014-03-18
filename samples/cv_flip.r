#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Flip functions "
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

wName: "Image 1 [space to continue]"
wName2: "Copy"

;picture:  to-string to-local-file join appDir "images/lena.tiff"

print "Select a picture"

temp: request-file 
picture: to-string to-local-file to-string temp

img: cvLoadImage picture CV_LOAD_IMAGE_COLOR
&img: as-pointer! img
cvShowImage wName &img
cvWaitKey 0
cvWaitKey 0

cvFlip &img &img 0
cvShowImage wName &img
cvWaitKey 0

cvFlip &img &img 1
cvShowImage wName &img
cvWaitKey 0

cvFlip &img &img -1
cvShowImage wName &img
cvWaitKey 0

cvFlip &img &img 1
cvShowImage wName &img
cvWaitKey 0

cvFlip &img &img 1
cvShowImage wName &img
cvWaitKey 0



print "Done"
cvReleaseImage &img