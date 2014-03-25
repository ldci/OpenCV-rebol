#! /usr/bin/rebol
REBOL[
	Title:		"OpenCV cxtypes"
	Author:		"Franois Jouen"
	Rights:		"Copyright (c) 2012 Franois Jouen. All rights reserved."
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


do %rtypes.r ; for stand alone testing 
do %rtools.r

;from cxtypes.h
;/****************************************************************************************\
;*                             Common macros and inline functions                         *
;\****************************************************************************************/

set 'CV_PI   3.1415926535897932384626433832795
set 'CV_LOG2 0.69314718055994530941723212145818


CV_SWAP: func [a [number!] b [number!] c [number!] /local v1 v2 v3] [
	v1: b
	v2: c
	v3: a
	return [v1 v2 v3]
]
; for MIN and MAX use Rebol functions 
CV_MIN: func [a [number!] b [number!]  /local val ] [
	either (a > b) [b] [a]
]

CV_MAX: func [a [number!] b [number!]  /local val ] [
	either (a < b) [b] [a]
]

;/* min & max without jumps */

CV_IMIN: func [a [number!] b [number!]  /local val ]
	[ either a < (b - 1) [val: 1] [val: 0]
	return [a or (b or a) and val]
]

CV_IMAX: func [a [number!] b [number!]  /local val ]
	[ either a > (b - 1) [val: 1] [val: 0]
	return [a or (b or a) and val]
]


; some of these function are similar to math rebol functions
;Keep these function in order to remain compatible with OPenCV sources

CV_IABS: func [value /local val][ val: abs value return val]
CV_CMP: func [
	a 		[number!]
	b 		[number!] 
	/local val1 val2 
	]
	[ either a > (b) [val1: 1] [val1: 0]
	  either a < (b) [val2: 1] [val2: 0]
	  return [val1 - val2]
]
CV_SIGN: func  [a [number!]] [CV_CMP a 0]

cvRound: func [value  [number!]] [return round value]
cvFloor: func [value  [number!]] [return round/floor value]
cvCeil: func [value  [number!]] [return round/ceiling value]
cvSqrt: func [value  [number!]/local val] [ val: square-root value return val]
cvInvSqrt: func [value  [number!]/local val] [ val: 1.0 / square-root value return val]

; is not a number ?
cvIsNaN: func [value] [number? value]

;is infinite? 

cvIsInf: func [value [decimal!] /local result] [
        result: 0
		; to be done
	    return result
]


;random 
cvRNG: func [seed] [random/seed seed] 

cvRandInt: func [val [integer!]] [random val]
cvRandReal: func [] [
"return a decimal value beween 0 and 1. Base 16 bit"
	x: random power 2 16
	return x / power 2 16
]


;/****************************************************************************************\
;*                                  Image type (IplImage)                                 *
;\****************************************************************************************/

 {* The following definitions (until #endif)
 * is an extract from IPL headers.
 * Copyright (c) 1995 Intel Corporation.}
IPL_DEPTH_SIGN: 		to-integer #80000000

IPL_DEPTH_1U:     		1
IPL_DEPTH_8U:     		8
IPL_DEPTH_16U:   		16
IPL_DEPTH_32F:   		32

IPL_DEPTH_8S:  			(IPL_DEPTH_SIGN OR 8)
IPL_DEPTH_16S: 			(IPL_DEPTH_SIGN OR 16)
IPL_DEPTH_32S: 			(IPL_DEPTH_SIGN OR 32)


IPL_DATA_ORDER_PIXEL:  	0
IPL_DATA_ORDER_PLANE:  	1

IPL_ORIGIN_TL: 			0
IPL_ORIGIN_BL: 			1

IPL_ALIGN_4BYTES:   	4
IPL_ALIGN_8BYTES:   	8
IPL_ALIGN_16BYTES: 		16
IPL_ALIGN_32BYTES: 		32

IPL_ALIGN_DWORD:   		IPL_ALIGN_4BYTES
IPL_ALIGN_QWORD:   		IPL_ALIGN_8BYTES

IPL_BORDER_CONSTANT:   	0
IPL_BORDER_REPLICATE:  	1
IPL_BORDER_REFLECT:    	2
IPL_BORDER_WRAP:       	3

	

;IplCallBack = procedure(const Img: PIplImage; XIndex, YIndex: Integer; Mode: Integer); stdcall;


IplTileInfo!: make struct! compose/deep/only [
	IplCallBack  	[callback [int int int int int]] 	; pointer sur une fonction avec 5 params
	id				[int] 								;additional identification field
	TileData		[int]								;pointer on tile data	
	Width			[integer!]							;width of tile
	Height			[integer!]							;height of tile
] none


; basic IPL image structure
IplROI!: make struct! [
    coi 				[integer!] ;0 - no COI (all channels are selected), 1 - 0th channel is selected ..
    xOffset 			[integer!]
    yOffset 			[integer!]
    width				[integer!]
    height				[integer!]
] none


IplImage!: make struct! compose/deep/only [
    nSize 				[integer!]							; sizeof(IplImage)
    ID 					[integer!]							; version (=0)
    nChannels 			[integer!]							; Most of OpenCV functions support 1,2,3 or 4 channels
   	alphaChannel 		[integer!]							; Ignored by OpenCV */
    depth 				[integer!]							; Pixel depth in bits: 
    colorModel 			[integer!]							; Ignored by OpenCV char [4]
    channelSeq 			[integer!]							; ditto *
    dataOrder 			[integer!]							; 0 - interleaved color channels, 1 - separate color channels.
    origin 				[integer!]							; 0 - top-left origin, 1 - bottom-left origin (Windows bitmaps style). 
    align 				[integer!]							; Alignment of image rows (4 or 8).OpenCV ignores it and uses widthStep instead.
    width 				[integer!]							; Image width in pixels
    height 				[integer!]							; Image height in pixels. `
    roi					[int]; [struct! (first IplROI! )]   ; Image ROI. If NULL, the whole image is selected  we absolutely need  a pointer to IplRoi! structure when using routines with a ROI
    maskROI 			[int]; [struct! (first IplImage!)]	; Must be NULL [0]. IplImage! : pointer to maskROI if any
    imageId 			[int] ;[void*]						; "           " 
    tileInfo 			[int] ;[struct! (first IplTileInfo! )]		; [int]; here also"           "
    imageSize 			[integer!]							; Image data size in bytes
    imageData 			[int]; [char*]						; Pointer to aligned image data.     
    widthStep 			[integer!]							; Size of aligned image row in bytes.    
    BorderMode 			[integer!]							; Ignored by OpenCV.                     
    BorderConst 		[integer!]							; Ditto.                                
    imageDataOrigin		[int]	    						; Pointer to very origin of image data 
] none 


IplConvKernel!: make struct! [
	nCols 				[integer!]
    nRows 				[integer!]
    anchorX 			[integer!]
    anchorY 			[integer!]
    values 				[int]    							; pointer to int array
    nShiftR 			[integer!]
] none

IplConvKernelFP!: make struct! [
	nCols 				[integer!]
    nRows 				[integer!]
    anchorX 			[integer!]
    anchorY 			[integer!]
    values 				[int]								; pointer to float array
] none

IPL_IMAGE_HEADER: 		1
IPL_IMAGE_DATA:   		2
IPL_IMAGE_ROI:    		4

;/* extra border mode */
IPL_BORDER_REFLECT_101:  4
IPL_IMAGE_MAGIC_VAL:  	[length? third IplImage!]
CV_TYPE_NAME_IMAGE: 	"opencv-image"
IPL_DEPTH_64F:  		64 			; for storing double-precision floating point data in IplImage's

CV_IS_IMAGE_HDR: func [img /local val] [
    val: 0
    size: (length? third img) + 24
    if not none? img [val: 1]
    if (img/nSize = size) [val: val + 1]
    either val >= 1 [true] [false]  
]

CV_IS_IMAGE: func [img /local hdr data] [
	data: hdr: false
	if not none? img/imageData [data: true]
	hdr: CV_IS_IMAGE_HDR img 
    either (hdr AND data) [true] [false]
]


;for storing double-precision floating point data in IplImage's
IPL_DEPTH_64F:  		64

;/* get reference to pixel at (col,row), for multi-channel images (col) should be multiplied by number of channels */
CV_IMAGE_ELEM: func [image elemtype row col] [
    get-memory image/imageData + (image/widthStep  * row * col) sizeof to-word type? elemtype
]

{/****************************************************************************************\
*                                  Matrix type (CvMat)                                   *
\****************************************************************************************/}
CV_CN_MAX: 				64
CV_CN_SHIFT: 			3
CV_DEPTH_MAX: 			(shift/left 1 CV_CN_SHIFT) ; OK 8
CV_8U: 					0
CV_8S: 					1
CV_16U: 				2
CV_16S: 				3
CV_32S: 				4
CV_32F: 				5
CV_64F: 				6
CV_USRTYPE1: 			7

CV_MAT_DEPTH_MASK: 		CV_DEPTH_MAX - 1
CV_MAT_DEPTH: func [flags] [flags and CV_MAT_DEPTH_MASK]
CV_MAKETYPE: func [depth [integer!] cn [integer!]] [(CV_MAT_DEPTH depth + cn - 1) shift/left 1 CV_CN_SHIFT]

;alias 'CV_MAKETYPE "CV_MAKE_TYPE"

CV_8UC2: CV_MAKETYPE CV_8U 2

n: make integer!
CV_8UC1: 					CV_MAKETYPE CV_8U 1
CV_8UC2: 					CV_MAKETYPE CV_8U 2
CV_8UC3: 					CV_MAKETYPE CV_8U 3
CV_8UC4: 					CV_MAKETYPE CV_8U 4
CV_8UC_n: 					CV_MAKETYPE CV_8U (n) ;example print [ CV_8UC(5) lf ]  -> 32
CV_8SC1: 					CV_MAKETYPE CV_8S 1
CV_8SC2: 					CV_MAKETYPE CV_8S 2
CV_8SC3: 					CV_MAKETYPE CV_8S 3
CV_8SC4: 					CV_MAKETYPE CV_8S 4
CV_8SC_n: 					CV_MAKETYPE CV_8S (n)
CV_16UC1: 					CV_MAKETYPE CV_16U 1
CV_16UC2: 					CV_MAKETYPE CV_16U 2
CV_16UC3: 					CV_MAKETYPE CV_16U 3
CV_16UC4: 					CV_MAKETYPE CV_16U 4
CV_16UC_n: 					CV_MAKETYPE CV_16U (n)
CV_16SC1: 					CV_MAKETYPE CV_16S 1
CV_16SC2: 					CV_MAKETYPE CV_16S 2
CV_16SC3: 					CV_MAKETYPE CV_16S 3
CV_16SC4: 					CV_MAKETYPE CV_16S 4
CV_16SC_n: 					CV_MAKETYPE CV_16S (n)
CV_32SC1: 					CV_MAKETYPE CV_32S 1
CV_32SC2: 					CV_MAKETYPE CV_32S 2
CV_32SC3: 					CV_MAKETYPE CV_32S 3
CV_32SC4: 					CV_MAKETYPE CV_32S 4
CV_32SC_n: 					CV_MAKETYPE CV_32S (n)
CV_32FC1: 					CV_MAKETYPE CV_32F 1
CV_32FC2: 					CV_MAKETYPE CV_32F 2
CV_32FC3: 					CV_MAKETYPE CV_32F 3
CV_32FC4: 					CV_MAKETYPE CV_32F 4
CV_32FC_n: 					CV_MAKETYPE CV_32F (n)
CV_64FC1: 					CV_MAKETYPE CV_64F 1
CV_64FC2: 					CV_MAKETYPE CV_64F 2
CV_64FC3: 					CV_MAKETYPE CV_64F 3
CV_64FC4: 					CV_MAKETYPE CV_64F 4
CV_64FC_n: 					CV_MAKETYPE CV_64F (n)

CV_AUTO_STEP:  				to-integer #7FFFFFFF					 
CV_WHOLE_ARR:  				[cvslice 0 to-integer #3FFFFFFF]

CV_MAT_CN_MASK:          	(shift/left (CV_CN_MAX - 1) CV_CN_SHIFT)
CV_MAT_TYPE_MASK:        	(CV_DEPTH_MAX * (CV_CN_MAX - 1))
CV_MAT_CONT_FLAG_SHIFT: 	14
CV_MAT_CONT_FLAG:       	(shift/left 1 CV_MAT_CONT_FLAG_SHIFT )
CV_MAT_TEMP_FLAG_SHIFT:  	15
CV_MAT_TEMP_FLAG:        	shift/left 1 CV_MAT_TEMP_FLAG_SHIFT 

; Macros -> Func in rebol
CV_MAT_CN: 		func [flags] [1 + shift (flags and CV_MAT_CN_MASK) CV_CN_SHIFT]  
CV_MAT_TYPE: 	func [flags] [ flags and CV_MAT_TYPE_MASK]
CV_IS_MAT_CONT: func [flags] [flags and CV_MAT_CONT_FLAG]
CV_IS_TEMP_MAT: func [flags] [flags AND CV_MAT_TEMP_FLAG]

CV_MAGIC_MASK:       		to-integer #FFFF0000
CV_MAT_MAGIC_VAL:    		to-integer #42420000
CV_TYPE_NAME_MAT:    		"opencv-matrix"

CvMat!: make struct! [
	type 			[integer!]		; CvMat signature (CV_MAT_MAGIC_VAL), element type and flags 
	step 			[integer!]		; full row length in bytes
	;for internal use only 
	refcount 		[int]			; underlying data reference counter (a integer pointer) 
	hdr_refcount    [integer!] 		;
	data 			[int]	    	; in C an union to pointer [ uchar* ptr;short* s;int* i;float* fl;double* db;]
	rows 			[integer!]		;number of rows
	cols 			[integer!]		;number of cols
] none


CV_IS_MAT_HDR: func [mat /local v ] [ 	
	v: 0 
 	if not none? (mat) [v: v + 1]
 	if (mat/type) AND (CV_MAGIC_MASK)  = CV_MAT_MAGIC_VAL [v: v + 1]
 	if mat/cols > 0 [v: v + 1]
 	if mat/rows > 0 [v: v + 1]
 	either v = 4 [true] [false]
]  

CV_IS_MAT: func [ mat /local v ][
	v: 0 
 	if not none? (mat/data) [v: v + 1 ]
 	if CV_IS_MAT_HDR mat [v: v + 1 ]
 	either v = 2 [true] [false]
 ] 	
 

CV_IS_MASK_ARR: func [mat][(mat/type) AND CV_MAT_TYPE_MASK AND (complement CV_8S 1) = 0] ; true si = 0 
 	
CV_ARE_TYPES_EQ: func [mat1 mat2 ][(mat1/type XOR mat2/type) AND CV_MAT_TYPE_MASK = 0] ; idem

CV_ARE_CNS_EQ: func [mat1 mat2][(mat1/type XOR mat2/type) AND CV_MAT_CN_MASK = 0] ; idem

CV_ARE_DEPTHS_EQ: func [mat1 mat2][(mat1/type XOR mat2/type) AND CV_MAT_DEPTH_MASK = 0]; idem

CV_ARE_SIZES_EQ: func [mat1 mat2][(mat1/rows = mat2/rows) AND (mat1/cols = mat2/cols)]

CV_IS_MAT_CONST: func [mat] [mat/rows XOR mat/cols = 1]

CV_ELEM_SIZE1: func [type /local size_t l][ 
	size_t: sizeof to-word type? type
	l: shift/left size_t 28 OR 138682897
	shift l (((CV_MAT_DEPTH type) * 4) and 15)
]

CV_ELEM_SIZE: func [type /local tmp size_t l][
	tmp: CV_MAT_CN type
	size_t: sizeof to-word type? type
	l: shift/left (CV_MAT_CN type) (((size_t / 4) * 1 * 16384) OR 14928)
	shift l (((CV_MAT_DEPTH type) * 2) AND 3)
]

{inline constructor. No data is allocated internally!!!
(use together with cvCreateData, or use cvCreateMat instead to
get a matrix with allocated data)}

{This is a slight modification of orignal version : we directly use a binary string to be stored as pointer in m/data
To get back value use get-memory m/data size}


cvMat: func  [rows [integer!] cols [integer!] type [integer!] data [binary!]] [
	m: make struct! cvMat! none
	assert [m/type and  CV_MAT_DEPTH_MASK <= CV_64F]
	m/type: CV_MAT_MAGIC_VAL OR CV_MAT_CONT_FLAG OR type 
	m/cols: cols;
    m/rows: rows
    either rows > 1 [m/step: m/cols * CV_ELEM_SIZE type ][m/step: 0]
    m/data: string-address? data
    m/refcount: 0;
   	m/hdr_refcount: 0;
   	m
]

CV_MAT_ELEM_PTR_FAST: func [mat row [integer!] col [integer!] pix_size [integer!]][
	size: sizeof to-word type? (mat/step) 
	assert [(row < mat/rows) AND (col < mat/cols)] 
	mat/data + (size * row) + (pix_size * col)	
]

CV_MAT_ELEM_PTR: func [mat row [integer!] col [integer!]][ 
	CV_MAT_ELEM_PTR_FAST mat row col CV_ELEM_SIZE mat/type
]

CV_MAT_ELEM: func [mat elemtype [integer!] row [integer!] col [integer!]][
 	size: sizeof to-word type? (elemtype) 
	return CV_MAT_ELEM_PTR_FAST mat row col size
]

cvmGet: func [mat row [integer!] col [integer!] /local type size_t] [
	type: CV_MAT_TYPE mat/type
	size_t: sizeof to-word type? mat/step * row
	assert [(row < mat/rows) AND (col < mat/cols)]
	offset: (mat/step * row)  + (col * size_t) + (size_t * row)
	adr: mat/data + offset
	if (type = CV_32FC1) OR (type = CV_64FC1)  [s: get-memory adr size_t]
	to-decimal to-string trim s
]

cvmSet: func [mat row [integer!] col [integer!] value [decimal!] /local type size_t adr ][	
	type: CV_MAT_TYPE mat/type
	size_t: sizeof to-word type? mat/step * row
	assert [(row < mat/rows) AND (col < mat/cols)]
	offset: (mat/step * row)  + (col * size_t) + (size_t * row) ; OK for offset
	adr: mat/data + offset
	if (type = CV_32FC1) OR (type = CV_64FC1)  [set-memory adr to-binary value]
]


cvCvToIplDepth: func [type [integer!] /local depth val ] [
	depth: CV_MAT_DEPTH type
	val: 0
	either depth = CV_8S [val: IPL_DEPTH_SIGN] [val: 0]
	either depth = CV_16S [val: IPL_DEPTH_SIGN] [val: 0]
	either depth = CV_32S [val: IPL_DEPTH_SIGN] [val: 0]
    val 
]

;/****************************************************************************************\
;*                       Multi-dimensional dense array (CvMatND)                          *
;\****************************************************************************************/
CV_MATND_MAGIC_VAL:			   	to-integer #42430000
CV_TYPE_NAME_MATND:		    	"opencv-nd-matrix"
CV_MAX_DIM:			            32
CV_MAX_DIM_HEAP:                shift/left 1 16



CvMatND!: make struct! compose/deep/only [
	type 		 [integer!]
	dims 		 [integer!]
	refcount	 [int]         	; internal use
	hdr_refcount [integer!]		; idem
	data		 [int]					; pointer to an union : un variant 		 
	dim 		 [int] ; pointer to array [0..(CV_MAX_DIM)-1] of dim structures de structures
] none



CV_IS_MATND_HDR: func  [mat	/local v][ 
	v: 0 
	if not none? (mat) [v: v + 1]
	if (mat/type  and CV_MAGIC_MASK) = CV_MATND_MAGIC_VAL [v: v + 1]
	either v = 2 [true] [false]
]

CV_IS_MATND: func [mat	/local v][ 	
	v: 0 
	if not none? (mat/data) [v: v + 1]
	if CV_IS_MATND_HDR mat [v: v + 1]
	either v = 2 [true] [false]
]

;/****************************************************************************************\
;*                      Multi-dimensional sparse array (CvSparseMat)                      *
;\****************************************************************************************/

CV_SPARSE_MAT_MAGIC_VAL:    to-integer #42440000
CV_TYPE_NAME_SPARSE_MAT:    "opencv-sparse-matrix"


CvSparseMat!: make struct!  [
	type 			[integer!]
	dims 			[integer!]
	refcount		[integer!]
	heap 			[int] 		; CvSet*
	hashtable 		[int]		; void **double pointer
	hashsize 		[integer!]
	total 			[integer!]
	valoffset 		[integer!]
	idxoffset 		[integer!]
	size 			[integer!]	
] none

CV_IS_SPARSE_MAT_HDR: func [mat	/local v][ 	
	v: 0 
	if not none? (mat) [v: v + 1]
	if (mat/type AND CV_MAGIC_MASK) = CV_SPARSE_MAT_MAGIC_VAL [v: v + 1]
	either v = 2 [true] [false]
]
CV_IS_SPARSE_MAT: func [mat][CV_IS_SPARSE_MAT_HDR mat]

;/**************** iteration through a sparse array *****************/


CvSparseNode!: make struct! compose/deep/only [
	hashval		[integer!];
    next		[int] ; CvSparseNode*
] none 


Conteneur: make struct! compose/deep [noeud [struct! [(CvSparseNode!)]]] none


CvSparseMatIterator!: make struct! compose/deep/only [
	mat			[struct! (first CvSparseMat!)]
    node		[struct! (first CvSparseNode!)]
    curidx		[integer!]
] none

;[CvSparseMat!] ;[CvSparseNode!]
CV_NODE_VAL: func [ mat	node] [
	size: length? third node
    mat/valoffset + size
]

CV_NODE_IDX: func [mat	node][
	size: length? third node
	mat/idxoffset + size
]

;/****************************************************************************************\
;*                                         Histogram                                      *
;\****************************************************************************************/

 CvHistType!: 				make integer! 0
 CV_HIST_MAGIC_VAL:     	to-integer #42450000
 CV_HIST_UNIFORM_FLAG:  	(1 shift/left 10 1)
;indicates whether bin ranges are set already or not 
 CV_HIST_RANGES_FLAG:   	(1 shift/left 11 1)
 CV_HIST_ARRAY:         	0
 CV_HIST_SPARSE:        	1
 CV_HIST_TREE:          	CV_HIST_SPARSE

;should be used as a parameter only, it turns to CV_HIST_UNIFORM_FLAG of hist->type 
 CV_HIST_UNIFORM: 	       1

; mat is not a pointer but a structure. Mat must be initialised 
CvHistogram!: make struct! compose/deep/only  [
    type 			[integer!];
    bins 			[int]; ** pointer to CvArr!
    thresh			[int] ; pointer to float array [CV_MAX_DIM][2]; /* for uniform histograms */
    thresh2			[int] ; ** pointeur to float array for non-uniform histograms */
    mat				[struct! (first CvMatND!)] ; CvMatND! embedded matrix header for array histograms  */
] none

CV_IS_HIST: func [hist /local v][ 	v: 0 
	if not none? (hist) [v: v + 1]
	if hist/type  AND CV_MAGIC_MASK = CV_HIST_MAGIC_VAL [v: v + 1]
	if not none? (hist/bins) [v: v + 1]
	either v = 3 [true] [false]
]

CV_IS_UNIFORM_HIST: func [
	hist			;[CvHistogram!]
	]
	[return (hist/type AND CV_HIST_UNIFORM_FLAG) <> 0
]

CV_IS_SPARSE_HIST: func [ hist	/local v][ 
	v: 0
	if not none? (hist/bins) [v: v + 1]
	if (hist/type AND CV_MAGIC_MASK) = CV_SPARSE_MAT_MAGIC_VAL [v: v + 1]
	either v = 2 [true] [false]
]

CV_HIST_HAS_RANGES: func [hist][ hist/type AND CV_HIST_RANGES_FLAG <> 0]

;/****************************************************************************************\
;*                      Other supplementary data type definitions                         *
;\****************************************************************************************/


;/*************************************** CvRect *****************************************/     

; In REBOL we can also directly use structures
; for example aRect: make struct! CvRect! [0 5 10 100] is equivalent to aRect: cvRect 0 5 10 200
; second arect: access to values in the structures
; struct-address? arect : access to the adress of structure!
; we keep inline functions for compatibility

CvRect!: make struct!  [
	x 		[integer!]
	y 		[integer!]
	width 	[integer!]
	height 	[integer!]
] none

; returns a CvRect! structure
cvRect: func [x [number!] y [number!] width [number!] height [number!] /local r][
    r: make struct! CvRect! [0 0 0 0]
	r/x: 		to-integer x
	r/y: 		to-integer y
	r/width: 	to-integer width
	r/height: 	to-integer height
	r
]

; CvRect! structure as parameter returns a IplROI! structure
cvRectToROI: func [rect  coi [integer!] /local roi][
	roi: make struct! IplROI! [0 0 0 0 0]
	roi/xOffset: rect/x
    roi/yOffset: rect/y
    roi/width: rect/width
    roi/height: rect/height
    roi/coi: to-integer coi
	roi
]



; returns a CvRect! structure from a IplROI! structure
cvROIToRect: func [roi /local r] [
	r: make struct! cvRect! [0 0 0 0]
	r/x: 		roi/xOffset
	r/y: 		roi/yOffset
	r/width: 	roi/width
	r/height: 	roi/height
	r
]


;/*********************************** CvTermCriteria *************************************/

CV_TERMCRIT_ITER:    		1
TERMCRIT_NUMBER:	  		CV_TERMCRIT_ITER
CV_TERMCRIT_EPS:     		2

CvTermCriteria!: make struct! [
	type		[integer!] ;  may be combination of  CV_TERMCRIT_ITER CV_TERMCRIT_EPS
	max_iter	[integer!]
	epsilon		[decimal!]
] none

cvTermCriteria: func [type [number!] max_iter [number!] epsilon [number!] /local t][
	t: make struct! CvTermCriteria! [0 0 0.0]
	t/type: to-integer type
	t/max_iter: to-integer max_iter
    t/epsilon: to-decimal epsilon
	t
]


;/******************************* CvPoint and variants ***********************************/

CvPoint!: make struct! [
	x 	[integer!]
	y 	[integer!]
] none

; returns a CvPoint! structure
cvPoint: func [x [number!] y [number!] /local p][
	p: make struct! cvPoint! [0 0]
	p/x: to-integer x
	p/y: to-integer y
	p
]

CvPoint2D32f!: make struct! [
	x 	[decimal!]
	y 	[decimal!]
] none

CvPoint3D32f!: make struct! [
	x 	[decimal!]
	y 	[decimal!]
	z 	[decimal!]
] none

; returns a CvPoint2D32f! structure
cvPoint2D32f: func [x [number!] y [number!] /local p][
	p: make struct! CvPoint2D32f! [0 0]
	p/x: to-decimal x
	p/y: to-decimal y
	p
]


; returns a CvPoint2D32f! structure from CvPoint!
cvPointTo32f: func [xy /local p][
		p: make struct! CvPoint2D32f! [0 0]  
		p/x: first second xy
        p/y: second second xy 
        p
]

; returns a CvPoint! structure from a cvPoint2D32f! structure
cvPointFrom32f: func [xy  /local p ][
		p: make struct! cvPoint! [0 0]
		p/x: to-integer first second xy
		p/y: to-integer second second xy 
        p
]

CvPoint2D64f!: make struct! [
	x 	[decimal!]
	y 	[decimal!]
] none

; returns a cvPoint2D64f! structure

cvPoint2D64f: func [x [number!] y [number!] /local p][
	p: make struct! CvPoint2D64f! [0 0] 
	p/x: to-decimal x
	p/y: to-decimal y
	p
]

CvPoint3D64f!: make struct! [
	x 	[decimal!]
	y 	[decimal!]
	z 	[decimal!]
] none


; returns a cvPoint3D64f! structure

cvPoint3D64f: func [x  [number!] y  [number!] z [number!] /local p][
	p: make struct! CvPoint3D64f! [0 0 0]
	p/x: to-decimal x
	p/y: to-decimal y
	p/z: to-decimal z
	p
]



;/******************************** CvSize's & CvBox **************************************/

CvSize!: make struct! [
	width 	[integer!]
	height 	[integer!]
] none

; returns a CvSize! structure
cvSize: func [width [number!] height [number!] /local s] [
	s: make struct! cvSize! [0 0]
	s/width: to-integer width
	s/height: to-integer height
	s
]

CvSize2D32f!: make struct! [
	width		[decimal!]
	height 		[decimal!]
] none


cvSize2D32f: func [width  [number!] height [number!] /local s][
    s: make struct! cvSize2D32f! [0 0]
    s/width: to-decimal width
    s/height: to-decimal height
    s
]


cvBox2D!: make struct!  [
     ;center of the box
	 center  [struct! [
					x 	[decimal!]
					y 	[decimal!]
					z 	[decimal!]]
	 ]
	 ;box width and length
    size 	[struct! [
				width	[decimal!]
				height 	[decimal!]]
	]
    angle 	[decimal!]	;angle between the horizontal axis and the first side (i.e. length) in degrees
] none



;/* Line iterator state */

CvLineIterator!: make struct! [
    uchar 		[int] 			;Pointer to the current point
    err 		[integer!]		;Bresenham algorithm state 
    plus_delta 	[integer!]
    minus_delta [integer!]
    plus_step 	[integer!]
    minus_step 	[integer!]
] none

;/************************************* CvSlice ******************************************/

CvSlice!: make struct! [ 
	start_index [integer!]
	end_index [integer!]
] none


cvSlice: func [start_index [integer!] end_index  [integer!] /local slice][
    slice: make struct! CvSlice! [0 0]
    slice/start_index: to-integer start_index
    slice/end_index: to-integer end_index
    slice
]


CV_WHOLE_SEQ_END_INDEX: to-integer #3FFFFFFF
CV_WHOLE_SEQ: cvSlice 0 CV_WHOLE_SEQ_END_INDEX
;/************************************* CvScalar *****************************************/
; cvColor is not included in openCV; just facilitation for rebol

CvColor!: make struct! [
	b 		[integer!]
	g 		[integer!]
	r 		[integer!]
	alpha 	[integer!]
] none

cvColor: func [r g b  alpha /local c] [
	c: make struct! CvColor! none
	c/b: 	b
	c/g: 	g
	c/r:	r
	c/alpha: alpha
	c
]



; tableau de 4 float ;double val[4];
;typedef struct CvScalar
;{
;;    double val[4]; val est un pointeur sur un array de 4 decimaux
;}
;CvScalar;

; one peut pas utiliser les blocks donc on passe par une structure

CvScalar!: make struct! [
	v0 [decimal!]
	v1 [decimal!]
	v2 [decimal!]
	v3 [decimal!]
] none



cvScalar: func [v0 v1 v2 v3] [
	c: make struct! cvScalar! [0 0 0 0]
	c/v0: to-decimal v0
	c/v1: to-decimal v1
	c/v2: to-decimal v2
	c/v3: to-decimal v3
	return  c
]


cvRealScalar: func [v0 [number!] /local c][
	c: make struct! cvScalar! [0 0 0 0]
	c/v0: to-decimal v0
	c/v1: 0.0
	c/v2: 0.0
	c/v3: 0.0
	return c
]



cvScalarAll: func [
	v0 [number!] ;should be double
	/local c
	][
	c: make struct! cvScalar! [0 0 0 0]
	c/v0: to-decimal v0
	c/v1: to-decimal v0
	c/v2: to-decimal v0
	c/v3: to-decimal v0
	return  c
]


;/****************************************************************************************\
;*                                   Dynamic Data structures                              *
;\****************************************************************************************/

;/******************************** Memory storage ****************************************/

cvMemBlock!: make struct! [
	prev 		[int] ;cvMemBlock*
	next 		[int] ;cvMemBlock*
] none

;cvMemBlock*: make struct! compose/deep [node_type [struct! [(cvMemBlock!)]]] none

CV_STORAGE_MAGIC_VAL:   to-integer #42890000 

cvMemStorage!: make struct!  [
	signature 		[integer!]		;OK when creataed
	bottom 			[int]			; pointer cvMemBlock* first allocated block */
	top 			[int]			; pointer cvMemBlock* current memory block - top of the stack */
	parent 			[int]			; pointer to cvMemStorage!* We get new blocks from parent as needed. */
	block_size 		[integer!]		; block size */
    free_space 		[integer!]		; free space in the current block */
] none

;cvMemStorage*: make struct! compose/deep [node_type [struct! [(cvMemStorage!)]]] none


CV_IS_STORAGE: func [storage /local v][ 
	v: 0
	if not none? (storage) [v: v + 1]
	if (storage/signature AND CV_MAGIC_MASK = CV_STORAGE_MAGIC_VAL) [v: v + 1]
	either v = 2 [true] [false]
] ; OK

cvMemStoragePos: make struct!  [
    *top 			[int] ;CvMemBlock!
    free_space 		[integer!]
] none

;/*********************************** Sequence *******************************************/
CvSeqBlock!: make struct! compose/deep/only [
    prev 			[int]				; previous sequence block :  CvSeqBlock*
    next 			[int]				; next sequence block :  CvSeqBlock*
    start_index 	[integer!]			; index of the first element in the block + sequence->first->start_index */
    count 			[integer!]	 		; number of elements in the block */
    data 			[int]				; pointer to the first element of the block */
] none

;we combine CV_TREE_NODE_FIELDS  CV_SEQUENCE_FIELDS


CvSeq!: make struct![
	flags           		[integer!]      ;micsellaneous flags
	header_size     		[integer!]      ;size of sequence header
    h_prev                 	[int]    		;pointer to CvSeq! struct:  previous sequence  
    h_next                	[int]     		;pointer to CvSeq! struct: next sequence 
    v_prev                 	[int]    		;pointer to  CvSeq! struct: 2nd previous sequence 
    v_next                 	[int]      		;pointer to CvSeq! struct 2nd next sequence 
    total                   [integer!]      ;total number of elements
    elem_size               [integer!]      ;size of sequence element in bytes 
    block_max              	[int]    	    ; maximal bound of the last block char*
    ptr                    	[int]    		;current write pointer
    delta_elems             [integer!]      ;how many elements allocated when the seq grows
    storage                 [int]   		;CvMemStorage! where the seq is stored
    free_blocks             [int]     		;CvSeqBlock! free blocks list 
    first                   [int]     		;CvSeqBlock! pointer to the first sequence block 
] none





CvSeq**: make struct! compose/deep/only [seq [struct!(first CvSeq!)]] none


CV_TYPE_NAME_SEQ:             "opencv-sequence"
CV_TYPE_NAME_SEQ_TREE:        "opencv-sequence-tree"

;/*************************************** Set ********************************************/
{
  Set.
  Order is not preserved. There can be gaps between sequence elements.
  After the element has been inserted it stays in the same place all the time.
  The MSB(most-significant or sign bit) of the first field (flags) is 0 iff the element exists.
}



CvSetElem!: make struct! [
	flags [integer!]				;                        
    next_free [int];
] none


;we combine CV_SET_FIELDS! and CV_SEQUENCE_FIELDS()   in a  struct
CvSet!: make struct! [
	flags           		[integer!]      ;micsellaneous flags
	header_size     		[integer!]      ;size of sequence header
    h_prev                 	[int]    		;struct previous sequence  CvSeq! 
    h_next                	[int]    		;struct next sequence CvSeq!
    v_prev                 	[int]    		;struct 2nd previous sequence CvSeq!
    v_next                 	[int]     		;struct 2nd next sequence CvSeq!
    total                   [integer!]      ;total number of elements
    elem_size               [integer!]      ;size of sequence element in bytes 
    block_max              	[int]    		; maximal bound of the last block
    ptr                    	[int]    		;current write pointer
    delta_elems             [integer!]      ;how many elements allocated when the seq grows
    storage                 [int]   		;CvMemStorage! where the seq is stored
    free_blocks             [int]     		;CvSeqBlock! free blocks list 
    first                   [int]     		;CvSeqBlock! pointer to the first sequence block
	free_elems				[int]			;CvSetElem!  
    active_count 			[integer!]	 
]none


CV_SET_ELEM_IDX_MASK:   ((1 shift/left 26 1) - 1)
CV_SET_ELEM_FREE_FLAG:   (1 shift/left 31 1)

;/* Checks whether the CvSetElem! element pointed by ptr belongs to a set or not */
CV_IS_SET_ELEM: func [ ptr ] [
either ptr != 0 [
	flags: to-integer reverse get-memory ptr + 0 4
	next_free: to-integer reverse get-memory ptr + 4 4
	flags >= 0] 
	[false]
]

;/************************************* Graph ********************************************/

{
  Graph is represented as a set of vertices.
  Vertices contain their adjacency lists (more exactly, pointers to first incoming or
  outcoming edge (or 0 if isolated vertex)). Edges are stored in another set.
  There is a single-linked list of incoming/outcoming edges for each vertex.

  Each edge consists of:
    two pointers to the starting and the ending vertices (vtx[0] and vtx[1],
    respectively). Graph may be oriented or not. In the second case, edges between
    vertex i to vertex j are not distingueshed (during the search operations).

    two pointers to next edges for the starting and the ending vertices.
    next[0] points to the next edge in the vtx[0] adjacency list and
    next[1] points to the next edge in the vtx[1] adjacency list.
}

CvGraphEdge!: make struct! [
    flags			[integer!];        
    weight			[integer!];    
    next			[int] ; pointer struct CvGraphEdge*  
    vtx				[int] ; pointer struct CvGraphVtx* 
] none

CvGraphVtx!: make struct! [
	flags				[integer!];                
    first 				[int] ; pointer struct CvGraphEdge! ;
] none

CvGraphVtx2D!: make struct! compose/deep/only [
    flags				[integer!];                
    first 				[int] ; pointer struct CvGraphEdge* ;
    ptr 				[int] ; CvPoint2D32f!
] none

;Graph is "derived" from the set (this is set a of vertices) and includes another set (edges)


CvGraph!: make struct!  [
    flags           		[integer!]      ;micsellaneous flags
	header_size     		[integer!]      ;size of sequence header
    h_prev                 	[int]    		;struct previous sequence  CvSeq! 
    h_next                	[int]    		;struct next sequence CvSeq!
    v_prev                 	[int]    		;struct 2nd previous sequence CvSeq!
    v_next                 	[int]     		;struct 2nd next sequence CvSeq!
    total                   [integer!]      ;total number of elements
    elem_size               [integer!]      ;size of sequence element in bytes 
    block_max              	[int]    		; maximal bound of the last block
    ptr                    	[int]    		;current write pointer
    delta_elems             [integer!]      ;how many elements allocated when the seq grows
    storage                 [int]   		;CvMemStorage! where the seq is stored
    free_blocks             [int]     		;CvSeqBlock! free blocks list 
    first                   [int]     		;CvSeqBlock! pointer to the first sequence block
	free_elems				[int]			;CvSetElem!  
    active_count 			[integer!]	 
    edges					[int]			; pointer to CvSet
] none

CV_TYPE_NAME_GRAPH:			 "opencv-graph"

;/*********************************** Chain/Countour *************************************/

CvChain!: make struct!  [
	r 		[int] ;CvSeq!
    origin 	[int] ;CvPoint!
] none

CV_CONTOUR_FIELDS!: make struct!  [
    r 			[int]  ;CvSeq!
    rect  		[int]  ;CvRect!      
    color 		[integer!];          
    reserved 	[integer!];
] none

CvContour!: make struct! 
[
    ptr [int] ;CV_CONTOUR_FIELDS!
] none

CvPoint2DSeq!: make struct!  [ ptr [struct![(first CvContour!)]]] none

;/****************************************************************************************\
;*                                    Sequence types                                      *
;\****************************************************************************************/

CV_SEQ_MAGIC_VAL:             to-integer 42990000

CV_IS_SEQ: func [seq] [
    return seq != NULL and  (CvSeq!/seq/flags and CV_MAGIC_MASK) = CV_SEQ_MAGIC_VAL
]
CV_SET_MAGIC_VAL:             to-integer #42980000

CV_IS_SET: func [aset]
    [ return aset != NULL and (CvSeq!/aset/flags and CV_MAGIC_MASK) = CV_SET_MAGIC_VAL]
    
CV_SEQ_ELTYPE_BITS:           9
CV_SEQ_ELTYPE_MASK:           (1 shift/left CV_SEQ_ELTYPE_BITS - 1 1)
CV_SEQ_ELTYPE_POINT:          CV_32SC2	;  /* (x,y) */
CV_SEQ_ELTYPE_CODE:           CV_8UC1   ;/* freeman code: 0..7 */
CV_SEQ_ELTYPE_GENERIC:        0
CV_SEQ_ELTYPE_PTR:            CV_USRTYPE1
CV_SEQ_ELTYPE_PPOINT:         CV_SEQ_ELTYPE_PTR ;  /* &(x,y) */
CV_SEQ_ELTYPE_INDEX:          CV_32SC1  ;/* #(x,y) */
CV_SEQ_ELTYPE_GRAPH_EDGE:     0  ;/* &next_o, &next_d, &vtx_o, &vtx_d */
CV_SEQ_ELTYPE_GRAPH_VERTEX:   0  ;/* first_edge, &(x,y) */
CV_SEQ_ELTYPE_TRIAN_ATR:      0  ;/* vertex of the binary tree   */
CV_SEQ_ELTYPE_CONNECTED_COMP: 0  ;/* connected component  */
CV_SEQ_ELTYPE_POINT3D:        CV_32FC3  ;/* (x,y,z)  */
CV_SEQ_KIND_BITS:	          3
CV_SEQ_KIND_MASK:	         ((1 shift/left CV_SEQ_KIND_BITS - 1 1 ) shift/left CV_SEQ_ELTYPE_BITS 1)

;/* types of sequences */
CV_SEQ_KIND_GENERIC:	     	(0 shift/left CV_SEQ_ELTYPE_BITS 1)
CV_SEQ_KIND_CURVE:       		(1 shift/left CV_SEQ_ELTYPE_BITS 1)
CV_SEQ_KIND_BIN_TREE:     		(2 shift/left CV_SEQ_ELTYPE_BITS 1)

;/* types of sparse sequences (sets) */
CV_SEQ_KIND_GRAPH:		        (3 shift/left CV_SEQ_ELTYPE_BITS 1)
CV_SEQ_KIND_SUBDIV2D:    		(4 shift/left CV_SEQ_ELTYPE_BITS 1)
CV_SEQ_FLAG_SHIFT:		        (CV_SEQ_KIND_BITS + CV_SEQ_ELTYPE_BITS)

;/* flags for curves */
CV_SEQ_FLAG_CLOSED:     	(1 shift/left CV_SEQ_FLAG_SHIFT 1)
CV_SEQ_FLAG_SIMPLE:     	(2 shift/left CV_SEQ_FLAG_SHIFT 1)
CV_SEQ_FLAG_CONVEX:     	(4 shift/left CV_SEQ_FLAG_SHIFT 1)
CV_SEQ_FLAG_HOLE:       	(8 shift/left CV_SEQ_FLAG_SHIFT 1)

;/* flags for graphs */
CV_GRAPH_FLAG_ORIENTED:		 (1 shift/left CV_SEQ_FLAG_SHIFT 1)
CV_GRAPH:	                 CV_SEQ_KIND_GRAPH
CV_ORIENTED_GRAPH:	        (CV_SEQ_KIND_GRAPH OR CV_GRAPH_FLAG_ORIENTED)

;/* point sets */
 CV_SEQ_POINT_SET:	    	 (CV_SEQ_KIND_GENERIC OR  CV_SEQ_ELTYPE_POINT)
 CV_SEQ_POINT3D_SET:	     (CV_SEQ_KIND_GENERIC OR  CV_SEQ_ELTYPE_POINT3D)
 CV_SEQ_POLYLINE:	         (CV_SEQ_KIND_CURVE   OR  CV_SEQ_ELTYPE_POINT)
 CV_SEQ_POLYGON:	         (CV_SEQ_FLAG_CLOSED  OR  CV_SEQ_POLYLINE )
 CV_SEQ_CONTOUR:	         CV_SEQ_POLYGON
 CV_SEQ_SIMPLE_POLYGON:	     (CV_SEQ_FLAG_SIMPLE  OR  CV_SEQ_POLYGON )
 
 ;/* chain-coded curves */
CV_SEQ_CHAIN:	           (CV_SEQ_KIND_CURVE  OR CV_SEQ_ELTYPE_CODE)
CV_SEQ_CHAIN_CONTOUR:	   (CV_SEQ_FLAG_CLOSED OR CV_SEQ_CHAIN)

;/* binary tree for the contour */
CV_SEQ_POLYGON_TREE:	    (CV_SEQ_KIND_BIN_TREE  OR CV_SEQ_ELTYPE_TRIAN_ATR)

;/* sequence of the connected components */
CV_SEQ_CONNECTED_COMP:	  (CV_SEQ_KIND_GENERIC  OR CV_SEQ_ELTYPE_CONNECTED_COMP)

;/* sequence of the integer numbers */
CV_SEQ_INDEX:	           (CV_SEQ_KIND_GENERIC  OR CV_SEQ_ELTYPE_INDEX)

CV_SEQ_ELTYPE: func [seq] [return seq/flags AND CV_SEQ_ELTYPE_MASK]
CV_SEQ_KIND: func [seq] [return seq/flags AND CV_SEQ_KIND_MASK ]

;/* flag checking */
 CV_IS_SEQ_INDEX: func [seq] [return (CV_SEQ_ELTYPE(seq) = CV_SEQ_ELTYPE_INDEX) and
                                     (CV_SEQ_KIND(seq) = CV_SEQ_KIND_GENERIC)]

CV_IS_SEQ_CURVE: func [seq] [return CV_SEQ_KIND(seq) = CV_SEQ_KIND_CURVE]
CV_IS_SEQ_CLOSED: func [seq] [return (seq/flags AND CV_SEQ_FLAG_CLOSED) != 0]
CV_IS_SEQ_CONVEX: func [seq] [return (seq/flags AND CV_SEQ_FLAG_CONVEX) != 0]
CV_IS_SEQ_HOLE: func [seq] [return (seq/flags AND CV_SEQ_FLAG_HOLE) != 0]
CV_IS_SEQ_SIMPLE: func [seq] [return (seq/flags AND CV_SEQ_FLAG_SIMPLE) != 0 OR CV_IS_SEQ_CONVEX seq]

;/* type checking macros */
CV_IS_SEQ_POINT_SET: func [seq] [return (CV_SEQ_ELTYPE seq = CV_32SC2) OR (CV_SEQ_ELTYPE seq  = CV_32FC2)]
CV_IS_SEQ_POINT_SUBSET: func [seq] [return  (CV_IS_SEQ_INDEX seq  OR CV_SEQ_ELTYPE seq) = CV_SEQ_ELTYPE_PPOINT]
CV_IS_SEQ_POLYLINE: func [seq] [return (CV_SEQ_KIND seq = CV_SEQ_KIND_CURVE) AND CV_IS_SEQ_POINT_SET seq]
CV_IS_SEQ_POLYGON: func [seq] [return CV_IS_SEQ_POLYLINE seq AND CV_IS_SEQ_CLOSED seq]
CV_IS_SEQ_CHAIN: func [seq] [return (CV_SEQ_KIND seq = CV_SEQ_KIND_CURVE) AND seq/elem_size = 1]
CV_IS_SEQ_CONTOUR: func [seq] [return (CV_IS_SEQ_CLOSED seq AND CV_IS_SEQ_POLYLINE seq) OR CV_IS_SEQ_CHAIN seq]
CV_IS_SEQ_CHAIN_CONTOUR: func [seq] [return CV_IS_SEQ_CHAIN seq  AND CV_IS_SEQ_CLOSED seq]
CV_IS_SEQ_POLYGON_TREE: func [seq] [
	return(CV_SEQ_ELTYPE seq =  CV_SEQ_ELTYPE_TRIAN_ATR) AND (CV_SEQ_KIND seq  =  CV_SEQ_KIND_BIN_TREE)
]
CV_IS_GRAPH: func [seq] [return (CV_IS_SET seq AND CV_SEQ_KIND CvSet!/seq) = CV_SEQ_KIND_GRAPH]
CV_IS_GRAPH_ORIENTED: func [seq][return (seq/flags AND CV_GRAPH_FLAG_ORIENTED) != 0]
CV_IS_SUBDIV2D: func [seq][return (CV_IS_SET seq AND CV_SEQ_KIND CvSet!seq) = CV_SEQ_KIND_SUBDIV2D]

;/****************************************************************************************/
;/*                            Sequence writer & reader                                  */
;/****************************************************************************************/
CV_SEQ_WRITER_FIELDS!: make struct!  [                                    
    header_size [integer!];                                      
    seq			[int]		;CvSeq* the sequence written
    block 		[int]		;CvSeqBlock* current block
    ptr			[int]		;pointer to free space          
    block_min	[int]		; pointer to the beginning of block
    block_max	[int]		; pointer to the end of block
] none

CvSeqWriter!: make struct! compose/deep/only  [ 
   	ptr 		[struct! (first CV_SEQ_WRITER_FIELDS!)] ;CV_SEQ_WRITER_FIELDS!
] none


CV_SEQ_READER_FIELDS!: make struct!  [                                    
    header_size [integer!]                                      
    seq			[int]		;CvSeq* sequence, beign read
    block 		[int]		;CvSeqBlock* current block
    ptr			[int]		;pointer to element be read next           
    block_min	[int]		;pointer to the beginning of block
    block_max	[int]		;pointer to the end of block
    delta_index [int]		;= seq/first/start_index
    prev_elem   [int]		;pointer to previous element
] none

CvSeqReader!: make struct!  compose/deep/only [ 
   ptr 			[struct! (first CV_SEQ_READER_FIELDS!)] ;CV_SEQ_READER_FIELDS!
] none

;/****************************************************************************************/
;/*                                Operations on sequences                               */
;/****************************************************************************************/

CV_SEQ_ELEM: func [seq elem_type index /local val]
[
	val: 0
	if assert [size? seq/first = Size? CvSeqBlock!] [val: val + 1] 
	if assert [size? seq/elem_size = Size? elem_type] [val: val + 1] 
	return val
]



CV_GET_SEQ_ELEM: func [elem_type seq index ] [CV_SEQ_ELEM (seq) elem_type (index)]

;/* macro that adds element to sequence


CV_WRITE_SEQ_ELEM_VAR: func [elem_ptr writer]     
[      
	&writer: as int-ptr! writer                                              
    if (writer/ptr >= writer/block_max ) [ cvCreateSeqBlock &writer] ;new seq to add
    writer/ptr: get-memory elem_ptr writer/seq/ptr/elem_size ; copy memory dest source size 
    writer/ptr: writer/ptr + writer/seq/elem_size; ; increase struct address
]

CV_WRITE_SEQ_ELEM: func [elem writer]             
[         
	&writer: as byte-ptr! writer                                             
    assert [writer/seq/elem_size = size? elem]
    if (writer/ptr >= writer/block_max ) [ cvCreateSeqBlock &writer] ;make pointer &writer                                              
    assert [writer/ptr <= writer/block_max - size? elem]
    &elem: as byte-ptr! elem ; 
    writer/ptr: get-memory &elem size? elem
    ;memcpy((writer).ptr, &(elem), sizeof(elem));      
    writer/ptr:  writer/ptr + size? elem                    
]

; move reader position forward */
CV_NEXT_SEQ_ELEM: func [elem_size reader]                
[           
	&reader: as byte-ptr! reader                                                
    if (reader/ptr + elem_size >= reader/block_max ) [cvChangeSeqBlock  &reader 1 ] ;&reader                                                       
]

;/* move reader position backward */
CV_PREV_SEQ_ELEM: func [elem_size reader]              
[         
	&reader: as byte-ptr! reader                                                      
    if (reader/ptr - elem_size < reader/block_min) [cvChangeSeqBlock  &reader 1 ] ;&reader                                                    
]

;/* read element and move read position forward */
CV_READ_SEQ_ELEM: func [elem_size reader]  
[                                                                                  
    assert [reader/seq/elem_size = size? elem]    
    &elem: as byte-ptr! elem      
    &elem: get-memory reader/ptr size? elem
    ;memcpy( &(elem), (reader).ptr, sizeof((elem)));            
    CV_NEXT_SEQ_ELEM size? elem reader                  
]
 
;/* read element and move read position backward */
CV_REV_READ_SEQ_ELEM: func [elem_size reader]                     
[                                                                
    assert [reader/seq/elem_size = size? elem] 
    &elem: as byte-ptr! elem      
    &elem: get-memory reader/ptr size? elem           
    ;memcpy(&(elem), (reader).ptr, sizeof((elem)));               
    CV_PREV_SEQ_ELEM size? elem reader                     
]


CV_READ_CHAIN_POINT: func [_pt reader]                              
[                                                                       
    _pt: reader.pt                                                
    if (reader/ptr )                                                  
    [                                                                   
        CV_READ_SEQ_ELEM reader/code reader                     
        assert [reader/code and 7 = 0 ]                            
        eader/pt/x: reader/pt/x +  reader/deltas/1 ;deltas[(int)(reader).code][0]
        reader/pt/y: reader/pt/y +  reader/deltas/2 ;deltas[(int)(reader).code][1] 
    ]                                                                  
]

;OK
CV_CURRENT_POINT: func [reader /local p] 
[	
	p: make struct! cvPoint! [0 0]
	p/x: reader/ptr/x
	p/y: reader/ptr/y
	return p
]

CV_PREV_POINT: func [reader /local p] 
[	
	p: make struct! cvPoint! [0 0]
	p/x: reader/prev_elem/x
	p/y: reader/prev_elem/y
	return p
]

CV_READ_EDGE: func [pt1 pt2 reader]               
[                                                      
    assert [(size? pt1 = size? CvPoint!) AND          
            (size? pt2 = size? CvPoint) AND          
            (reader/seq/elem_size = size? CvPoint!)] 
    pt1: CV_PREV_POINT reader                   
    pt2: CV_CURRENT_POINT reader                
	reader/prev_elem: reader/ptr                 
    CV_NEXT_SEQ_ELEM size? CvPoint! reader      
]

;/************ Graph macros ************/

;/* returns next graph edge for given vertex */
CV_NEXT_GRAPH_EDGE: func [edge vertex][                              
    assert edge/vtx/1 = vertex OR
    assert edge/vtx/2 = vertex OR
    assert edge/next/vtx/1 = vertex
]

;/****************************************************************************************\
;*             Data structures for persistence (a.k.a serialization) functionality        *
;\****************************************************************************************/
;
;/* "black box" file storage */
;typedef struct CvFileStorage CvFileStorage;

;/* storage flags */
CV_STORAGE_READ:          0
CV_STORAGE_WRITE:         1
CV_STORAGE_WRITE_TEXT:    CV_STORAGE_WRITE
CV_STORAGE_WRITE_BINARY:  CV_STORAGE_WRITE
CV_STORAGE_APPEND:        2


;/* list of attributes */
CvAttrList!: make struct! [
	attr		[string!] 						; NULL-terminated array of (attribute_name,attribute_value) pairs
    next		[int]	; CvAttrList* pointer to next chunk of the attributes list
] none

CvAttrList*: make struct!  [attribute [struct! [(CvAttrList!)]]] none

cvAttrList: func [attr next ] [
;( const char** attr CV_DEFAULT(NULL), CvAttrList* next CV_DEFAULT(NULL) )
    l: make struct! CvAttrList! none
    l/attr: attr;
    l/next: next;
    return l
]

;struct CvTypeInfo;

CV_NODE_NONE:        0
CV_NODE_INT:         1
CV_NODE_INTEGER:     CV_NODE_INT
CV_NODE_REAL:        2
CV_NODE_FLOAT:       CV_NODE_REAL
CV_NODE_STR:         3
CV_NODE_STRING:      CV_NODE_STR
CV_NODE_REF:         4 ;not used
CV_NODE_SEQ:         5
CV_NODE_MAP:         6
CV_NODE_TYPE_MASK:   7
CV_NODE_TYPE: func [flags] [ return flags AND CV_NODE_TYPE_MASK]
 
; /* file node flags */
CV_NODE_FLOW:        8 ;used only for writing structures to YAML format
CV_NODE_USER:        16
CV_NODE_EMPTY:       32
CV_NODE_NAMED:       64
CV_NODE_IS_INT: func [flags]  [return CV_NODE_TYPE flags = CV_NODE_INT]
CV_NODE_IS_REAL: func [flags]  [return CV_NODE_TYPE flags = CV_NODE_REAL]
CV_NODE_IS_STRING: func [flags] [return CV_NODE_TYPE = CV_NODE_STRING]
CV_NODE_IS_SEQ: func [flags] [return CV_NODE_TYPE = CV_NODE_SEQ]
CV_NODE_IS_MAP: func [flags] [return CV_NODE_TYPE flags = CV_NODE_MAP]
CV_NODE_IS_COLLECTION: func [flags] [return CV_NODE_TYPE flags >= CV_NODE_SEQ]
CV_NODE_IS_FLOW: func [flags] [return (flags AND CV_NODE_FLOW) != 0]
CV_NODE_IS_EMPTY: func [flags] [return(flags AND CV_NODE_EMPTY) != 0]
CV_NODE_IS_USER: func [flags] [return (flags AND CV_NODE_USER) != 0]
CV_NODE_HAS_NAME: func [flags] [return (flags AND CV_NODE_NAMED) != 0]
CV_NODE_SEQ_SIMPLE: 256
CV_NODE_SEQ_IS_SIMPLE: func [seq] [return (seq/flags AND CV_NODE_SEQ_SIMPLE) != 0]

CvString!: make struct! [
	len 	[integer!]
    ptr		[string!]
] none

{all the keys (names) of elements in the readed file storage
are stored in the hash to speed up the lookup operations }


CvStringHashNode!: make struct!  [
    hashval			[integer!];
    str				[string!]							; should be CvString!
    next			[int]		;pointer to  CvStringHashNode* ;
] none


CvTypeInfo!: make struct!  [
    flags				[integer!];
    header_size			[integer!];
    prev				[int]	; pointer CvTypeInfo;
    next				[int]	; pointer CvTypeInfo;
    type_name			[string!];
    is_instance			[int]	;pointer to function CvIsInstanceFunc
    release				[int]	;pointer to function CvReleaseFunc ;
    read				[int]  ;CvReadFunc ;
    write				[int]  ;CvWriteFunc write;
    clone				[int]  ;CvCloneFunc ;
] none




CvFileNode!: make struct!  [
    tag			[integer!];
    info 		[int]	; CvTypeInfo* info; /* type information (only for user-defined object, for others it is 0) */
    data 		[int] 	; void  ; pointer to union
    {   double f; /* scalar floating-point number 
        int i;    /* scalar integer number
        CvString str; /* text string
        CvSeq* seq; /* sequence (ordered collection of file nodes)
        CvFileNodeHash* map; /* map (collection of named file nodes)
    }
] none

;/**** System data types ******/

CvPluginFuncInfo!: make struct!  [
    func_addr			[int]		; void pointer
    default_func_addr	[int]		; void pointer
    func_names			[string!]
    search_modules		[integer!]
    loaded_from			[integer!]
] none

CvModuleInfo!:  make struct!  [
    next			[int]		;pointer CvModuleInfo;
    name			[string!]
    version			[string!]
    func_tab		[int]		; pointer CvPluginFuncInfo! ;
] none



