#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Tests: REBOL to OpenCV"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]
do %../opencv.r
set 'appDir what-dir 

width: 0
height: 0
wndname: "Rebol to OpenCv"
isFile: false
image: none

loadImage: does [
isFile: false
if error? try [
	temp: request-file 
	if not none? temp [
		imageRead: load to-file temp 
		rimage/image: imageRead
		width: imageRead/size/1
		height: imageRead/size/2
		show rimage
		isFile: true
	]
	] [alert "Non supported image"]
]

; OK Rebol travaille en 24 bits 
;Chaque couleur est codée sur 1 octet = 8 bits. 
;Chaque pixel sur 3 octets c'est à dire 24 bits : le rouge de 0 à 255 , le vert de 0 à 255, le Bleu de 0 à 255.
; Rebol rajoute un bit alpha pour la luminance 
; chaque pixel est codé par un tuple de 4 valeurs rgba (donc en 32 bits) 

convertImage: does [
    t1: now/time/precise
    fl: flash "Patience writing memory data" 
    wait 0.1
    either fchan/data 
    	[bin: to-binary imageRead image: cvCreateImage width height IPL_DEPTH_8U 4]	;4 channels
    	[bin: to-binary imageRead/rgb image: cvCreateImage width height IPL_DEPTH_8U 3] ;3 channels
	&image: as-pointer! image
	&bin: string-address? bin
	cvSetData &image &bin image/widthStep ;size/width
	; rebol version: slower
	;set-memory image/imageData bin ; copy data 
	
	if rgb/data  [if not fchan/data [cvConvertImage &image &image CV_CVTIMG_SWAP_RB] ] ;; pour le flip RGB to BGR
	cvNamedWindow wndname CV_WINDOW_AUTOSIZE
	cvShowImage wndname &image
	t2: now/time/precise
	unview/only fl
	sb/text: join "Done in " [round/to t2 - t1 0.001 " sec"]
	show sb
]

; on peut aussui &image: cvCreateImage width height IPL_DEPTH_8U 4 pour avoir le bit alpha
; mais dans ce cas, data doit avor la valeur data: to-binary image (on prend /rgb + /aplha)

mainwin: layout/size [
	across
	origin 0X0
	space 5x0
	at 5x5 
	btn 100 "Load Image" [loadImage]
	btn 100 "Convert Image" [if isFile [convertImage] ]
	txt "4 channels" fchan: check 20x20
	txt "Inversion RGB"  rgb: check 20x20
	btn 100 "Quit" [if isFile [cvReleaseImage &image] quit]
	space 0x0
	at 5x30 console: area 300x512 sl: slider 16x512 [scroll-para console sl]
	at 325x30 rimage: image 512x512 frame blue
	at 5x550 sb: info 835
	] 845x580

center-face mainwin
append console/text join "Hello OpenCV can talk to REBOL !!!" newline
view mainwin
 