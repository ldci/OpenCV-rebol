#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Binding"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]


; some information we need 
; little or big endian ?

endian?: get-modes system/ports/system 'endian ; 

;which OS?

getOs: does [
	switch/default system/version/4 [
		3 [os: "Windows" ]
		2 [os: "Mac OS X"]
		4 [os: "Linux" ]
		5 [os: "BeOS" ]
		7 [os: "NetBSD" ]
		9 [os: "OpenBSD" ]
		10 [os: "SunSolaris" ]
	] [os: "Unknow OS !!!"]
	return os
]


;which version of openCV 
; please adapt according your needs


usedLib: func [version [tuple!]] [
	runningOs: getOs
	if runningOs = "Mac OS X" [
		switch version [
			1.0.0 [ocv: load/library %/Library/Frameworks/OpenCV1-0.framework/Versions/Current/OpenCV]
			2.0.0 [ocv: load/library %/Library/Frameworks/OpenCV2-0.framework/Versions/Current/OpenCV]
			2.4.1 [ocv: load/library %/Library/Frameworks/OpenCV2-4.framework/Versions/2.4.1/opencv2] ; 64-bit
		]
		cvision: ocv highgui: ocv cxcore: ocv
	]
	
	if runningOs = "Windows" [
		switch version [
			1.0.0 [
				cxcore: load/library to-file "c:\windows\system32\cxcore100.dll"
				cvision: load/library to-file "c:\windows\system32\cv100.dll"
				highgui: load/library to-file "c:\windows\system32\highgui100.dll"
			]
			2.0.0 [
				cxcore: load/library to-file "c:\OpenCV2.0\bin\libcxcore200.dll"
				cvision: load/library to-file "c:\OpenCV2.0\bin\libcv200.dll"
				highgui: load/library to-file "c:\OpenCV2.0\bin\libhighgui200.dll"
			]
		]
	]
	
	if runningOs = "linux" [
		switch version [
			2.0.0 [
				cxcore: load/library to-file "/usr/lib/libcxcore.so.2.1"
				cvision: load/library to-file "/usr/lib/libcv.so.2.1"
				highgui: load/library to-file "/usr/lib/libhighgui.so.2.1"
			]
		]
	]

]


; select correct opencv version
opencvVersion: 2.0.0

usedLib opencvVersion





;same rebol code for each os
do %libs/rtypes.r 				; specific structures and functions for REBOL
do %libs/rtools.r				; tools by famous rebolers
do %libs/cvver.r				; version numbering
do %libs/cxerror.r				; error processing
do %libs/cxtypes.r  	        ; cxcore structures
do %libs/cxcore.r   	        ; cxcore functions                          :cxcore
do %libs/cvtypes.r              ; Computer Vision structures
do %libs/cv.r		 			; Computer Vision functions                 :cvision
do %libs/highgui.r 	        	; Simple Highgui structures and functions   :highui






