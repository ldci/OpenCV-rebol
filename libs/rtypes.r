#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Rebol Types"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

; this is for my own tests on Mac OSX

;ocv: load/library %/Library/Frameworks/OpenCV1-0.framework/Versions/A/OpenCV ; 1.0
;ocv: load/library %/Library/Frameworks/OpenCV2-0.framework/Versions/B/OpenCV ; 2.0
; these libs are 64 bits cannot be used with rebol
;cxcore: load/library %/usr/local/lib/libopencv_core.dylib
;cvision: load/library %/usr/local/lib/libopencv_imgproc.dylib
;highgui: load/library %/usr/lib/libopencv_highgui.dylib

;****************** we need some specific structures for talking to OPenCV  **************
; * pointers

void*: integer!
char*: make struct! [buffer [string!]] none
struct*: make struct! [struct [struct! [[save] c [char]]]] none

byte-ptr!: make struct! [byte [char!]] none
int-ptr!: make struct! [int [integer!]] none
float-ptr!: make struct! [float [decimal!]] none


; for OpenCV

{metatypes used 
typedef void CvArr;
The metatype CvArr is used only as a function parameter to specify that the function accepts arrays of multiple types, 
such as IplImage*, CvMat* or even CvSeq* sometimes. The particular array type is determined at runtime by analyzing the first 4 bytes of the header.
in rebol we have to define a generic pointer 
CvArr!: make struct! [ptr [integer!]] none ; just a pointer to integer ; or to byte
}

CvArr!: int-ptr!
CvRNG!: make struct! [rng [decimal!]] none
CvFileStorage!: int-ptr!






