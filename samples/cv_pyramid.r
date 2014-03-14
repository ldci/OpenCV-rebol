#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: Pyramid Segmentation"
	Author:		"FranÁois Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License:     "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 
isFile: false

threshold1: 255
threshold2: 30
level: 4
block_size: 1000

comp: make struct! CvSeq! none
&comp: struct-address? comp

pthreshold1: make struct! int-ptr! reduce [threshold1]
pthreshold2: make struct! int-ptr! reduce [threshold2]




ON_SEGMENT: does [
    threshold1: pthreshold1/int
    threshold2: pthreshold2/int
    cvPyrSegmentation image0 image1 storage &comp level threshold1 + 1 threshold2 + 1
    cvShowImage "Segmentation" image1
]

filename: to-string to-local-file to-string request-file ; to-string join appDir "/images/apple.jpg"
wait 0.1
image: cvLoadImage filename CV_LOAD_IMAGE_UNCHANGED 


cvNamedWindow "Source" CV_WINDOW_AUTOSIZE ;0 
cvShowImage "Source" image
cvNamedWindow "Segmentation" 1 ;0


storage: cvCreateMemStorage block_size
&&storage:  make struct! int-ptr! reduce [ struct-address? storage]

val: negate shift/left 1 level
image/width: image/width and val 
image/height: image/height and val

image0: cvCloneImage image
image1: cvCloneImage image

;image1: cvCreateImage image/width image/height IPL_DEPTH_8U 3


sthreshold1: cvCreateTrackbar "Threshold1" "Segmentation" pthreshold1 255 :ON_SEGMENT 
sthreshold2: cvCreateTrackbar "Threshold2" "Segmentation" pthreshold2 255 :ON_SEGMENT 

cvShowImage "Segmentation" image1
cvMoveWindow "Segmentation" 300 50 

ON_SEGMENT

cvWaitKey(0);

cvDestroyWindow "Segmentation"
cvDestroyWindow "Source"
cvReleaseImage image
cvReleaseImage image0
cvReleaseImage image1
cvReleaseMemStorage &&storage 


