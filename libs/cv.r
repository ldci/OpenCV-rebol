#! /usr/bin/rebol
REBOL [
	Title:		"OpenCV Binding: cv"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012 François Jouen. All rights reserved."
	version: 	1.0.1
	License: {
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		    * Redistributions of source code must retain the above copyright notice,
		      this list of conditions and the following disclaimer.
		    * Redistributions in binary form must reproduce the above copyright notice,
		      this list of conditions and the following disclaimer in the documentation
		      and/or other materials provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
		ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	}
]

; for stand alone testing

do %cxtypes.r
do %cvtypes.r ; needs %cxtypes.r




;/****************************************************************************************\
;*                                    Image Processing                                    *
;\****************************************************************************************/

;Copies source 2D array inside of the larger destination array and
;makes a border of the specified type (IPL_BORDER_*) around the copied area. */
                             
cvCopyMakeBorder: make routine! compose/deep/only [
	src 	[int];         CvArr!
	dst 	[int];         CvArr!
	x  		[integer!] ; in fact CvPoint
	y		[integer!]
	bordertype [integer!]
	value 	[struct! (first CvScalar!)] ;CvScalar CV_DEFAULT(cvScalarAll(0))	
] cvision  "cvCopyMakeBorder"                             

CV_BLUR_NO_SCALE: 	0
CV_BLUR:  			1
CV_GAUSSIAN:  		2
CV_MEDIAN:			3
CV_BILATERAL:	 	4

;Smoothes array (removes noise)
cvSmooth: make routine! compose/deep/only [
	src 		[int]; [struct! (first CvArr!)]
	dst 		[int]; [struct! (first CvArr!)]
	smoothtype 	[integer!] ; CV_DEFAULT(CV_GAUSSIAN)
	param1		[integer!] ; CV_DEFAULT(3)
	param2		[integer!] ; CV_DEFAULT(0)
	param3		[decimal!] ; CV_DEFAULT(0)
	param4		[decimal!] ; CV_DEFAULT(0)	
] cvision "cvSmooth"

;Convolves the image with the kernel
cvFilter2D: make routine! compose/deep/only [
	src 		[int];         CvArr!
	dst 		[int];         CvArr!
	kernel		[struct! (first CvMat!)]
	x  			[integer!] ; in fact CvPoint 
	y			[integer!] ;CV_DEFAULT(cvPoint(-1,-1))
] cvision "cvFilter2D"

;Finds integral image: SUM(X,Y) = sum(x<X,y<Y)I(x,y)
cvIntegral: make routine! compose/deep/only [
	image 		[int];         CvArr!
	sum 		[int];         CvArr!
	sqsum		[int];         CvArr! ;CV_DEFAULT(NULL) none
	tilted_sum	[int];         CvArr! ;CV_DEFAULT(NULL) none	
] cvision "cvIntegral"

;Smoothes the input image with gaussian kernel and then down-samples it.
;dst_width = floor(src_width/2)[+1],
;dst_height = floor(src_height/2)[+1]   
cvPyrDown: make routine! compose/deep/only [
	src 		[int] ; [struct! (first CvArr!)]
	dst 		[int] ;[struct! (first CvArr!)]
	filter		[integer!]; CV_DEFAULT(CV_GAUSSIAN_5x5)
] cvision "cvPyrDown"
                   
;Up-samples image and smoothes the result with gaussian kernel.
;dst_width = src_width*2, dst_height = src_height*2
cvPyrUp: make routine! compose/deep/only [
	src 		[int];         CvArr!
	dst 		[int];         CvArr!
	filter		[integer!]; CV_DEFAULT(CV_GAUSSIAN_5x5)
] cvision "cvPyrUp"

;Builds pyramid for an image 
if opencvVersion > 1.0.0 [

cvCreatePyramid: make routine! compose/deep/only [
	img 			[int];         CvArr!
	extra_layers	[integer!]
	rate			[decimal!]
	layer_sizes		[integer!]; pointer to CvSize* ; CV_DEFAULT(0),
	bufarr 			[integer!] ; CV_DEFAULT(0)
	calc			[integer!]; CV_DEFAULT(1)
	filter			[integer!]; CV_DEFAULT(CV_GAUSSIAN_5x5)
	return 			[integer!] ;a double pointer CvMat**
] cvision "cvCreatePyramid"


; Releases pyramid
cvReleasePyramid: make routine! compose/deep/only [
	pyramid			[integer!] ; pointer CvMat***
	extra_layers	[integer!]
] cvision "cvReleasePyramid"
]

{Splits color or grayscale image into multiple connected components
of nearly the same color/brightness using modification of Burt algorithm.
comp with contain a pointer to sequence (CvSeq)
of connected components (CvConnectedComp)}
cvPyrSegmentation: make routine! compose/deep/only [
	src 			[int]; [struct! (first iplImage!)]
	dst 			[int];[struct! (first iplImage!)]
	storage			[struct! (first CvMemStorage!)]
	comp			[int] ; pointer CvSeq**
	level			[integer!]
	threshold1		[decimal!]
	threshold2		[decimal!]
]cvision "cvPyrSegmentation"

;Filters image using meanshift algorithm
cvPyrMeanShiftFiltering: make routine! compose/deep/only [
	src 		[int];         CvArr!
	dst 		[int];         CvArr!
	sp			[decimal!]
	sr			[decimal!]
	max_level	[integer!] ;  CV_DEFAULT(1)
	termcrit	[struct! (first CvTermCriteria!)] ; CV_DEFAULT(cvTermCriteria(CV_TERMCRIT_ITER+CV_TERMCRIT_EPS,5,1)))
] cvision "cvPyrMeanShiftFiltering"


;Segments image using seed "markers"
cvWatershed: make routine! compose/deep/only [
	src 		[int];         CvArr!
	markers 	[int];         CvArr!
] cvision "cvWatershed"

CV_INPAINT_NS:      0
CV_INPAINT_TELEA:   1

;Inpaints the selected region in the image
cvInpaint: make routine! compose/deep/only [
	src 			[int];         CvArr!
	inpaint_mask 	[int];         CvArr!
	dst 			[int];         CvArr!
	inpaintRange	[decimal!]
	flags			[integer!]	
] cvision "cvInpaint"

CV_SCHARR:			 	-1
CV_MAX_SOBEL_KSIZE:		 7

{ Calculates an image derivative using generalized Sobel
(aperture_size = 1,3,5,7) or Scharr (aperture_size = -1) operator.
Scharr can be used only for the first dx or dy derivative }
cvSobel: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	xorder			[integer!]
	yorder			[integer!]
	aperture_size	[integer!];  CV_DEFAULT(3)
] cvision "cvSobel"

;Calculates the image Laplacian: (d2/dx + d2/dy)I
cvLaplace: make routine! compose/deep/only [
"Calculates the image Laplacian: (d2/dx + d2/dy)I"
            src 			[int] ; CvArr!
            dst 			[int] ; CvArr!
            aperture_size	[integer!];  CV_DEFAULT(3)
] cvision "cvLaplace"        


;Constants for color conversion
CV_BGR2BGRA:    0
CV_RGB2RGBA:    CV_BGR2BGRA

CV_BGRA2BGR:    1
CV_RGBA2RGB:    CV_BGRA2BGR

CV_BGR2RGBA:    2
CV_RGB2BGRA:    CV_BGR2RGBA

CV_RGBA2BGR:    3
CV_BGRA2RGB:    CV_RGBA2BGR

CV_BGR2RGB:     4
CV_RGB2BGR:     CV_BGR2RGB

CV_BGRA2RGBA:   5
CV_RGBA2BGRA:   CV_BGRA2RGBA

CV_BGR2GRAY:    6
CV_RGB2GRAY:    7
CV_GRAY2BGR:    8
CV_GRAY2RGB:    CV_GRAY2BGR
CV_GRAY2BGRA:   9
CV_GRAY2RGBA:   CV_GRAY2BGRA
CV_BGRA2GRAY:   10
CV_RGBA2GRAY:   11

CV_BGR2BGR565:  12
CV_RGB2BGR565:  13
CV_BGR5652BGR:  14
CV_BGR5652RGB:  15
CV_BGRA2BGR565: 16
CV_RGBA2BGR565: 17
CV_BGR5652BGRA: 18
CV_BGR5652RGBA: 19

CV_GRAY2BGR565: 20
CV_BGR5652GRAY: 21

CV_BGR2BGR555:  22
CV_RGB2BGR555:  23
CV_BGR5552BGR:  24
CV_BGR5552RGB:  25
CV_BGRA2BGR555: 26
CV_RGBA2BGR555: 27
CV_BGR5552BGRA: 28
CV_BGR5552RGBA: 29

CV_GRAY2BGR555: 30
CV_BGR5552GRAY: 31

CV_BGR2XYZ:     32
CV_RGB2XYZ:     33
CV_XYZ2BGR:     34
CV_XYZ2RGB:     35

CV_BGR2YCrCb:   36
CV_RGB2YCrCb:   37
CV_YCrCb2BGR:   38
CV_YCrCb2RGB:   39

CV_BGR2HSV:     40
CV_RGB2HSV:     41

CV_BGR2Lab:     44
CV_RGB2Lab:     45

CV_BayerBG2BGR: 46
CV_BayerGB2BGR: 47
CV_BayerRG2BGR: 48
CV_BayerGR2BGR: 49

CV_BayerBG2RGB: CV_BayerRG2BGR
CV_BayerGB2RGB: CV_BayerGR2BGR
CV_BayerRG2RGB: CV_BayerBG2BGR
CV_BayerGR2RGB: CV_BayerGB2BGR

CV_BGR2Luv:     50
CV_RGB2Luv:     51
CV_BGR2HLS:     52
CV_RGB2HLS:     53

CV_HSV2BGR:     54
CV_HSV2RGB:     55

CV_Lab2BGR:     56
CV_Lab2RGB:     57
CV_Luv2BGR:     58
CV_Luv2RGB:     59
CV_HLS2BGR:     60
CV_HLS2RGB:     61

CV_COLORCVT_MAX:  100

;Converts input array pixels from one color space to another 
cvCvtColor: make routine! compose/deep/only [
	src 			[int];[struct! (first CvArr!)]
	dst 			[int]; [struct! (first CvArr!)]
	code			[integer!]
] cvision "cvCvtColor"

CV_INTER_NN:        0
CV_INTER_LINEAR:    1
CV_INTER_CUBIC:     2
CV_INTER_AREA:      3

CV_WARP_FILL_OUTLIERS: 8
CV_WARP_INVERSE_MAP:  16

;Resizes image (input array is resized to fit the destination array) 
cvResize: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	interpolation	[integer!] ;CV_DEFAULT( CV_INTER_LINEAR ))
] cvision "cvResize"

;Warps image with affine transform
cvWarpAffine: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	map_matrix		[struct! (first CvMat!)]
	flags			[integer!] ;CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS)
	fillval			[struct! (first CvScalar!)] ;CV_DEFAULT(cvScalarAll(0))
] cvision "cvWarpAffine"

;computes affine transform matrix for mapping src[i] to dst[i] (i=0,1,2) 
cvGetAffineTransform: make routine! compose/deep/only [
	src 			[struct! (first CvPoint2D32f!)]
	dst 			[struct! (first CvPoint2D32f!)]
	map_matrix		[struct! (first CvMat!)]
	return:			[struct! (first CvMat!)]
] cvision "cvGetAffineTransform"

;Computes rotation_matrix matrix */
cv2DRotationMatrix: make routine! compose/deep/only [
	center 			[struct! (first CvPoint2D32f!)]
	angle 			[decimal!]
	scale			[decimal!]
	map_matrix		[struct! (first CvMat!)]
	return:			[struct! (first CvMat!)]
] cvision "cv2DRotationMatrix"

;Warps image with perspective (projective) transform
cvWarpPerspective: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	map_matrix		[struct! (first CvMat!)]
	flags			[integer!] ;CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS)
	fillval			[struct! (first CvScalar!)] ;CV_DEFAULT(cvScalarAll(0))
] cvision "cvWarpPerspective"

;Computes perspective transform matrix for mapping src[i] to dst[i] (i=0,1,2,3)
cvGetPerspectiveTransform: make routine! compose/deep/only [
	src 			[struct! (first CvPoint2D32f!)]
	dest 			[struct! (first CvPoint2D32f!)]
	map_matrix		[struct! (first CvMat!)]
	return:			[struct! (first CvMat!)]
] cvision "cvGetPerspectiveTransform"

;Performs generic geometric transformation using the specified coordinate maps */
cvWarpPerspective: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	mapx			[int];         CvArr!
	mapy			[int];         CvArr!
	flags			[integer!] ;CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS)
	fillval			[struct! (first CvScalar!)] ;CV_DEFAULT(cvScalarAll(0))
] cvision "cvWarpPerspective"

;Performs forward or inverse log-polar image transform
cvLogPolar: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dest 			[int];         CvArr!
	center			[struct! (first CvPoint2D32f!)]
	m				[decimal!]
	flags			[integer!] ;CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS)
] cvision "cvLogPolar"

CV_SHAPE_RECT:      0
CV_SHAPE_CROSS:     1
CV_SHAPE_ELLIPSE:   2
CV_SHAPE_CUSTOM:    100

;creates structuring element used for morphological operations */
cvCreateStructuringElementEx: make routine! compose/deep/only [
	cols		[integer!]
	rows		[integer!]
	anchor_x	[integer!]
	anchor_y	[integer!]
	shapes		[integer!]
	values		[integer!] ; pointer to values CV_DEFAULT(NULL)
	return:		[struct! (first IplConvKernel!)]
] cvision "cvCreateStructuringElementEx" 

;releases structuring element */
cvReleaseStructuringElement: make routine! compose/deep/only [
	IplConvKernel**		[struct! (first int-ptr!)]; double pointer
] cvision "cvReleaseStructuringElement"


;erodes input image (applies minimum filter) one or more times.
;If element pointer is NULL, 3x3 rectangular element is used
cvErode: make routine! compose/deep/only [
	src 			[int]; [struct! (first CvArr!)]
	dest 			[int];[struct! (first CvArr!)]
	element			[struct! (first IplConvKernel!)] ;pointer CV_DEFAULT(NULL)
	iterations		[integer!] ;CV_DEFAULT(1)
] cvision "cvErode"

;dilates input image (applies maximum filter) one or more times.
;If element pointer is NULL, 3x3 rectangular element is used */
cvDilate: make routine! compose/deep/only [
	src 			[int];[struct! (first CvArr!)]
	dest 			[int];[struct! (first CvArr!)]
	element			[struct! (first IplConvKernel!)] ;pointer CV_DEFAULT(NULL)
	iterations		[integer!] ;CV_DEFAULT(1)
] cvision "cvDilate"

CV_MOP_OPEN:         2
CV_MOP_CLOSE:        3
CV_MOP_GRADIENT:     4
CV_MOP_TOPHAT:       5
CV_MOP_BLACKHAT:     6         

;Performs complex morphological transformation
cvMorphologyEx: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dest 			[int];         CvArr!
	temp 			[int];         CvArr!
	element			[struct! (first IplConvKernel!)] ;pointer CV_DEFAULT(NULL)
	operation		[integer!] ;CV_DEFAULT(1)
	iterations		[integer!] ;CV_DEFAULT(1)
] cvision "cvMorphologyEx"

;Calculates all spatial and central moments up to the 3rd order 
cvMoments: make routine! compose/deep/only [
	arr 			[int];         CvArr!
	moments 		[struct! (first CvMoments!)]
	binary			[integer!] ;CV_DEFAULT(0)
] cvision "cvMoments"

;/* Retrieve particular spatial, central or normalized central moments 
cvGetSpatialMoment: make routine! compose/deep/only [
	moments 		[struct! (first CvMoments!)]
	x_order			[integer!] 
	y_order			[integer!] 
	return:			[decimal!]
] cvision "cvGetSpatialMoment"
cvGetCentralMoment: make routine! compose/deep/only [
	moments 		[struct! (first CvMoments!)]
	x_order			[integer!] 
	y_order			[integer!] 
	return:			[decimal!]
] cvision "cvGetCentralMoment"

cvGetNormalizedCentralMoment: make routine! compose/deep/only [
	moments 		[struct! (first CvMoments!)]
	x_order			[integer!] 
	y_order			[integer!] 
	return:			[decimal!]
] cvision "cvGetNormalizedCentralMoment"

;Calculates 7 Hu's invariants from precalculated spatial and central moments
cvGetHuMoments: make routine! compose/deep/only [
	moments 		[struct! (first CvMoments!)]
	hu_moments 		[struct! (first CvMoments!)]
] cvision "cvGetHuMoments"

;/*********************************** data sampling **************************************/

;Fetches pixels that belong to the specified line segment and stores them to the buffer. Returns the number of retrieved points.
cvSampleLine: make routine! compose/deep/only [
	image 			[int];         CvArr!
	pt1_x	 		[integer!];CvPoint
	pt1_y	 		[integer!];CvPoint
	pt2_x	 		[integer!];CvPoint
	pt2_y	 		[integer!];CvPoint
	void*	 		[integer!] ; pointer
	connectivity	[integer!] ;CV_DEFAULT(8)
	return:			[integer!]
] cvision "cvSampleLine"

 {Retrieves the rectangular image region with specified center from the input array.
 dst(x,y) <- src(x + center.x - dst_width/2, y + center.y - dst_height/2).
 Values of pixels with fractional coordinates are retrieved using bilinear interpolation}
cvGetRectSubPix: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	center	 		[struct! (first CvPoint2D32f!)] ; to be tested
] cvision "cvGetRectSubPix"

{Retrieves quadrangle from the input array.
matrixarr = ( a11  a12 | b1 )   dst(x,y) <- src(A[x y]' + b)
( a21  a22 | b2 )   (bilinear interpolation is used to retrieve pixels with fractional coordinates)}
cvGetQuadrangleSubPix: make routine! compose/deep/only [
	src 			[int];         CvArr!
	dst 			[int];         CvArr!
	map_matrix 		[int];         CvArr!
] cvision "cvGetQuadrangleSubPix"

;Methods for comparing two array
CV_TM_SQDIFF:        0
CV_TM_SQDIFF_NORMED: 1
CV_TM_CCORR:         2
CV_TM_CCORR_NORMED:  3
CV_TM_CCOEFF:        4
CV_TM_CCOEFF_NORMED: 5

;Measures similarity between template and overlapped windows in the source image and fills the resultant image with the measurements 
cvMatchTemplate: make routine! compose/deep/only [
	image 			[int];         CvArr!
	temp1 			[int];         CvArr!
	result	 		[int];         CvArr!
	method			[integer!]
] cvision "cvMatchTemplate"
;Computes earth mover distance between two weighted point sets (called signatures)
cvCalcEMD2: make routine! compose/deep/only [
	signature1 			[int];         CvArr!
	signature2 			[int];         CvArr!
	distance_type		[integer!]
	distance_func 		[integer!] ; pointer CV_DEFAULT(NULL)
	cost_matrix	 		[int];         CvArr!; CV_DEFAULT(NULL)
	flow				[int];         CvArr!; CV_DEFAULT(NULL)
	lower_bound			[decimal!];  CV_DEFAULT(NULL)
	userdata			[integer!]; null pointer CV_DEFAULT(NULL));
] cvision "cvCalcEMD2"

;/****************************************************************************************\
;*                              Contours retrieving                                       *
;\****************************************************************************************/

;Retrieves outer and optionally inner boundaries of white (non-zero) connected components in the black (zero) background
cvFindContours: make routine! compose/deep/only [
	image 			[int];         CvArr!
	storage 		[struct! (first CvMemStorage!)]
	first_contour	[struct!(first CvSeq**)]
	;first_contour	[integer!]; double pointer to CvSeq**
	header_size		[integer!];CV_DEFAULT(sizeof(CvContour))
	mode			[integer!];CV_DEFAULT(CV_RETR_LIST)
	method			[integer!];CV_DEFAULT(CV_CHAIN_APPROX_SIMPLE)
	offset_x		[integer!]; cvPoint CV_DEFAULT(cvPoint(0,0))
	offset_y		[integer!];cvPoint CV_DEFAULT(cvPoint(0,0))
	return: 		[integer!]
] cvision "cvFindContours"

{Initalizes contour retrieving process. Calls cvStartFindContours.
Calls cvFindNextContour until null pointer is returned or some other condition becomes true.
Calls cvEndFindContours at the end.}
cvStartFindContours: make routine! compose/deep/only [
	image 			[int];         CvArr!
	storage 		[struct! (first CvMemStorage!)]
	header_size		[integer!];CV_DEFAULT(sizeof(CvContour))
	mode			[integer!];CV_DEFAULT(CV_RETR_LIST)
	method			[integer!];CV_DEFAULT(CV_CHAIN_APPROX_SIMPLE)
	offset_x		[integer!]; cvPoint CV_DEFAULT(cvPoint(0,0))
	offset_y		[integer!];cvPoint CV_DEFAULT(cvPoint(0,0))
	return: 		[integer!]; pointer to CvContourScanner
] cvision "cvStartFindContours"

;Retrieves next contour
cvFindNextContour: make routine! compose/deep/only [
		scanner [struct! (first int-ptr!)]; CvContourScanner
		return: [struct! (first CvSeq!)]	
] cvision "cvFindNextContour"

;Substitutes the last retrieved contour with the new one 
;(if the substitutor is null, the last retrieved contour is removed from the tree)

cvSubstituteContour: make routine! compose/deep/only [
		scanner [struct! (first int-ptr!)]; CvContourScanner
		new_contour [struct! (first CvSeq!)]	
] cvision "cvFindNextContour"

;Releases contour scanner and returns pointer to the first outer contour
cvEndFindContours: make routine! compose/deep/only [
		scanner [struct! (first int-ptr!)]; CvContourScanner
		return: [struct! (first CvSeq!)]	
] cvision "cvEndFindContours"

;Approximates a single Freeman chain or a tree of chains to polygonal curves
cvApproxChains: make routine! compose/deep/only [
	src_seq				[struct!(first CvSeq!)]
	storage				[struct! (first CvMemStorage!)]
	method				[decimal!];CV_DEFAULT(0)
	parameter			[integer!];CV_DEFAULT(0)
	minimal_perimeter	[integer!];CV_DEFAULT(0)
	recursive			[integer!];CV_DEFAULT(0)
	return: 			[struct!(first CvSeq!)]	
]cvision "cvApproxChains"

{Initalizes Freeman chain reader.
The reader is used to iteratively get coordinates of all the chain points.
If the Freeman codes should be read as is, a simple sequence reader should be used}
cvStartReadChainPoints: make routine! compose/deep/only [
	chain		[struct! (first CvChain!)]
	reader		[struct! (first CvChainPtReader!)]
] cvision "cvStartReadChainPoints"

;Retrieves the next chain point 
cvReadChainPoint: make routine! compose/deep/only [
	reader		[struct! (first CvChainPtReader!)]
	return		[struct! (first CvPoint!)]
] cvision "cvReadChainPoint"


;*                                  Motion Analysis                                       *
;************************************ optical flow ***************************************

cvCalcOpticalFlowLK: make routine! compose/deep/only  [
"Calculates optical flow for 2 images using classical Lucas & Kanade algorithm "
            prev                    [int];         CvArr!
            curr                    [int];         CvArr!
            win_width               [integer!] ;_CvSize
            win_height              [integer!] ;_CvSize
            velx                    [int];         CvArr!
            vely                    [int];         CvArr!
] cvision "cvCalcOpticalFlowLK"

cvCalcOpticalFlowBM: make routine! compose/deep/only [
"Calculates optical flow for 2 images using block matching algorithm "
            prev                    [int];         CvArr!
            curr                    [int];         CvArr!
            win_width               [integer!] ;_CvSize
            win_height              [integer!] ;_CvSize
            shift_width             [integer!] ;_CvSize
            shift_height            [integer!] ;_CvSize
            max_width               [integer!] ;_CvSize
            max_height              [integer!] ;_CvSize
            use_previous            [integer!]
            velx                    [int];         CvArr!
            vely                    [int];         CvArr!
] cvision "cvCalcOpticalFlowBM" 


cvCalcOpticalFlowHS: make routine! compose/deep/only [
"Calculates Optical flow for 2 images using Horn & Schunck algorithm"
            prev                    [int];         CvArr!
            curr                    [int];         CvArr!
            use_previous            [integer!]
            velx                    [int];         CvArr!
            vely                    [int];         CvArr!
            lambda                  [decimal!]
            criteria                [struct! (first CvTermCriteria!)]
] cvision "cvCalcOpticalFlowHS"
        
CV_LKFLOW_PYR_A_READY:       1
CV_LKFLOW_PYR_B_READY:       2
CV_LKFLOW_INITIAL_GUESSES:   4        
        
cvCalcOpticalFlowPyrLK:  make routine! compose/deep/only  [
"It is Lucas & Kanade method, modified to use pyramids"
            prev                    [int];         CvArr!
            curr                    [int];         CvArr!
            prev_features           [struct! (first CvPoint2D32f!)] ; *pointer 
            curr_features           [struct! (first CvPoint2D32f!)] ;*pointer 
            count                   [integer!]
            win_width               [integer!] ;_CvSize
            win_height              [integer!] ;_CvSize
            level                   [integer!]
            status                  [string!]
            track_error             [struct! (first float-ptr!)]; pointer
            criteria                [struct! (first CvTermCriteria!)]
            flags                   [integer!]
] cvision "cvCalcOpticalFlowPyrLK"

if opencvVersion > 1.0.0 [

cvCalcAffineFlowPyrLK: make routine! compose/deep/only [
"Modification of a previous sparse optical flow algorithm to calculate affine flow "
            prev                    [int];         CvArr!
            curr                    [int];         CvArr!
            prev_pyr                [int];         CvArr!
            curr_pyr                [int];         CvArr!
            prev_features           [struct! (first CvPoint2D32f!)] ; *pointer 
            curr_features           [struct! (first CvPoint2D32f!)] ;*pointer 
            matrices                [struct! (first float-ptr!)]
            count                   [integer!]
            win_width               [integer!] ;_CvSize
            win_height              [integer!] ;_CvSize
            level                   [integer!]
            status                  [string!]
            track_error             [struct! (first float-ptr!)]; pointer
            criteria                [struct! (first CvTermCriteria!)]
            flags                   [integer!]
]  cvision "cvCalcAffineFlowPyrLK"       
     
cvEstimateRigidTransform:  make routine! compose/deep/only [
"Estimate rigid transformation between 2 images or 2 point sets"
            A                       [int];         CvArr!
            B                       [int];         CvArr!
            M                       [int];         CvArr!
            full_affine             [integer!]
            return:                 [integer!]
] cvision "cvEstimateRigidTransform"
]
;******************************** motion templates *************************************/

;/****************************************************************************************\
;*        All the motion template functions work only with single channel images.         *
;*        Silhouette image must have depth IPL_DEPTH_8U or IPL_DEPTH_8S                   *
;*        Motion history image must have depth IPL_DEPTH_32F,                             *
;*        Gradient mask - IPL_DEPTH_8U or IPL_DEPTH_8S,                                   *
;*        Motion orientation image - IPL_DEPTH_32F                                        *
;*        Segmentation mask - IPL_DEPTH_32F                                               *
;*        All the angles are in degrees, all the times are in milliseconds                *
;\****************************************************************************************/
 
cvUpdateMotionHistory: make routine! compose/deep/only [
"Updates motion history image given motion silhouette"
            silhouette              [int];         CvArr!
            mhi                     [int];         CvArr!
            timestamp               [decimal!]
            duration                [decimal!]
] cvision "cvUpdateMotionHistory"
               
cvCalcMotionGradient: make routine! compose/deep/only [
"Calculates gradient of the motion history image and fills a mask indicating where the gradient is valid "
            mhi                     [int];         CvArr!
            mask                    [int];         CvArr!
            orientation             [int];         CvArr!
            delta1                  [decimal!]
            delta2                  [decimal!]
            aperture_size           [integer!] ;CV_DEFAULT(3))
] cvision "cvCalcMotionGradient" 
        
cvCalcGlobalOrientation: make routine! compose/deep/only [
{Calculates average motion direction within a selected motion region 
(region can be selected by setting ROIs and/or by composing a valid gradient mask
 with the region mask) }
            orientation             [int];         CvArr!
            mask                    [int];         CvArr!
            mhi                     [int];         CvArr!
            timestamp               [decimal!]
            duration                [decimal!]
            return:                 [decimal!]
] cvision "cvCalcGlobalOrientation"    

cvSegmentMotion: make routine! compose/deep/only [
"Splits a motion history image into a few parts corresponding to separate independent motions (e.g. left hand, right hand)"
            mhi                     [int];         CvArr!
            seg_mask                [int];         CvArr!
            storage                 [struct! (first CvMemStorage!)]
            timestamp               [decimal!]
            seg_thresh              [decimal!]
            return:                 [struct!(first CvSeq!)]; a pointer to CvSeq
] cvision "cvSegmentMotion"  

;*********************** Background statistics accumulation *****************************/
cvAcc:  [
"Adds image to accumulator"
            image                   [int];         CvArr!
            sum                     [int];         CvArr!
            mask                    [int];         CvArr! ; CV_DEFAULT(NULL))
] cvision "cvAcc"  

cvSquareAcc:  make routine! compose/deep/only [
"Adds squared image to accumulator"
            image                   [int];         CvArr!
            sum                     [int];         CvArr!
            mask                    [int];         CvArr! ; CV_DEFAULT(NULL))
]  cvision "cvSquareAcc"    

cvMultiplyAcc: make routine! compose/deep/only [
"Adds a product of two images to accumulator"
            image1                  [int];         CvArr!
            image2                  [int];         CvArr!
            acc                     [int];         CvArr!
            mask                    [int];         CvArr! ; CV_DEFAULT(NULL))
] cvision "cvMultiplyAcc"

cvRunningAvg: make routine! compose/deep/only [
"Adds image to accumulator with weights: acc = acc*(1-alpha) + image*alpha "
            image                   [int];         CvArr!
            acc                     [int];         CvArr!
            alpha                   [decimal!]
            mask                    [int];         CvArr! ; CV_DEFAULT(NULL))
] cvision "cvRunningAvg"

;******************************** Tracking ********************************
cvCamShift: make routine! compose/deep/only [
"Implements CAMSHIFT algorithm - determines object position, size and orientation from the object histogram back project (extension of meanshift)"
            prob_image              [int];         CvArr!
            window_x                [integer!] ;_CvRect
            window_y                [integer!]
            window_w                [integer!]
            window_h                [integer!]
            criteria                [struct! (first CvTermCriteria!)]
            comp                    [struct! (first CvConnectedComp!)]
            *box                    [struct! (first CvBox2D!)] ; pointer CV_DEFAULT(NULL)
            return:                 [integer!]
] cvision "cvCamShift"

cvMeanShift: make routine! compose/deep/only [
"Implements MeanShift algorithm -determines object position from the object histogram back project"
            prob_image              [int];         CvArr!
            window_x                [integer!] ;_CvRect
            window_y                [integer!]
            window_w                [integer!]
            window_h                [integer!]
            criteria                [struct! (first CvTermCriteria!)]
            comp                    [struct! (first CvConnectedComp!)]  
            return:                 [integer!]
] cvision "cvMeanShift"

cvCreateConDensation: make routine! compose/deep/only [
        "Creates ConDensation filter state"
            dynam_params            [integer!]
            measure_params          [integer!]
            sample_count            [integer!]
            return:                 [struct! (first CvConDensation!)]     
] cvision "cvCreateConDensation"

cvReleaseConDensation: make routine! compose/deep/only  [
"Releases ConDensation filter state"
            **condens               [struct! (first int-ptr!)]  
] cvision "cvReleaseConDensation"


cvConDensUpdateByTime: make routine! compose/deep/only  [
"Updates ConDensation filter by time (predict future state of the system)"
            *condens               [struct! (first CvConDensation!)]    ; pointer 
] cvision "cvConDensUpdateByTime"
  
cvConDensInitSampleSet: make routine! compose/deep/only [
"Updates ConDensation filter by time (predict future state of the system)"
            condens                 [struct! (first CvConDensation!)]
            lower_bound             [struct! (first CvMat!)]
            upper_bound             [struct! (first CvMat!)]
] cvision "cvConDensInitSampleSet"
        
cvCreateKalman: make routine! compose/deep/only  [
        "Creates Kalman filter and sets A, B, Q, R and state to some initial values"
            dynam_params            [integer!]
            measure_params          [integer!]
            control_params          [integer!] ;CV_DEFAULT(0)
            return:                 [struct! (first CvKalman!)]
] cvision "cvCreateKalman"

cvReleaseKalman: make routine! compose/deep/only [
        "Releases Kalman filter state"
            kalman                  [struct! (first int-ptr!)] ; double ptr
] cvision "cvReleaseKalman"

cvKalmanPredict: make routine! compose/deep/only [
        "Updates Kalman filter by time (predicts future state of the system)"
            kalman                  [struct! (first CvKalman!)]
            control                 [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            return:                 [struct! (first CvMat!)]
] cvision "cvKalmanPredict" 

cvKalmanCorrect: make routine! compose/deep/only  [
"Updates Kalman filter by measurement (corrects state of the system and internal matrices)"
            kalman                  [struct! (first CvKalman!)]
            measurement             [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            return:                 [struct! (first CvMat!)]
] cvision "cvKalmanCorrect"
        

;********************************Planar subdivisions *************************
cvInitSubdivDelaunay2D:  make routine! compose/deep/only   [
"Initializes Delaunay triangulation"
            subdiv                  [struct! (first CvSubdiv2D!)]
            rect_x                  [integer!] ;_CvRect
            rect_y                  [integer!]
            rect_w                  [integer!]
            rect_h                  [integer!]
] cvision "cvInitSubdivDelaunay2D"

cvCreateSubdiv2D:  make routine! compose/deep/only [
"Creates new subdivision"
            subdiv_type             [integer!]
            header_size             [integer!]
            vtx_size                [integer!]
            uadedge_size            [integer!]
            storage                 [struct! (first CvMemStorage!)]
            return:                 [struct! (first CvSubdiv2D!)]
] cvision "cvCreateSubdiv2D"

cvSubdiv2DLocate: make routine! compose/deep/only  [
"Locates a point within the Delaunay triangulation (finds the edgethe point is left to or belongs to, or the triangulation point the given point coinsides with"
            subdiv                  [struct! (first CvSubdiv2D!)]
            pt_x                    [decimal!] ;_CvPoint2D32f
            pt_y                    [decimal!]
            edge                    [struct! (first CvSubdiv2D!)]
            vertex                  [struct! (first int-ptr!)] ;CvSubdiv2DPoint**  CV_DEFAULT(NULL)
            return:                 [CvSubdiv2DPointLocation] ; enum not a struc
] cvision "cvSubdiv2DLocate"

cvCalcSubdivVoronoi2D: make routine! compose/deep/only [
"Calculates Voronoi tesselation (i.e. coordinates of Voronoi points) "
            subdiv                  [struct! (first CvSubdiv2D!)]
] cvision  "cvCalcSubdivVoronoi2D"

cvClearSubdivVoronoi2D:  make routine! compose/deep/only  [
"Removes all Voronoi points from the tesselation "
            subdiv                  [struct! (first CvSubdiv2D!)]
] cvision "cvClearSubdivVoronoi2D"

cvFindNearestPoint2D: make routine! compose/deep/only  [
"Finds the nearest to the given point vertex in subdivision."
            subdiv                  [struct! (first CvSubdiv2D!)]
            pt_x                    [decimal!] ;_CvPoint2D32f
            pt_y                    [decimal!]
            return:                 [CvSubdiv2DPointLocation] ; enum not a struc
] cvision "cvFindNearestPoint2D"
        
;*************************** Contour Processing and Shape Analysis *************************
CV_POLY_APPROX_DP: 0
cvApproxPoly: make routine! compose/deep/only [
"Approximates a single polygonal curve (contour) or a tree of polygonal curves (contours)"
            src_seq                     [struct! (first int-ptr!)] ;void*
            header_size                 [integer!]
            storage                     [struct! (first CvMemStorage!)]
            method                      [integer!]
            parameter                   [decimal!]
            parameter2                  [integer!] ;CV_DEFAULT(0)
            return:                     [struct!(first CvSeq!)]
] cvision "cvApproxPoly"

CV_DOMINANT_IPAN: 1

cvFindDominantPoints: make routine! compose/deep/only [
"Finds high-curvature points of the contour"
            contour                     [struct!(first CvSeq!)]
            storage                     [struct! (first CvMemStorage!)]
            parameter1                  [decimal!] ;CV_DEFAULT(0)
            parameter2                  [decimal!] ;CV_DEFAULT(0)
            parameter3                  [decimal!] ;CV_DEFAULT(0)
            parameter4                  [decimal!] ;CV_DEFAULT(0)
            return:                     [struct!(first CvSeq!)] ;CV_DEFAULT(0)
] cvision "cvFindDominantPoints"

cvArcLength: make routine! compose/deep/only [
"Calculates perimeter of a contour or length of a part of contour"
            curve                       [struct! (first int-ptr!)] ;void*
            slice_start_index           [integer!]; _CvSlice  ;CV_DEFAULT(CV_WHOLE_SEQ)
            slice_end_index             [integer!]
            is_closed                   [integer!]   ; CV_DEFAULT(-1)
            return:                     [decimal!]
] cvision "cvArcLength"


cvContourPerimeter: func [[contour]] [cvArcLength contour CV_WHOLE_SEQ 1]

cvBoundingRect: make routine! compose/deep/only [
"Calculates contour boundning rectangle (update=1) or just retrieves pre-calculated rectangle (update=0)"
            points                      [int];         CvArr!
            update                      [integer!] ;CV_DEFAULT(0)
            return:                     [CvRect!]; not a pointer just a struct
] cvision "cvBoundingRect"

cvContourArea:  [
"Calculates area of a contour or contour segment"
            points                      [int];         CvArr!
            slice_start_index           [integer!] ;_CvSlice CV_DEFAULT(CV_WHOLE_SEQ))
            slice_end_index             [integer!] ;_CvSlice CV_DEFAULT(CV_WHOLE_SEQ))
            return:                     [decimal!]
] cvision "cvContourArea"


cvMinAreaRect2: make routine! compose/deep/only  [
"Finds minimum area rotated rectangle bounding a set of points"
             points                      [int];         CvArr!
             storage                     [struct! (first CvMemStorage!)] ;CV_DEFAULT(NULL)
             return:                     [CvBox2D!]
] cvision "cvMinAreaRect2"

cvMinEnclosingCircle: make routine! compose/deep/only [
"Finds minimum enclosing circle for a set of points"
            points                      [int];         CvArr!
            center                      [struct! (first CvPoint2D32f!)] ;* pointer
            radius                      [struct! (first float-ptr!)]
            return:                     [integer!]
] cvision "cvMinEnclosingCircle"

CV_CONTOURS_MATCH_I1:  1
CV_CONTOURS_MATCH_I2:  2
CV_CONTOURS_MATCH_I3:  3


cvMatchShapes: make routine! compose/deep/only [
"Compares two contours by matching their moments"
            object1                     [struct! (first int-ptr!)]
            object2                     [struct! (first int-ptr!)]
            method                      [integer!]
            parameter                   [decimal!]
            return:                     [decimal!]
] cvision "cvMatchShapes" 

cvCreateContourTree: make routine! compose/deep/only [
"Builds hierarhical representation of a contour"  
            contour                     [struct!(first CvSeq!)]
            storage                     [struct! (first CvMemStorage!)]
            threshold                   [decimal!]
            return:                     [struct! (first CvContourTree!)]          
] cvision "cvCreateContourTree"

cvContourFromContourTree:   [
"Reconstruct (completelly or partially) contour a from contour tree"
            tree                        [struct! (first CvContourTree!)]   
            storage                     [struct! (first CvMemStorage!)]
            criteria_type               [integer!] ; CvCriteria not pointed
            criteria_max_iter           [integer!]
            ctriteria_epsilon           [decimal!]
            return:                     [struct!(first CvSeq!)]
] cvision "cvContourFromContourTree"

CV_CONTOUR_TREES_MATCH_I1:  1
cvMatchContourTrees: make routine! compose/deep/only [
"Compares two contour trees"
            tree1                       [struct! (first CvContourTree!)]   
            tree2                       [struct! (first CvContourTree!)]   
            method                      [integer!]
            threshold                   [decimal!]
            return:                     [decimal!]
]cvision "cvMatchContourTrees"

cvCalcPGH: make routine! compose/deep/only  [
"Calculates histogram of a contour"
            contour                     [struct!(first CvSeq!)]
            hist                        [struct! (first CvHistogram!)]
] cvision "cvCalcPGH"
        
CV_CLOCKWISE:         1
CV_COUNTER_CLOCKWISE: 2

cvConvexHull2: make routine! compose/deep/only  [
"Calculates exact convex hull of 2d point set"
            input                       [int];         CvArr!
            hull_storage                [struct! (first int-ptr!)] ; void * ;CV_DEFAULT(NULL)
            orientation                 [integer!]  ;CV_DEFAULT(CV_CLOCKWISE)
            return_points               [integer!]   ;CV_DEFAULT(0)
            return:                     [struct!(first CvSeq!)]
] cvision "cvConvexHull2"

cvCheckContourConvexity: make routine! compose/deep/only [
"Checks whether the contour is convex or not (returns 1 if convex, 0 if not)"
            contour                       [int];         CvArr!
            return:                       [integer!]
] cvision "cvCheckContourConvexity"

cvConvexityDefects: make routine! compose/deep/only [
            contour                       [int];         CvArr!
            convexhull                    [int];         CvArr!
            storage                       [struct! (first CvMemStorage!)] ;CV_DEFAULT(NULL)
            return:                       [struct!(first CvSeq!)]
] cvision "cvConvexityDefects"


cvFitEllipse2: make routine! compose/deep/only [
"Fits ellipse into a set of 2d points"
            points                       [int];         CvArr!
            return:                      [CvBox2D!] ; may be problematic
] cvision "cvFitEllipse2"

cvMaxRect: make routine! compose/deep/only  [
            rect1                       [struct! (first CvRect!)]
            rect2                       [struct! (first CvRect!)]
            return:                     [CvRect!] ; may be problematic
] cvision "cvMaxRect"

cvBoxPoints: make routine! compose/deep/only  [
"Finds coordinates of the box vertices "
            box_center_x                    [decimal!]  ;CvBox2D
            box_center_y                    [decimal!]  ;CvBox2D
            box_size_width                  [decimal!]  ;CvBox2D
            box_size_height                 [decimal!]  ;CvBox2D
            box_angle                       [decimal!]  ;CvBox2D
            pt_4                            [struct! (first float-ptr!)] ; pointeur array 4 float32
] cvision "cvBoxPoints"

cvPointSeqFromMat: make routine! compose/deep/only  [
"Initializes sequence header for a matrix (column or row vector) of points - a wrapper for cvMakeSeqHeaderForArray (it does not initialize bounding rectangle!!!)"
            seq_kind                        [integer!]
            mat                             [int];         CvArr!
            contour_header                  [struct! (first CvContour!)]
            block                           [struct! (first CvSeqBlock!)]
            return:                         [struct!(first CvSeq!)]
] cvision "cvPointSeqFromMat"

cvPointPolygonTest: make routine! compose/deep/only [      
            contour                         [int];         CvArr!
            pt_x                            [decimal!]
            pt_y                            [decimal!]
            measure_dist                    [integer!]
            return:                         [decimal!]
] cvision "cvPointPolygonTest"
        
;*********************************** Histogram functions ****************************
cvCreateHist: make routine! compose/deep/only [
"Creates new histogram"
            dims                            [integer!]
            sizes                           [struct! (first int-ptr!)]
            type                            [integer!]
            ranges                          [struct! (first int-ptr!)]	; ** float CV_DEFAULT(NULL)
            uniform                         [integer!]         				 ;CV_DEFAULT(1)
            return:                         [struct! (first CvHistogram!)]
] cvision "cvCreateHist"
  
cvSetHistBinRanges: make routine! compose/deep/only [
"Assignes histogram bin ranges"
            hist                            [struct! (first CvHistogram!)]
            ranges                          [struct! (first float-ptr!)]; **float
            uniform                         [integer!]          ;CV_DEFAULT(1)
] cvision "cvSetHistBinRanges"
  
cvMakeHistHeaderForArray: make routine! compose/deep/only [
"Creates histogram header for array"
            dims                            [integer!]
            sizes                           [struct! (first int-ptr!)]
            data                           	[struct! (first float-ptr!)]
            ranges                          [struct! (first float-ptr!)]; ** float CV_DEFAULT(NULL)
            uniform                         [integer!]
            return:                         [struct! (first CvHistogram!)]
] cvision "cvMakeHistHeaderForArray"

cvReleaseHist: make routine! compose/deep/only [
"Releases histogram"
            CvHistogram                     [struct! (first int-ptr!)]
] cvision "cvReleaseHist"

cvClearHist: make routine! compose/deep/only  [
            hist                            [struct! (first CvHistogram!)]
] cvision "cvClearHist"

cvGetMinMaxHistValue: make routine! compose/deep/only [
"Finds indices and values of minimum and maximum histogram bins"
            hist                            [struct! (first CvHistogram!)]
            min_value                       [struct! (first float-ptr!)]
            max_value                       [struct! (first float-ptr!)]
            min_idx                         [struct! (first int-ptr!)] ;CV_DEFAULT(NULL)
            max_idx                         [struct! (first int-ptr!)] ;CV_DEFAULT(NULL)
] cvision "cvGetMinMaxHistValue"
  
cvNormalizeHist:  make routine! compose/deep/only [
"Normalizes histogram by dividing all bins by sum of the bins, multiplied by <factor>. After that sum of histogram bins is equal to <factor>"
            hist                            [struct! (first CvHistogram!)]
            factor                          [decimal!]
] cvision "cvNormalizeHist"

cvThreshHist: make routine! compose/deep/only  [
"Clear all histogram bins that are below the threshold"
            hist                            [struct! (first CvHistogram!)]
            threshold                       [decimal!]
] cvision "cvThreshHist"

CV_COMP_CORREL:              0
CV_COMP_CHISQR:              1
CV_COMP_INTERSECT:           2
CV_COMP_BHATTACHARYYA:       3

cvCompareHist: make routine! compose/deep/only [
        "Compares two histogram"
            hist1                          [struct! (first CvHistogram!)]
            hist2                          [struct! (first CvHistogram!)]
            method                         [integer!]
            return:                        [decimal!]
] cvision "cvCompareHist"

cvCopyHist: make routine! compose/deep/only [
"Copies one histogram to another. Destination histogram is created if the destination pointer is NULL"
            src                          [struct! (first CvHistogram!)]
            dst                          [struct! (first int-ptr!)] ;CvHistogram**
] cvision "cvCopyHist"

cvCalcBayesianProb: make routine! compose/deep/only [
"Calculates bayesian probabilistic histograms (each or src and dst is an array of <number> histograms"
            src                         [struct! (first int-ptr!)] ;CvHistogram**
            number                      [integer!]
            dst                         [struct! (first int-ptr!)] ;CvHistogram**
] cvision "cvCalcBayesianProb"
 
cvCalcArrHist: make routine! compose/deep/only [
            arr                         [int];         CvArr! 			; ** CvArr
            hist                        [struct! (first CvHistogram!)]
            accumulate                  [integer!]          				; CV_DEFAULT(0)
            mask                        [int];         CvArr!           ;CV_DEFAULT(NULL)
] cvision "cvCalcArrHist" 

cvCalcArrBackProject: make routine! compose/deep/only [
"Calculates back project"
            image                       [int];         CvArr! ; ** CvArr
            dst                         [int];         CvArr!; * CvArr
            hist                        [struct! (first CvHistogram!)]
] cvision "cvCalcArrBackProject"
 
        
cvCalcBackProject: func [image dst hist] [cvCalcArrBackProject image dst hist]

cvCalcArrBackProjectPatch: make routine! compose/deep/only  [
"Does some sort of template matching but compares histograms of template and each window location"
            image                       [int];         CvArr! ; ** CvArr
            dst                         [int];         CvArr! ; * CvArr
            range_w                     [integer!] ; _CvSize
            range_h                     [integer!] ; _CvSize
            hist                        [struct! (first CvHistogram!)]
            method                      [integer!]
            factor                      [decimal!]
] cvision "cvCalcArrBackProjectPatch"

cvCalcBackProjectPatch: func [image dst range hist method factor] [
            cvCalcArrBackProjectPatch image dst range hist method factor   
]
   
cvCalcProbDensity:  [
"calculates probabilistic density (divides one histogram by another)"
            hist1                          [struct! (first CvHistogram!)]
            hist2                          [struct! (first CvHistogram!)]
            dst_hist                       [struct! (first CvHistogram!)]
            scale                          [decimal!]
] cvision "cvCalcProbDensity"

cvEqualizeHist: make routine! compose/deep/only [
        "equalizes histogram of 8-bit single-channel image"
            src                            [int]; [struct! (first CvArr!)]
            dst                            [int]; [struct! (first CvArr!)]
] cvision "cvEqualizeHist"

CV_VALUE:  1
CV_ARRAY:  2

cvSnakeImage:  make routine! compose/deep/only [
"Updates active contour in order to minimize its cummulative (internal and external) energy."
            image                       [struct! (first iplImage!)]
            points                      [struct! (first CvPoint!)] ;pointer
            length                      [integer!]
            alpha                       [struct! (first float-ptr!)]
            beta                        [struct! (first float-ptr!)]
            gamma                       [struct! (first float-ptr!)]
            coeff_usage                 [integer!]
            win_w                       [integer!] ; _CvSize
            win_h                       [integer!] ; _CvSize
            criteria                    [struct! (first CvTermCriteria!)]
            calc_gradient               [integer!]  ; CV_DEFAULT(1)
] cvision "cvSnakeImage"
        
cvCalcImageHomography: make routine! compose/deep/only [
"Calculates the cooficients of the homography matrix"
            line                        [struct! (first float-ptr!)]
            center                      [struct! (first CvPoint3D32f!)] ;* pointer
            intrinsic                   [struct! (first float-ptr!)]
            homography                  [struct! (first float-ptr!)]
] cvision "cvCalcImageHomography"

CV_DIST_MASK_3:   3
CV_DIST_MASK_5:   5
CV_DIST_MASK_PRECISE: 0

cvDistTransform: make routine! compose/deep/only  [
"Applies distance transform to binary image"
            src                 [int];         CvArr!
            dst                 [int];         CvArr!
            distance_type       [integer!] ; CV_DEFAULT(CV_DIST_L2)
            mask_size           [integer!] ; CV_DEFAULT(3)
            mask                [struct! (first float-ptr!)]; CV_DEFAULT(NULL)
            labels              [int];         CvArr! ; CV_DEFAULT(NULL) 
] cvision "cvDistTransform"
     
; Types of thresholding 
CV_THRESH_BINARY:      0  ; value = value > threshold ? max_value : 0       
CV_THRESH_BINARY_INV:  1  ; value = value > threshold ? 0 : max_value       
CV_THRESH_TRUNC:       2  ; value = value > threshold ? threshold : value   
CV_THRESH_TOZERO:      3  ; value = value > threshold ? value : 0           
CV_THRESH_TOZERO_INV:  4  ; value = value > threshold ? 0 : value           
CV_THRESH_MASK:        7
CV_THRESH_OTSU:        8  ; use Otsu algorithm to choose the optimal threshold value; combine the flag with one of the above CV_THRESH_* values 


cvThreshold: make routine! compose/deep/only  [
            src                 [int] ; CvArr!
            dst                 [int] ; CvArr!
            threshold           [decimal!]
            max_value           [decimal!]
            threshold_type      [integer!]
            return:             [decimal!] 
] cvision "cvThreshold"

CV_ADAPTIVE_THRESH_MEAN_C:  0
CV_ADAPTIVE_THRESH_GAUSSIAN_C:  1

;Applies adaptive threshold to grayscale image.
;The two parameters for methods CV_ADAPTIVE_THRESH_MEAN_C and CV_ADAPTIVE_THRESH_GAUSSIAN_C are:
;neighborhood size (3, 5, 7 etc.), and a constant subtracted from mean (...,-3,-2,-1,0,1,2,3,...)

cvAdaptiveThreshold: make routine! compose/deep/only [
"Applies adaptive threshold to grayscale image."
            src                 [int] ;CvArr!
            dst                 [int] ;CvArr!
            max_value           [decimal!]
            adaptive_method     [integer!]  ;CV_DEFAULT(CV_ADAPTIVE_THRESH_MEAN_C)
            threshold_type      [integer!]  ; CV_DEFAULT(CV_THRESH_BINARY)
            block_size          [integer!]  ; CV_DEFAULT(3)
            param1              [decimal!]    ; CV_DEFAULT(5))
] cvision "cvAdaptiveThreshold"

CV_FLOODFILL_FIXED_RANGE:    [shift/left 1 16]
CV_FLOODFILL_MASK_ONLY:      [shift/left 1 17]

cvFloodFill: make routine! compose/deep/only  [
"Fills the connected component until the color difference gets large enough"
            image               [int];         CvArr!
            seed_point_x        [integer!]
            seed_point_y        [integer!]
            new_val0            [decimal!]    ;CvScalar
            new_val1            [decimal!]    ;CvScalar
            new_val2            [decimal!]    ;CvScalar
            new_val3            [decimal!]    ;CvScalar
            lo_diff0            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0))
            lo_diff1            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            lo_diff2            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            lo_diff3            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            up_diff0            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0))
            up_diff1            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            up_diff2            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            up_diff3            [decimal!]    ;CvScalar CV_DEFAULT(cvScalarAll(0)
            comp                [struct! (first CvConnectedComp!)]
            flags               [integer!]  ;CV_DEFAULT(4)
            mask                [int];         CvArr!    ; CV_DEFAULT(NULL)  
] cvision "cvFloodFill"

;*********************** Feature detection  ***************************

CV_CANNY_L2_GRADIENT:  [shift/left 1 31]

cvCanny: make routine! compose/deep/only  [
            image               [int]; [struct! (first CvArr!)]
            edges               [int]; [struct! (first CvArr!)]
            threshold1          [decimal!]
            threshold2          [decimal!]
            aperture_size       [integer!] ; CV_DEFAULT(3)
] cvision "cvCanny"
        
;Applying threshold to the result gives coordinates of corners
cvPreCornerDetect: make routine! compose/deep/only [
"Calculates constraint image for corner detection Dx^2 * Dyy + Dxx * Dy^2 - 2 * Dx * Dy * Dxy."
            image               [int];         CvArr!
            edges               [int];         CvArr!
            aperture_size       [integer!] ; CV_DEFAULT(3)
] cvision "cvPreCornerDetect" 

cvCornerEigenValsAndVecs: make routine! compose/deep/only [
"Calculates eigen values and vectors of 2x2 gradient covariation matrix at every image pixel"
            image               [int];         CvArr!
            eigenvv             [int];         CvArr!
            block_size          [integer!]
            aperture_size       [integer!] ; CV_DEFAULT(3)
] cvision "cvCornerEigenValsAndVecs"

cvCornerMinEigenVal: make routine! compose/deep/only  [
        "Calculates minimal eigenvalue for 2x2 gradient covariation matrix at every image pixel"
            image               [int];         CvArr!
            eigenval            [int];         CvArr!
            block_size          [integer!]
            aperture_size       [integer!] ; CV_DEFAULT(3)
] cvision "cvCornerMinEigenVal"

cvCornerHarris: make routine! compose/deep/only[
"Harris corner detector: Calculates det(M) - k*(trace(M)^2), where M is 2x2 gradient covariation matrix for each pixel"    
            image               [int];         CvArr!
            harris_responce     [int];         CvArr!
            block_size          [integer!]
            aperture_size       [integer!] ; CV_DEFAULT(3)
            k                   [decimal!]   ; CV_DEFAULT(0.04)
] cvision "cvCornerHarris" 

cvFindCornerSubPix: make routine! compose/deep/only  [
"Adjust corner position using some sort of gradient search"
            image               [int];         CvArr!
            corners             [struct! (first CvPoint2D32f!)] ; pointer
            count               [integer!]
            win_w               [integer!] ; CvSize
            win_h               [integer!] ; CvSize
            zero_zone_w         [integer!] ; CvSize
            zero_zone_h         [integer!] ; CvSize
            criteria            [struct! (first CvTermCriteria!)]
] cvision "cvFindCornerSubPix"

cvGoodFeaturesToTrack: make routine! compose/deep/only [
"Finds a sparse set of points within the selected region that seem to be easy to track"
            image               [int];         CvArr!
            eig_image           [int];         CvArr!
            temp_image          [int];         CvArr!
            corners             [struct! (first CvPoint2D32f!)] ; pointer
            corner_count        [struct! (first int-ptr!)]
            quality_level       [decimal!]
            min_distance        [decimal!]
            mask                [int];         CvArr!   ;CV_DEFAULT(NULL)
            block_size          [integer!] ;CV_DEFAULT(3)
            use_harris          [integer!] ; CV_DEFAULT(0)
            k                   [decimal!]   ; CV_DEFAULT(0.04)
] cvision "cvGoodFeaturesToTrack"

CV_HOUGH_STANDARD: 		0
CV_HOUGH_PROBABILISTIC: 1
CV_HOUGH_MULTI_SCALE: 	2
CV_HOUGH_GRADIENT: 		3

;Finds lines on binary image using one of several methods.
;line_storage is either memory storage or 1 x <max number of lines> CvMat, its
;number of columns is changed by the function.
; method is one of CV_HOUGH_*;
;rho, theta and threshold are used for each of those methods;
;param1 ~ line length, param2 ~ line gap - for probabilistic,
;param1 ~ srn, param2 ~ stn - for multi-scale

cvHoughLines2: make routine! compose/deep/only  [
"Finds lines on binary image using one of several methods"
            image               [int] ;        CvArr!
            line_storage        [struct! (first int-ptr!)] ;*void
            method              [integer!]
            rho                 [decimal!]
            theta               [decimal!]
            threshold           [integer!]
            param1              [decimal!] ; CV_DEFAULT(0)
            param2              [decimal!] ; CV_DEFAULT(0)
            return:             [struct! (first CvSeq!)]
] cvision "cvHoughLines2"

cvHoughCircles: make routine! compose/deep/only  [
"Finds circles in the image"
            image               [int]
            circle_storage      [struct! (first int-ptr!)] ;*void
            method              [integer!]
            dp                  [decimal!]
            min_dist            [decimal!]
            param1              [decimal!] ; CV_DEFAULT(100)
            param2              [decimal!] ; CV_DEFAULT(100)
            min_radius          [integer!] ; CV_DEFAULT(0)
            max_radius          [integer!]
            return:             [struct! (first CvSeq!)]
]cvision "cvHoughCircles"
        
cvFitLine: make routine! compose/deep/only  [
"Fits a line into set of 2d or 3d points in a robust way (M-estimator technique)"
            points              [int];         CvArr!
            dist_type           [integer!]
            param               [decimal!]
            reps                [decimal!]
            aeps                [decimal!]
            line                [struct! (first float-ptr!)]
] cvision "cvFitLine"


 ;********************** Haar-like Object Detection functions ************************
        
 ;It is obsolete: convert your cascade to xml and use cvLoad instead
 cvLoadHaarClassifierCascade: make routine! compose/deep/only  [
        "Loads haar classifier cascade from a directory."
            directory           [string!]
            orig_window_size_x  [integer!]  ;CvSize
            orig_window_size_y  [integer!]  ;CvSize
            return:             [struct! (first CvHaarClassifierCascade!)]
] cvision "cvLoadHaarClassifierCascade"

cvReleaseHaarClassifierCascade: make routine! compose/deep/only   [
            cascade             [struct! (first int-ptr!)]   ;CvHaarClassifierCascade** 
] cvision "cvReleaseHaarClassifierCascade"

CV_HAAR_DO_CANNY_PRUNING:    1
CV_HAAR_SCALE_IMAGE:         2
CV_HAAR_FIND_BIGGEST_OBJECT: 4 
CV_HAAR_DO_ROUGH_SEARCH:     8

cvHaarDetectObjects: make routine! compose/deep/only [
            image               [int]; CvArr!
            cascade             [struct! (first CvHaarClassifierCascade!)]
            storage             [struct! (first CvMemStorage!)]
            scale_factor        [decimal!]  ;CV_DEFAULT(1.1)
            min_neighbors       [integer!] ; CV_DEFAULT(3)
            flags               [integer!]  ;CV_DEFAULT(0)
            min_size_w          [integer!]  ; CvSize CV_DEFAULT(cvSize(0,0))
            min_size_h          [integer!]  ; CvSize CV_DEFAULT(cvSize(0,0))
            return:             [struct!(first CvSeq!)]
] cvision "cvHaarDetectObjects" 

cvSetImagesForHaarClassifierCascade: make routine! compose/deep/only  [
        "sets images for haar classifier cascade"
            cascade             [struct! (first CvHaarClassifierCascade!)]
            sum                 [int];         CvArr!
            squm                [int];         CvArr!
            tilted_sum          [int];         CvArr!
            scale               [decimal!]
] cvision "cvSetImagesForHaarClassifierCascade"

cvRunHaarClassifierCascade: make routine! compose/deep/only  [
"runs the cascade on the specified window "
            cascade             [struct! (first CvHaarClassifierCascade!)]
            pt_x                [integer!] ; CvPoint
            pt_y                [integer!] ; CvPoint
            start_stage         [integer!] ; CV_DEFAULT(0)
            return:             [integer!]
] cvision "cvRunHaarClassifierCascade"

;******************** Camera Calibration and Rectification functions ***************
 cvUndistort2: make routine! compose/deep/only  [
"transforms the input image to compensate lens distortion"
            src                     [int];         CvArr!
            dst                     [int];         CvArr!
            intrinsic_matrix        [struct! (first CvMat!)]
            distortion_coeffs       [struct! (first CvMat!)]
] cvision "cvUndistort2"

cvInitUndistortMap: make routine! compose/deep/only [
"computes transformation map from intrinsic camera parameters that can used by cvRemap"
            intrinsic_matrix        [struct! (first CvMat!)]
            distortion_coeffs       [struct! (first CvMat!)]
            mapx                    [int];         CvArr!
            mapy                    [int];         CvArr!
] cvision "cvInitUndistortMap"

cvRodrigues2: make routine! compose/deep/only [
"converts rotation vector to rotation matrix or vice versa"
            src                     [int];         CvArr!
            dst                     [struct! (first CvMat!)]
            jacobian                [struct! (first CvMat!)] ; CV_DEFAULT(0)
            return:                 [integer!]
] cvision "cvRodrigues2" 

cvFindHomography: make routine! compose/deep/only  [
"finds perspective transformation between the object plane and image (view) plane"
            src_points                [struct! (first CvMat!)]
            dst_points                [struct! (first CvMat!)]
            homography                [struct! (first CvMat!)]
] cvision "cvFindHomography"

cvProjectPoints2: make routine! compose/deep/only [
"projects object points to the view plane using the specified extrinsic and intrinsic camera parameters"
            object_points               [struct! (first CvMat!)]
            rotation_vector             [struct! (first CvMat!)]
            translation_vector          [struct! (first CvMat!)]
            intrinsic_matrix            [struct! (first CvMat!)]
            distortion_coeffs           [struct! (first CvMat!)]
            image_points                [struct! (first CvMat!)]
            dpdrot                      [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            dpdt                        [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            dpdf                        [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            dpdc                        [struct! (first CvMat!)] ;CV_DEFAULT(NULL)
            dpddist                     [struct! (first CvMat!)] ;CV_DEFAULT(NULL)          
] cvision "cvProjectPoints2" 

cvFindExtrinsicCameraParams2: make routine! compose/deep/only  [
        "Finds extrinsic camera parameters from a few known corresponding point pairs and intrinsic parameters"
            object_points               [struct! (first CvMat!)]
            image_points                [struct! (first CvMat!)]
            intrinsic_matrix            [struct! (first CvMat!)]
            distortion_coeffs           [struct! (first CvMat!)]
            rotation_vector             [struct! (first CvMat!)]
            translation_vector          [struct! (first CvMat!)]
] cvision "cvFindExtrinsicCameraParams2"

CV_CALIB_USE_INTRINSIC_GUESS:  1
CV_CALIB_FIX_ASPECT_RATIO:     2
CV_CALIB_FIX_PRINCIPAL_POINT:  4
CV_CALIB_ZERO_TANGENT_DIST:    8

cvCalibrateCamera2: make routine! compose/deep/only  [
            object_points               [struct! (first CvMat!)]
            image_points                [struct! (first CvMat!)]
            point_counts                [struct! (first CvMat!)]
            image_size_w                [integer!] ;_CvSize
            image_size_h                [integer!] ; _CvSize
            intrinsic_matrix            [struct! (first CvMat!)]
            distortion_coeffs           [struct! (first CvMat!)]
            rotation_vectors            [struct! (first CvMat!)]   ;CV_DEFAULT(NULL)
            translation_vectors         [struct! (first CvMat!)]   ;CV_DEFAULT(NULL)
            flags                       [integer!] ;CV_DEFAULT(0)    
] cvision "cvCalibrateCamera2"

CV_CALIB_CB_ADAPTIVE_THRESH:  1
CV_CALIB_CB_NORMALIZE_IMAGE:  2
CV_CALIB_CB_FILTER_QUADS:     4

cvFindChessboardCorners: make routine! compose/deep/only  [
"Detects corners on a chessboard calibration pattern"
            image                   [struct! (first int-ptr!)]   ; *void
            pattern_size_w          [integer!]    ; _CvSize
            pattern_size_h          [integer!]    ; _CvSize
            corners                 [struct! (first CvPoint2D32f!)]; pointer
            corner_count            [struct! (first int-ptr!)] ;CV_DEFAULT(NULL)
            flags                   [integer!] ;CV_DEFAULT(CV_CALIB_CB_ADAPTIVE_THRESH)
] cvision "cvFindChessboardCorners"

cvDrawChessboardCorners: make routine! compose/deep/only   [
        "Draws individual chessboard corners or the whole chessboard detected"
            image                   [int];         CvArr!  ; 
            pattern_size_w          [integer!]    ; _CvSize
            pattern_size_h          [integer!]    ; _CvSize
            corners                 [struct! (first CvPoint2D32f!)] ; pointer
            count                   [integer!]
            pattern_was_found       [integer!]
] cvision "cvDrawChessboardCorners"

cvCreatePOSITObject: make routine! compose/deep/only [
"Allocates and initializes CvPOSITObject structure before doing cvPOSIT"
            points                  [struct! (first CvPoint2D32f!)]
            point_count             [integer!]
            return:                 [struct! (first int-ptr!)] ;CvPOSITObject
] cvision "cvCreatePOSITObject" 

cvPOSIT: make routine! compose/deep/only  [
"Runs POSIT (POSe from ITeration) algorithm for determining 3d position of an object given its model and projection in a weak-perspective case"
            posit_object            [struct! (first int-ptr!)] ;CvPOSITObject
            image_points            [struct! (first CvPoint2D32f!)]
            focal_length            [decimal!]
            criteria                [struct! (first CvTermCriteria!)] 
            rotation_matrix         [decimal!]  ; old CvMatr32f
            translation_vector      [decimal!]  ; old CvMatr32f
] cvision "cvPOSIT"

cvReleasePOSITObject: make routine! compose/deep/only  [
            posit_object            [struct! (first int-ptr!)]     ;CvPOSITObject**
] cvision "cvReleasePOSITObject"

;****************************** Epipolar Geometry ****************************
if opencvVersion > 1.0.0 [        
cvRANSACUpdateNumIters: make routine! compose/deep/only  [
"updates the number of RANSAC iterations"
            p                   [decimal!]
            err_prob            [integer!]
            model_points        [integer!]
            max_iters           [decimal!]
            return:             [integer!]
 ] cvision "cvRANSACUpdateNumIters"
]
; seens specific to opencv 1 
;cvConvertPointsHomogenious: make routine! compose/deep/only  [
;            src                   [int];  [struct! (first CvMat!)]
;            dst                    [int];  [struct! (first CvMat!)]
;] cvision "cvConvertPointsHomogenious"

;Calculates fundamental matrix given a set of corresponding points
CV_FM_7POINT: 		1
CV_FM_8POINT: 		2
CV_FM_LMEDS_ONLY:  	4
CV_FM_RANSAC_ONLY: 	8
CV_FM_LMEDS: reduce [(CV_FM_LMEDS_ONLY + CV_FM_8POINT)]
CV_FM_RANSAC:  reduce [(CV_FM_RANSAC_ONLY + CV_FM_8POINT)]

cvFindFundamentalMat: make routine! compose/deep/only  [
"Calculates fundamental matrix given a set of corresponding points"
            points1                 [struct! (first CvMat!)]
            points2                 [struct! (first CvMat!)]
            fundamental_matrix      [struct! (first CvMat!)]
            method                  [integer!]  ; CV_DEFAULT(CV_FM_RANSAC)
            param1                  [decimal!]    ; CV_DEFAULT(1.)
            param2                  [decimal!]    ; CV_DEFAULT(0.99)
            status                  [struct! (first CvMat!)]
            return:                 [integer!]
] cvision "cvFindFundamentalMat"

cvComputeCorrespondEpilines: make routine! compose/deep/only  [
"For each input point on one of images computes parameters of the corresponding epipolar line on the other image"
            points                  [struct! (first CvMat!)]
            which_image             [integer!]
            fundamental_matrix      [struct! (first CvMat!)]
            correspondent_lines     [struct! (first CvMat!)]
] cvision "cvComputeCorrespondEpilines"



; inline functions to be tested

cvCreateSubdivDelaunay2D: func [rect  storage  /local c][
"Simplified Delaunay diagram creation "
    subdiv: make struct! CvSubdiv2D! none
    c: make struct! CvQuadEdge2D! none
    subdiv: cvCreateSubdiv2D CV_SEQ_KIND_SUBDIV2D sizeof subdiv sizeof CvSubdiv2DPoint! sizeof c storage
    cvInitSubdivDelaunay2D subdiv rect/x rect/y rect/width rect/height
    subdiv
]

;************ Basic quad-edge navigation and operations ************
; edge parameter: CvSubdiv2DEdge! pointer

cvSubdiv2DNextEdge: func [ edge ] [CV_SUBDIV2D_NEXT_EDGE (edge/size)]
cvSubdiv2DRotateEdge: func [ edge  rotate [integer!]  /local e] [
    e: make struct! CvSubdiv2DEdge! none
    e/size: (edge/size and not 3) + ((edge/size + rotate) and 3)
    return: e
]

cvSubdiv2DSymEdge: func [ edge  /local e] [
    e: make struct! CvSubdiv2DEdge! none
    e/size: edge/size * edge/size
    return: e
]

;CvSubdiv2DEdge edge, CvNextEdgeType type

CVcvSubdiv2DGetEdge: func [ edge type] [
    e: make struct! CvQuadEdge2D! [edge and not 3]
    e/next: edge + to-integer type  and 3
    return: (edge and not 3) + (edge +  shift to-integer type 4 and  3)
]


;CvSubdiv2DPoint*  cvSubdiv2DEdgeOrg( CvSubdiv2DEdge edge )
;CvSubdiv2DPoint*  cvSubdiv2DEdgeDst( CvSubdiv2DEdge edge )

; a b c: CvPoint2D32f!
cvTriangleArea: func [a  b  c][ return: (b/x - a/x) * (c/y - a/y) - (b/y - a/y) * (c/x - a/x)]

;image [double-byte-ptr!] hist [CvHistogram!] accumulate [integer!] mask [CvArr!]

cvCalcHist: func [image  hist  accumulate  mask ] [
"Calculates array histogram (image : IplImage**)"
    cvCalcArrHist image hist accumulate mask
]






        







  

        















