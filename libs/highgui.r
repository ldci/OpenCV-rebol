#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Binding: highgui"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

; Highgui

do %cxtypes.r ; for stand alone testing

;The  opencv structure CvCapture does not have public interface and is used only as a parameter for video capturing functions.
CvCapture!: int-ptr! none
CvVideoWriter!: int-ptr! none

; windows control

CV_WINDOW_AUTOSIZE: 		1 ; fit image in windows
; mouse events 
CV_EVENT_MOUSEMOVE: 		0
CV_EVENT_LBUTTONDOWN: 		1
CV_EVENT_RBUTTONDOWN: 		2
CV_EVENT_MBUTTONDOWN: 		3
CV_EVENT_LBUTTONUP: 		4
CV_EVENT_RBUTTONUP: 		5
CV_EVENT_MBUTTONUP: 		6
CV_EVENT_LBUTTONDBLCLK: 	7
CV_EVENT_RBUTTONDBLCLK: 	8
CV_EVENT_MBUTTONDBLCLK: 	9
CV_EVENT_FLAG_LBUTTON: 		1
CV_EVENT_FLAG_RBUTTON: 		2
CV_EVENT_FLAG_MBUTTON: 		4
CV_EVENT_FLAG_CTRLKEY: 		8
CV_EVENT_FLAG_SHIFTKEY: 	16
CV_EVENT_FLAG_ALTKEY: 		32
 
;flags when loading image
CV_LOAD_IMAGE_UNCHANGED:  -1 ;8bit, color or not
CV_LOAD_IMAGE_GRAYSCALE:   0 ;8bit, gray
CV_LOAD_IMAGE_COLOR:       1 ; ?, color
CV_LOAD_IMAGE_ANYDEPTH:    2 ;any depth, ? 
CV_LOAD_IMAGE_ANYCOLOR:    4 ;?, any color

; convert one image to another 
CV_CVTIMG_FLIP:      		1
CV_CVTIMG_SWAP_RB:   		2 
CV_DEFAULT:			 		0

; playing with camera
CV_CAP_ANY:      			0    ; autodetect
CV_CAP_MIL:      			100   ; MIL proprietary drivers
CV_CAP_VFW:      			200   ; platform native
CV_CAP_V4L:      			200
CV_CAP_V4L2:     			200
CV_CAP_FIREWARE: 			300   ; IEEE 1394 drivers
CV_CAP_IEEE1394: 			300
CV_CAP_DC1394:   			300
CV_CAP_CMU1394:  			300
CV_CAP_STEREO:   			400   ;TYZX proprietary drivers
CV_CAP_TYZX:     			400
CV_TYZX_LEFT:    			400
CV_TYZX_RIGHT:   			401
CV_TYZX_COLOR:   			402
CV_TYZX_Z:       			403
CV_CAP_QT:       			500   ; QuickTime
; capture properties
CV_CAP_PROP_POS_MSEC:       0
CV_CAP_PROP_POS_FRAMES:     1
CV_CAP_PROP_POS_AVI_RATIO:  2
CV_CAP_PROP_FRAME_WIDTH:    3
CV_CAP_PROP_FRAME_HEIGHT:   4
CV_CAP_PROP_FPS:            5
CV_CAP_PROP_FOURCC:         6
CV_CAP_PROP_FRAME_COUNT:    7 
CV_CAP_PROP_FORMAT:         8
CV_CAP_PROP_MODE:           9
CV_CAP_PROP_BRIGHTNESS:    10
CV_CAP_PROP_CONTRAST:      11
CV_CAP_PROP_SATURATION:    12
CV_CAP_PROP_HUE:           13
CV_CAP_PROP_GAIN:          14
CV_CAP_PROP_CONVERT_RGB:   15

CV_FOURCC: func [c1 c2 c3 c4 /local v1 v2 v3 v4][
	v1: to-integer c1 and 255 
	v2: shift/left to-integer c2 and 255 8
	v3: shift/left to-integer c3 and 255 16
	v4: shift/left to-integer c4 and 255 24
	v1 + v2 + v3 + v4
]

CV_FOURCC_PROMPT: 		-1  ; Open Codec Selection Dialog (Windows only) */
CV_FOURCC_DEFAULT: 		-1 ; Use default codec for specified filename (Linux only) */


cvInitSystem: make routine! [
"this function is used to set some external parameters in case of X Window"
	argc 		[integer!]
	char** 		[string!] ; pointer
	return: 	[integer!]
] highgui "cvInitSystem"

cvStartWindowThread: make routine! [
"Start a separated window thread that will manage mouse events"
	return: 	[integer!]
] highgui "cvStartWindowThread"


cvNamedWindow: make routine! [
"create window: flags CV_DEFAULT(CV_WINDOW_AUTOSIZE)"
	name 		[string!]
	flags 		[integer!] ;CV_DEFAULT(CV_WINDOW_AUTOSIZE)
	return: 	[integer!]
] highgui "cvNamedWindow"

cvDestroyWindow: make routine! [
"destroy window and all the trackers associated with it"
	name 		[string!]
	return:		[]
] highgui "cvDestroyWindow"

cvDestroyAllWindows: make routine! [
"destroy all windows and all the trackers associated with it"
	return: 	[]
] highgui "cvDestroyAllWindows"

;resize/move window
cvResizeWindow: make routine! [
"resize window"
	name 		[string!]
	width 		[integer!]
	height 		[integer!]
	return: 	[]
] highgui "cvResizeWindow"

cvMoveWindow: make routine! [
"move window"
	name 		[string!]
	x 			[integer!]
	y 			[integer!]
	return: 	[]
] highgui "cvMoveWindow"

cvGetWindowHandle: make routine! [
"get native window handle (HWND in case of Win32 and Widget in case of X Window"
	name 		[string!]
	return: 	[int] ; return a pointer to HWD
] highgui "cvGetWindowHandle"

cvGetWindowName: make routine! [
"get name of highgui window given by its native handle"
	window_handle 	[int] ; void* pointer to handle
	return: 		[string!]
] highgui "cvGetWindowName"

; cvCreateImage is defined in cxcore 

cvShowImage: make routine! compose/deep/only [
"display image within window (highgui windows remember their content)"
	name 		[string!]
	image 		[int]; [struct! (first CvArr!)]
	return: 	[]
] highgui "cvShowImage"


cvCreateTrackbar: make routine!  compose/deep/only [
"create trackbar and display it on top of given window, set callback" 
	trackbar_name 	[string!]
	window_name 	[string!]
	value 			[struct! [(first int-ptr!)]] ; pointer
	count 			[integer!]
	on_change 		[callback [int]]; can be null 
	return: 		[integer!]	
] highgui "cvCreateTrackbar"


cvGetTrackbarPos: make routine! [
"retrieve trackbar position"
	trackbar_name 	[string!]
	window_name 	[string!]
	return: 		[integer!]
] highgui "cvGetTrackbarPos"

cvSetTrackbarPos: make routine! [
"set trackbar position"
	trackbar_name 	[string!]
	window_name 	[string!]
	pos 			[integer!]
	return: 		[integer!]
] highgui "cvSetTrackbarPos"

 
cvSetMouseCallback: make routine! compose/deep/only [
"assign callback for mouse events"
	window_name 	[string!]
	on_mouse 		[callback [int int int int int]] ; pointer sur une fonction avec 5 params
    param			[integer!] ; pointer must be null (set to none)
    return:			[]
] highgui "cvSetMouseCallback"


cvLoadImage: make routine! compose/deep/only[
{load image from file 
iscolor can be a combination of flags where CV_LOAD_IMAGE_UNCHANGED  overrides the other flags
using CV_LOAD_IMAGE_ANYCOLOR alone is equivalent to CV_LOAD_IMAGE_UNCHANGED
unless CV_LOAD_IMAGE_ANYDEPTH is specified images are converted to 8bit
this function returns a pointer IplImage structure  (see cxtypes.r)
Supported image formats: BMP, DIB, JPEG, JPG, JPE, PNG, PBM, SR, RAS, TIFF, TIF}
	filename 		[string!]
	flags 			[integer!] ;CV_DEFAULT(CV_LOAD_IMAGE_COLOR))
	return: 		[struct! (first IplImage!)] ; returns an iplImage structure
] highgui "cvLoadImage"



cvLoadImageM: make routine! compose/deep/only [
"this function returns a pointer CvMat structure  (see cxtypes.r)"
	filename 		[string!]
	iscolor 		[integer!] ;CV_DEFAULT(CV_LOAD_IMAGE_COLOR))
	return: 		[struct! (first CvMat!)]
	
] highgui "cvLoadImageM"

cvSaveImage: make routine! compose/deep/only  [
"save image to file"
	filename 		[string!]
	image 			[int]; [struct! (first CvArr!)]
	return: 		[integer!]
] highgui "cvSaveImage"


cvConvertImage: make routine! compose/deep/only [
{utility function: convert one image to another with optional vertical flip
src and dst are CvArr! i.e a pointer to image. flags:CV_DEFAULT(0)}
	src 			[int]; [struct! (first CvArr!)]
	dst 			[int]; [struct! (first CvArr!)]
	flags 			[integer!] ; CV_DEFAULT(0)
	return:			[]
]highgui "cvConvertImage" 

cvWaitKey: make routine! [
"wait for key event infinitely (delay<=0) or for delay milliseconds"
	delay 			[integer!] ; CV_DEFAULT(0)
	return: 		[integer!]
] highgui "cvWaitKey"
 
{****************************************************************************************
*                         Working with Video Files and Cameras                          *
\****************************************************************************************}


cvCreateFileCapture: make routine! compose/deep/only [
;start capturing frames from video file 
	filename 		[string!]
	return:  		[struct! (first CvCapture!)] ;pointer to cvCapture
] highgui "cvCreateFileCapture"


cvCreateCameraCapture: make routine! compose/deep/only [
{start capturing frames from camera: index = camera_index + domain_offset (CV_CAP_*)
Index of the camera to be used. If there is only one camera or it does not matter what camera to use -1 may be passed.}
	index 			[integer!]
	return:  		[struct! (first CvCapture!)] ;pointer to cvCapture
] highgui "cvCreateCameraCapture"

cvGrabFrame: make routine! compose/deep/only [
"grab a frame, return 1 on success, 0 on fail. this function is thought to be fast" 
	capture 		[int]; [struct! (first CvCapture!)] ;pointer to cvCapture
	return: 		[integer!] ; returned value
] highgui "cvGrabFrame" 

 
cvRetrieveFrame: make routine! compose/deep/only [
{get the frame grabbed with cvGrabFrame(..) This function may apply some frame processing like 
frame decompression, flipping etc. !!!DO NOT RELEASE or MODIFY the retrieved frame!!}
	capture 		[int]; [struct! (first CvCapture!)] ;pointer to cvCapture ;pointer to cvCapture
	return: 		[struct! (first IplImage!)] ; returns an iplImage structure
] highgui "cvRetrieveFrame" 
   
  
cvQueryFrame: make routine! compose/deep/only [
"Just a combination of cvGrabFrame and cvRetrieveFrame !!!DO NOT RELEASE or MODIFY the retrieved frame!!! "
	capture 		[int]; ;pointer to cvCapture 
	return: 		[struct! (first IplImage!)] ; returns an iplImage structure
] highgui "cvQueryFrame" 
   
; orginal OPenCV
cvReleaseCapture_: make routine! compose/deep/only [
"stop capturing/reading and free resources"
	capture 		[int]; requires double pointer to cvCapture
	return:			[]
]highgui "cvReleaseCapture"

;Rebol version : better 
cvReleaseCapture: func [capture] [
	free-mem capture
]


cvGetCaptureProperty: make routine! compose/deep/only[
"retrieve capture properties. Struct required!"
	capture 		[struct! (first CvCapture!)] ;pointer to cvCapture
	property_id 	[integer!]
	return: 		[decimal!]
]highgui "cvGetCaptureProperty"

cvSetCaptureProperty: make routine! compose/deep/only[
"set capture properties. Struct required!"
	capture 		[struct! (first CvCapture!)] ;pointer to cvCapture
	property_id 	[integer!]
	value 			[decimal!]
	return: 		[integer!]
]highgui "cvSetCaptureProperty"


cvCreateVideoWriter: make routine! compose/deep/only[
"initialize video file writer"
	filename 		[string!]
	fourcc 			[integer!]
	pfs 			[decimal!]
	width           [integer!] ;cvSize/width
    height          [integer!] ;cvSize/height
	is_color 		[integer!] ;CV_DEFAULT(1))
	return: 		[struct! (first CvVideoWriter!)] ; CvVideoWriter!
]highgui "cvCreateVideoWriter"	


cvWriteFrame: "cvWriteFrame" make routine! compose/deep/only[
"write frame to video file"
	writer 			[struct! (first CvVideoWriter!)] ;CvVideoWriter!
	image 			[struct! (first IplImage!)]
	return:			[integer!]
] highgui	"cvWriteFrame"


cvReleaseVideoWriter_: make routine! compose/deep/only [
"close video file writer" 
	writer 			[struct! (first CvVideoWriter!)] ;double pointer CvVideoWriter!
	return:			[]
]highgui "cvReleaseVideoWriter"

cvReleaseVideoWriter: func [writer] [
	free-mem writer
]

