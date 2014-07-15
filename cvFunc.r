#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: cvFunc"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;use integer! as pointer shortcut: gives the memory address of pointed values or structures 
ptr: integer!  

; for some tools
do %libs/rtools.r
; for image
set 'appDir what-dir 
picture:  to-string to-local-file join appDir  "samples/images/lena.tiff"; "images/lena.tiff"


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
			1.2.0 [ocv: load/library %/Library/Frameworks/OpenCV1-2.framework/Versions/Current/OpenCV]
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
				cvision: load/library to-file "/usr/lib/libocv.so.2.1"
				highgui: load/library to-file "/usr/lib/libhighgui.so.2.1"
			]
		]
	]

]


; select correct opencv version
opencvVersion: 2.0.0

usedLib opencvVersion



; load opencv lib
lib: ocv


;define a mezzanine function to be used to generate REBOL routine! for ALL cv Functions 

cvFunc: func [specs identifier][make routine! specs lib identifier]

;some external opencv functions to be called
cvNamedWindow: cvFunc [name [string!] flag [integer!] return: [integer!]] "cvNamedWindow"	
cvWaitKey: cvFunc [delay [integer!] return: [integer!]] "cvWaitKey"
cvLoadImage: cvFunc [name [string!] flag [integer!] return: [ptr]] "cvLoadImage"
cvShowImage: cvFunc [name [string!] img [integer!]] "cvShowImage"


; main function

windowsName: "Hello OpenCV World"				; opencv window name
w: cvNamedWindow windowsName 0			; create a opencv Window
img: cvLoadImage picture 4				; load image
cvShowImage windowsName img				; show image in cv Window
print getIPLValues/address img			; print information about image
c: cvWaitKey 0							; wait for a key event 
free lib								; free  library


