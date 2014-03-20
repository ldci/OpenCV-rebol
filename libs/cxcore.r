#! /usr/bin/rebol
REBOL[
	Title:		"OpenCV cxcore"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2014 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

; for stand alone testing

do %rtypes.r ; for stand alone testing 
do %rtools.r
do %cxtypes.r
do %cvtypes.r ; needs %cxtypes.r



;/****************************************************************************************\
;*          Array allocation, deallocation, initialization and access to elements         *
;\****************************************************************************************/

;/* <malloc> wrapper.
;If there is no enough memory, the function (as well as other OpenCV functions that call cvAlloc raises an error. */

cvAlloc: make routine! [
	size    [integer!]
    return: [string!]
] cxcore "cvAlloc"

;/* <free> wrapper.

cvFree: make routine! [
	ptr		[integer!]
] cxcore "cvFree_"

;Rebol Specific ; normally we have to use a CvSize! structure to creates images or header
; but rebol returns a block of value so we used 2 integers (width and height)


cvCreateImageHeader: make routine! compose/deep/only [
"Allocates and initializes IplImage header"
	width 		[integer!]; CvSize/width
	height 		[integer!]; CvSize/height
	depth		[integer!]
	channels    [integer!]
	return: 	[struct! (first IplImage!)] 
]cxcore "cvCreateImageHeader"


cvInitImageHeader: make routine! compose/deep/only [
"Inializes IplImage header"
	image		[int] 			; IplImage!
	width 		[integer!]		; CvSize/width
	height 		[integer!]		; CvSize/height
	depth		[integer!]
	channels	[integer!]
	origin		[integer!]		;CV_DEFAULT(0)
	align		[integer!]		;CV_DEFAULT(4)
	return: 	[struct! (first IplImage!)] 
]cxcore "cvInitImageHeader"

cvCreateImage: make routine! compose/deep/only[
"Creates IPL image (header and data);create new image"
	width 		[integer!]	; CvSize/width
	height 		[integer!]	; CvSize/height
	depth 		[integer!]
	channels 	[integer!]
	return: 	[struct! (first IplImage!)] ; returns an iplImage structure
] cxcore "cvCreateImage"

;orginal OpenCV
cvReleaseImageHeader_: make routine! compose/deep/only[
"Releases (i.e. deallocates) IPL image header"
	image		[struct! (first int-ptr!)] ; double pointeur
] cxcore "cvReleaseImageHeader"

;REBOL
cvReleaseImageHeader: func [image] [
	free-mem image
]

; orginal OPenCV
cvReleaseImage_: make routine! compose/deep/only[
"Releases IPL image header and data"
	image		[int] ; IplImage! ; double pointer to IplImage** image	
] cxcore "cvReleaseImage"

;Rebol: better
cvReleaseImage: func [image] [
	free-mem image
]


cvCloneImage: make routine! compose/deep/only[
"Creates a copy of IPL image (widthStep may differ) "
	image		[int] 						; IplImage!
	return: 	[struct! (first IplImage!)] ; returns an iplImage structure
] cxcore "cvCloneImage"

cvSetImageCOI: make routine! [
{Sets a Channel Of Interest (only a few functions support COI)
use cvCopy to extract the selected channel and/or put it back}
	image		[int] 		; IplImage!
    coi			[integer!]
] cxcore "cvSetImageCOI"


cvGetImageCOI: make routine!  [
"Retrieves image Channel Of Interest"
	image		[int] 		; IplImage!
	return:		[integer!]
] cxcore "cvGetImageCOI"


cvSetImageROI: make routine!  [
"Sets image ROI (region of interest) (COI is not changed)"
	image		[int] 		; IplImage!	
	rect_x		[integer!]  ; CvRect/x 
    rect_y		[integer!]	; CvRect/y
    rect_w		[integer!]  ; CvRect/width 
    rect_h		[integer!]  ; CvRect/height 
]cxcore "cvSetImageROI"

cvResetImageROI: make routine! [
"Resets image ROI and COI"
	image		[int] ; IplImage!
] cxcore "cvResetImageROI"

;OpenCV
cvGetImageROI_: make routine! [
"Retrieves image ROI"
	image		[int] ; IplImage! 
	return: 	reduce [int int int int] ; CvRect not a pointer
] cxcore "cvGetImageROI" 


; inline rebol version OK

cvGetImageROI: func [image] [
	; get values associated to IplImage	pointer
	blocValues: getIPLValues/address image
    ptr: blocValues/13 ; ROI value
    ;Roi exists
    if ptr <> 0 [roiValues: get-memory ptr 24
        	coi: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	xOffset: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	yOffset: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	width: to-integer copy/part roiValues 4
        	roiValues: skip roiValues 4
        	height: to-integer copy/part roiValues 4
     ]
    ; No Roi : all window
    if ptr = 0 [
            roi: 0
        	coi: 0
        	xOffset: 0
        	yOffset: 0
        	width: blocValues/11; image/width 
        	height: blocValues/12 ; image/height 
    ]
     reduce [xOffset yOffset width height]
]


cvCreateMatHeader: make routine! compose/deep/only[ 
"Allocates and initalizes CvMat header"
	rows		[integer!]
	cols		[integer!]
	type		[integer!]
	return:		[struct! (first CvMat!)]
]cxcore "cvCreateMatHeader"

CV_AUTOSTEP:  to-integer #7fffffff

cvInitMatHeader: make routine! compose/deep/only [ 
"Initializes CvMat header"
	mat			[int] 		; CvMat!
	rows		[integer!]
	cols		[integer!]
	type		[integer!]
	data    	[int] 		;  ; void* pointer
	step		[integer!] 	; CV_DEFAULT(CV_AUTOSTEP)
	return:		[struct! (first CvMat!)]
] cxcore "cvInitMatHeader"
  
cvCreateMat: make routine! compose/deep/only [
"Allocates and initializes CvMat header and allocates data"
 	rows		[integer!]
 	cols		[integer!]
 	type 		[integer!]
 	return:		[struct! (first CvMat!)]
]cxcore "cvCreateMat" 

;OpenCV
cvReleaseMat_: make routine! compose/deep/only [
"Releases CvMat header and deallocates matrix data (reference counting is used for data)"
	mat		 [struct! (first int-ptr!)] ; double pointer
] cxcore "cvReleaseMat"

;REBOL
cvReleaseMat: func [mat] [
	free-mem mat
]

;/* Decrements CvMat data reference counter and deallocates the data if it reaches
; inline function, not included in library. 
;use pointer to CvMat! To be tested with Rebol !!!!

cvDecRefData: func  [mat]
[
    if  (CV_IS_MAT mat)
    [
        mat/data: none
        if (mat/refcount != none)  and (mat/refcount = 0) [cvFree [mat/refcount]
        mat/refcount: none]
    ] 
    if (CV_IS_MATND mat)
    [
        mat/data: none
        if (mat/refcount != none)  and (mat/refcount = 0) [cvFree [mat/refcount]
        mat/refcount: none]
    ]
]

;Increments CvMat data reference counter */
cvIncRefData: func  [mat]
[
    refcount: 0
    if  (CV_IS_MAT mat)
    [
        if (mat/refcount != none) [refcount: refcount + 1 mat/refcount: refcount]
    ]
    if (CV_IS_MATND mat)
    [
       if (mat/refcount != none) [refcount: refcount + 1 mat/refcount: refcount]
    ]
    return refcount
]

cvCloneMat: make routine! compose/deep/only [
"Creates an exact copy of the input matrix (except, may be, step value)"
	mat			[int] 		; CvMat!
	return:		[struct! (first CvMat!)]
] cxcore "cvCloneMat"

cvGetSubRect: make routine! compose/deep/only [
"Makes a new matrix from <rect> subrectangle of input array No data is copied"
	arr			[int] 		; CvArr! 
	submat		[int] 		; CvMat!
	rect_x		[integer!]  ; CvRect/x 
    rect_y		[integer!]	; CvRect/y 
    rect_w		[integer!]	; CvRect/width
    rect_h		[integer!]	; CvRect/height 
	return:		[struct! (first CvMat!)]
]cxcore "cvGetSubRect"

alias 'cvGetSubRect "cvGetSubArr"

cvGetRows: make routine! compose/deep/only [
"Selects row span of the input array: arr(start_row:delta_row:end_row (end_row is not included into the span)"
	arr			[int] 		; CvArr!;pointer to generic array
	submat		[int] 		; CvMat!
	start_row   [integer!]
	end_row		[integer!]
	delta_row	[integer!] ; CV_DEFAULT(1)
	return:		[struct! (first CvMat!)]
]cxcore "cvGetRows"

; inline function
cvGetRow: func [arr submat row] [return cvGetRows arr submat row row + 1 1]

cvGetCols: make routine! compose/deep/only [
"Selects column span of the input array: arr(:,start_col:end_col) (end_col is not included into the span)"
	arr			[int] 		; CvArr!;pointer to generic array
	submat		[int] 		; CvMat!
	start_col	[integer!]
	end_col		[integer!]
	return:		[struct! (first CvMat!)]
] cxcore "cvGetCols"

; inline function
cvGetCol:func [arr submat col] [return cvGetCols arr submat col col + 1]

;Select a diagonal of the input array.
;(diag = 0 means the main diagonal, >0 means a diagonal above the main one,
;<0 - below the main one).
;The diagonal will be represented as a column (nx1 matrix).

cvGetDiag: make routine! compose/deep/only [
"Select a diagonal of the input array"
	arr			[int] 		; CvArr!;pointer to generic array;
	submat		[int] 		; CvMat!
	diag		[integer!]	;CV_DEFAULT(0)
	return:		[struct! (first CvMat!)]
]cxcore "cvGetDiag"

cvScalarToRawData: make routine! compose/deep/only [
"low-level scalar <-> raw data conversion functions"
	scalar			[struct! (first CvScalar!)]	; pointer 
	data			[int];  *void pointer
	type			[integer!]
	extend_to_12	[integer!];CV_DEFAULT(0)
] cxcore "cvScalarToRawData"

cvRawDataToScalar: make routine! compose/deep/only [
	data			[int]; *void pointer
	type			[integer!]
	scalar			[struct! (first CvScalar!)] ;pointer
	return:			[]
] cxcore "cvRawDataToScalar"

;Allocates and initializes CvMatND header
cvCreateMatNDHeader: make routine! compose/deep/only [
	dims			[integer!]
	sizes			[int] 		; pointer to an array of values 
	type			[integer!]
	return:			[struct! (first CvMatND!)]
] cxcore"cvCreateMatNDHeader"

cvCreateMatND: make routine! compose/deep/only [
"Allocates and initializes CvMatND header and allocates data"
	dims		[integer!]
	sizes		[int] 			; pointer to an array of values 
	type		[integer!]
	return:		[struct! (first CvMatND!)]
]cxcore "cvCreateMatND"

cvInitMatNDHeader: make routine! compose/deep/only [
"Initializes preallocated CvMatND header"
	mat			[int]    ;;CvMatND!
	dims		[integer!]
	sizes		[int] ; int pointer
	type		[integer!]
	data		[integer!]; *void  CV_DEFAULT(NULL)
	return:		[struct! (first CvMatND!)]
]cxcore "cvInitMatNDHeader"

;inline Releases CvMatND: use CvMatND** mat as parameter
cvReleaseMatND_: func [mat] [cvReleaseMat_ mat]      
; rebol
cvReleaseMatND: func [mat] [free-mem mat]                              

cvCloneMatND: make routine! compose/deep/only [
"Creates a copy of CvMatND (except, may be, steps)"
	mat		[int]	;CvMatND!
	return:	[struct! (first CvMatND!)]
] cxcore "cvCloneMatND"

cvCreateSparseMat: make routine! compose/deep/only[
"Allocates and initializes CvSparseMat header and allocates data"
	dims		[integer!]
	sizes		[int] ; int pointer
	type		[integer!]
	return:		[struct! (first CvSparseMat!)]
]cxcore "cvCreateSparseMat"
 
;OpenCV                                    
cvReleaseSparseMat_: make routine! compose/deep/only [
"Releases CvSparseMat"
	mat [struct! (first int-ptr!)] ;CvSparseMat** mat double pointer
]cxcore "cvReleaseSparseMat"

;REBOL
cvReleaseSparseMat: func [mat][free-mem mat]

cvCloneSparseMat: make routine! compose/deep/only [
"Creates a copy of CvSparseMat (except, may be, zero items)"
	mat 		[int]	;  CvSparseMat!
	return: 	[struct! (first CvSparseMat!)]
]cxcore "cvCloneSparseMat"

;opencv
cvInitSparseMatIterator_: make routine! compose/deep/only [
"Initializes sparse array iterator (returns the first node or NULL if the array is empty)"
	mat 			[struct! (first CvSparseMat!)]
	mat_iterator	[struct! (first CvSparseMatIterator!)]
	return: 		[struct! (first CvSparseNode!)]
]cxcore "cvInitSparseMatIterator"

; rebol : use struct!

cvInitSparseMatIterator: func [mat iterator] [
	node: make struct! CvSparseNode! none
	iterator/mat/type: mat/type
	iterator/mat/dims: mat/dims
	iterator/mat/refcount: mat/refcount
	iterator/mat/refcount: mat/refcount
	iterator/mat/heap: mat/heap
	iterator/mat/hashtable: mat/hashtable
	iterator/mat/hashsize: mat/hashsize
	iterator/mat/valoffset: mat/valoffset
	iterator/mat/idxoffset: mat/idxoffset
	iterator/mat/size: mat/size
	iterator/node/hashval: node/hashval
	iterator/node/next: node/next
	iterator/curidx: 1
	node/hashval: iterator/node/hashval
	node/next: iterator/node/next
	node

]




cvGetNextSparseNode: func [mat_iterator]
[
{returns next sparse array node (or NULL if there is no more nodes)
inline function uses CvSparseMatIterator! as parameter and returns  CvSparseNode! }
    either (mat_iterator/node/next) [return mat_iterator/node: mat_iterator/node/next]
    [
        idx: 0;
        for idx mat_iterator/curidx mat_iterator/mat/hashsize 1
        [
            node:  mat_iterator/mat/hashtable[idx]
            if (node)
            [
                mat_iterator/curidx: idx
                return [mat_iterator/node: node]
            ]
        ]
        return none;
    ]
]

;**************** matrix iterator: used for n-ari operations on dense arrays *********
CV_MAX_ARR: 10

CvNArrayIterator!: make struct! compose/deep/only
[
    count				[integer!]		; number of arrays
    dims				[integer!]      ; number of dimensions to iterate
    ;size				[struct! (first CvSize!)]; maximal common linear size: { width = size, height = 1 }
    width				[integer!]
    height!				[integer!]
    ptr					[struct![(first int-ptr!)]]	;pointers to the array slices [CV_MAX_ARR]
    stack				[integer!]		; for internal use [CV_MAX_DIM
    hdr					[integer!]		;/* pointers to the headers of the CvMatND! matrices that are processed [CV_MAX_ARR]
    									; may be we need a CvMatND! struct!  
] none

CV_NO_DEPTH_CHECK:     1
CV_NO_CN_CHECK:        2
CV_NO_SIZE_CHECK:      4

;(the function together with cvNextArraySlice is used for N-ari element-wise operations)
cvInitNArrayIterator: make routine! compose/deep/only [
"initializes iterator that traverses through several arrays simultaneously"
	count			[integer!]
	arrs			[int]		;(first CvArr!)
	mask			[int]		;(first CvArr!)
	stubs			[int]       ;CvMatND!
	array_iterator	[struct! (first CvNArrayIterator!)]
	flags			[integer!]
	return:			[integer!] 
] cxcore"cvInitNArrayIterator"


cvNextNArraySlice: make routine! compose/deep/only [
"returns zero value if iteration is finished, non-zero (slice length) otherwise "
	array_iterator	[int]		;struct! (first CvNArrayIterator!)
	return:			[integer!] 
] cxcore "cvNextNArraySlice"
 
cvGetElemType: make routine! compose/deep/only [
"returns type of array elements: CV_8UC1 ... CV_64FC4 ..."
	arr			[int]       ;CvArr!
	return:		[integer!]
] cxcore "cvGetElemType"

cvGetDims: make routine! compose/deep/only [
"retrieves number of an array dimensions and optionally sizes of the dimensions"
	arr			[int]       ;CvArr!
	sizes		[int]		; CV_DEFAULT(NULL)
	return:		[integer!]
] cxcore "cvGetDims"

cvGetDimSize: make routine! compose/deep/only [
{Retrieves size of a particular array dimension.
;For 2d arrays cvGetDimSize(arr,0) returns number of rows (image height) 
and cvGetDimSize(arr,1) returns number of columns (image width)}
	arr			[int]       ;CvArr!
	index		[integer!]	;CV_DEFAULT(NULL)
	return:		[integer!]
] cxcore "cvGetDimSize"

;ptr = &arr(idx0,idx1,...). All indexes are zero-based, the major dimensions go first (e.g. (y,x) for 2D, (z,y,x) for 3D
cvPtr1D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]	; 
	type		[int] 		; CV_DEFAULT(NULL)
	return:		[int] 		; or uchar*
] cxcore "cvPtr1D"

cvPtr2D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]	 
	idx1		[integer!]
	type		[int] 		; CV_DEFAULT(NULL)
	return:		[int] 		; or uchar*
] cxcore "cvPtr2D"

cvPtr3D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]; 
	idx1		[integer!];
	idx2		[integer!];
	type		[int] 		; CV_DEFAULT(NULL)
	return:		[int] ; or uchar*
] cxcore "cvPtr3D"

;For CvMat or IplImage number of indices should be 2
;(row index (y) goes first, column index (x) goes next).
;For CvMatND or CvSparseMat number of infices should match number of <dims> and
;indices order should match the array dimension order

cvPtrND: make routine! compose/deep/only [
	arr					[int]       ;CvArr!
	idx					[int]; 
	type				[int]		;CV_DEFAULT(NULL)
	create_node			[integer!]	;CV_DEFAULT(1)
	precalc_hashval		[int]		; CV_DEFAULT(NULL)
	return:				[int] 		; or uchar*
] cxcore "cvPtrND"

;value = arr(idx0,idx1,...)
cvGet1D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]	
	return:		[(second CvScalar!)];CvScalar not a pointer
] cxcore "cvGet1D"

cvGet2D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!];
	return:		[(second CvScalar!)] ;CvScalar not a pointer
] cxcore "cvGet2D"

cvGet3D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!];
	idx2		[integer!];
	return:		[(second CvScalar!)] ;CvScalar not a pointer			
] cxcore "cvGet3D"

cvGetND: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx			[int]
	return:		[(second CvScalar!)]	
] cxcore "cvGetND"

;for 1-channel arrays 

cvGetReal1D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	return:		[decimal!]		
] cxcore "cvGetReal1D"

cvGetReal2D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	return:		[decimal!]		
] cxcore "cvGetReal2D"

cvGetReal3D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	idx2		[integer!]
	return:		[decimal!]	
] cxcore "cvGetReal3D"

cvGetRealND: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx			[int]
	return:		[decimal!]			
] cxcore "cvGetRealND"

;arr(idx0,idx1,...) = value
cvSet1D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	v0			[decimal!] ;CvScalar not pointer
	v1			[decimal!]
	v2			[decimal!]
	v3			[decimal!]
] cxcore "cvSet1D"

cvSet2D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	v0			[decimal!] ;CvScalar not pointer
	v1			[decimal!]
	v2			[decimal!]
	v3			[decimal!]
] cxcore "cvSet2D"

cvSet3D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	idx2		[integer!]
	v0			[decimal!] ;CvScalar not pointer
	v1			[decimal!]
	v2			[decimal!]
	v3			[decimal!]
] cxcore "cvSet3D"

cvSetND: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx 		[struct![(first int-ptr!)]]
	v0			[decimal!] ;CvScalar not pointer
	v1			[decimal!]
	v2			[decimal!]
	v3			[decimal!]
] cxcore "cvSetND"

;for 1-channel arrays
cvSetReal1D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	value		[decimal!]
] cxcore "cvSetReal1D"

cvSetReal2D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	value		[decimal!]
] cxcore "cvSetReal2D"

cvSetReal3D: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx0		[integer!]
	idx1		[integer!]
	idx2		[integer!]
	value		[decimal!]
] cxcore "cvSetReal3D"

cvSetRealND: make routine! compose/deep/only [
	arr			[int]       ;CvArr!
	idx 		[int]
	value		[decimal!]
] cxcore "cvSetRealND"

cvClearND: make routine! compose/deep/only [
"clears element of ND dense array, in case of sparse arrays it deletes the specified node"
	arr			[int]
	idx 		[int]
] cxcore "cvClearND"

{Converts CvArr (IplImage or CvMat,...) to CvMat.
If the last parameter is non-zero, function can
convert multi(>2)-dimensional array to CvMat as long as
the last array's dimension is continous. The resultant
matrix will be have appropriate (a huge) number of rows}

cvGetMat: make routine! compose/deep/only [
"Converts CvArr (IplImage or CvMat,...) to CvMat"
	arr			[int]       				;CvArr!
	header		[int] 						; CvMat!
	coi			[int]						;CV_DEFAULT(NULL)
	allowND		[integer!]					;CV_DEFAULT(0)
	return: 	[struct! (first CvMat!)]
]cxcore "cvGetMat"


cvGetImage: make routine! compose/deep/only [
"Converts CvArr (IplImage or CvMat) to IplImage"
	arr				[int]       ;CvArr!
    image_header 	[int] 		; IplImage!
	return: 		[struct! (first IplImage!)]	
] cxcore "cvGetImage"

{Changes a shape of multi-dimensional array.
new_cn == 0 means that number of channels remains unchanged.
new_dims == 0 means that number and sizes of dimensions remain the same
(unless they need to be changed to set the new number of channels)
if new_dims == 1, there is no need to specify new dimension sizes
The resultant configuration should be achievable w/o data copying.
If the resultant array is sparse, CvSparseMat header should be passed
to the function else if the result is 1 or 2 dimensional,
CvMat header should be passed to the function
else CvMatND header should be passed}

cvReshapeMatND: make routine! compose/deep/only [
"Changes a shape of multi-dimensional array" 
	arr				[int]       ;CvArr!
	sizeof_header	[integer!]
	header			[int]       ;CvArr!
	new_cn			[integer!]
	new_dims		[integer!]
	new_sizes		[int]
	return: 		[struct! (first CvArr!)]
]cxcore "cvReshapeMatND"

cvReshapeND: func [arr header new_cn new_dims new_sizes]
[ cvReshapeMatND arr size? header header new_cn new_dims new_sizes]

cvReshape: make routine! compose/deep/only [
	arr				[int]       ;CvArr!
	header			[int]       ;CvArr!
	new_cn			[integer!]
	new_rows		[integer!]	;CV_DEFAULT(0)
	return: 		[struct! (first CvMat!)]
] cxcore "cvReshape"

cvRepeat: make routine! compose/deep/only [
"Repeats source 2d array several times in both horizontal and vertical direction to fill destination array"
	src				[int]       ;CvArr!
	dst				[int]       ;CvArr!
] cxcore "cvRepeat" 


cvCreateData: make routine! compose/deep/only [
"allocates array data"
	arr				[int]       ;CvArr!
] cxcore "cvCreateData"

cvReleaseData_: make routine! compose/deep/only [
"releases array data"
	arr				[struct! (first int-ptr!)] ; double pointer
] cxcore "cvReleaseData"

cvReleaseData: func [arr][
"releases array data"
	free-mem arr
] cxcore "cvReleaseData"


cvSetData: make routine! compose/deep/only [
{Attaches user data to the array header. The step is reffered to
the pre-last dimension. That is, all the planes of the array
must be joint (w/o gaps)}
	arr				[int]       ;CvArr!
	data			[int]		;void* pointer 
	step			[integer!]
] cxcore "cvSetData"

{Retrieves raw data of CvMat, IplImage or CvMatND.
In the latter case the function raises an error if
the array can not be represented as a matrix}

cvGetRawData: make routine! compose/deep/only [
"retrieves raw data of CvMat, IplImage or CvMatND"
	arr				[int]      ;CvArr!
	data			[int] ;uchar** pointer
	step			[int]; CV_DEFAULT(NULL)
	roi_size		[struct! (first CvSize!)];CV_DEFAULT(NULL)
] cxcore "cvGetRawData"

;openCV

cvGetSize_: make routine! compose/deep/only [
"Returns width and height of array in elements"
	arr				[int] ; CvArr!"IplImage or Matrice"
	return:			[integer!];; CvSize not a pointer
] cxcore "cvGetSize"

;Rebol
cvGetSize: func [arr /image /mat /matND /sparse] [
	if image  [return reduce [arr/width arr/height]]
	if mat  [return reduce [arr/cols arr/rows]]
	if matND [return arr/dim]
	if sparse [return arr/size]
]
 

cvCopy: make routine! compose/deep/only [
"copies source array to destination array"
	src				[int] 	;CvArr!
	dst				[int] 	;CvArr!
	mask			[int]; CV_DEFAULT(NULL) or none in REBOL
] cxcore "cvCopy"



cvSet: make routine! compose/deep/only [
"sets all or masked elements of input array to the same value"
	arr				[int]
	v0				[decimal!]; CvScalar not a pointer
    v1				[decimal!]
    v2				[decimal!]
    v3				[decimal!]
	mask			[int] ; CV_DEFAULT(NULL) 
] cxcore "cvSet"

cvSetZero: make routine! compose/deep/only [
"clears all the array elements (sets them to 0)"
	arr				[int]       ;CvArr!
] cxcore "cvSetZero"


cvZero: make routine! compose/deep/only [
"alias cvSetZero cvZero"
	arr				[int]; CvArr!
] cxcore "cvSetZero"

; Split and merge require ream int address :)
; use &pointer
cvSplit: make routine! compose/deep/only [
"splits a multi-channel array into the set of single-channel arrays or extracts particular [color] plane"
	src				[int] ;source 
	dst0			[int] 
	dst1			[int] 	
	dst2			[int] 
	dst3			[int] 
] cxcore "cvSplit"



cvMerge: make routine! compose/deep/only [
{merges a set of single-channel arrays into the single multi-channel array 
or inserts one particular [color] plane to the array}
	src0			[int] 
	src1			[int]  
	src2			[int] 
	src3			[int] 
	dst				[int] ; destination array
] cxcore "cvMerge"



cvMixChannels: make routine! compose/deep/only [
"copies several channels from input arrays to certain channels of output arrays"
	src			[int]			;CvArr!
	src_count	[integer!]
	dst			[int]			;CvArr!
	dst_count	[integer!]
	from_to		[int]			;CvArr!
	pair_count 	[integer!]	
]cxcore "cvMixChannels"

{Performs linear transformation on every source array element:
dst(x,y,c) = scale*src(x,y,c)+shift.
Arbitrary combination of input and output array depths are allowed
(number of channels must be the same), thus the function can be used
for type conversion}
cvConvertScale: make routine! compose/deep/only [
"performs linear transformation on every source array element"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	scale		[decimal!]					;CV_DEFAULT(1)
	shift		[decimal!]					;CV_DEFAULT(0)
] cxcore "cvConvertScale"


cvScale: func [src dst scale shift][
	cvConvertScale src dst scale shift
]

cvCvtScale: func [src dst scale shift][
	cvConvertScale src dst scale shift
]

cvConvert: func [src dst] [cvConvertScale src dst 1.0 0.0]

{Performs linear transformation on every source array element,
stores absolute value of the result:
dst(x,y,c) = abs(scale*src(x,y,c)+shift).
destination array must have 8u type.
In other cases one may use cvConvertScale + cvAbsDiffS}

cvConvertScaleAbs: make routine! compose/deep/only [
"performs linear transformation on every source array element"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	scale		[decimal!]				;CV_DEFAULT(1)
	shift		[decimal!]				;CV_DEFAULT(0)
] cxcore "cvConvertScaleAbs"

cvCvtScaleAbs: func [src dst scale shift] [
	cvConvertScaleAbs src dst scale shift
]


;checks termination criteria validity and sets eps to default_eps (if it is not set),
;max_iter to default_max_iters (if it is not set)
cvCheckTermCriteria: make routine! compose/deep/only [
"checks termination criteria validity and sets eps to default_eps (if it is not set)"
	criteria			[struct! (first CvTermCriteria!)]
	default_eps			[decimal!]
	default_max_iters 	[integer!]
	return: 			[struct! (first CvTermCriteria!)]
	
] cxcore "cvCheckTermCriteria"

;****************************************************************************************\
;*                   Arithmetic, logic and comparison operations                          *
;****************************************************************************************/
;pb with scalar in rebol

;dst(mask) = src1(mask) + src2(mask);

; all these routines want integer pointer 
;All the arrays must have the same type, except the mask, and the same size (or ROI size)

cvAdd: make routine! compose/deep/only [
	src1			[int] ; CvArr!;CvArr!
	src2			[int] ; CvArr! 
	dst				[int] ; CvArr! 
	mask			[int] ;CvArr!;CV_DEFAULT(NULL) 0
]cxcore "cvAdd"

;dst(mask) = src(mask) + value
cvAddS: make routine! compose/deep/only [
	src				[int] 		; CvArr! 
	v0              [decimal!]  ;cvScalar 4 values  
    v1              [decimal!]
    v2              [decimal!]
    v3              [decimal!]
	dst				[int];[struct! (first CvArr!)] ;CvArr!
	mask			[int] ;CvArr! CV_DEFAULT(NULL) 	
]cxcore "cvAddS"



;dst(mask) = src1(mask) - src2(mask) */
cvSub: make routine! compose/deep/only [
	src1			[int] ; CvArr! 
	src2			[int] ; CvArr! 
	dst				[int] ; CvArr! 
	mask			[int] ;CvArr!;CV_DEFAULT(NULL)
]cxcore "cvSub"

; dst(mask) = src(mask) - value = src(mask) + (-value) 
; CV_INLINE  void  cvSubS( const CvArr! src, CvScalar value, CvArr! dst, const CvArr! mask CV_DEFAULT(NULL))

cvSubS: func [src  v0 v1 v2 v3  dst  mask /local cvalue]  [
    cvalue: make struct! CvScalar! none
    cvalue/v0: negate v0
    cvalue/v1: negate v1
    cvalue/v2: negate v2
    cvalue/v3: negate v3
    cvAddS src cvalue/v0 cvalue/v1 cvalue/v2 cvalue/v3 dst mask
    
]


;dst(mask) = value - src(mask)
cvSubRS: make routine! compose/deep/only [
	src				[int] ;CvArr!
	v0              [decimal!]    
    v1              [decimal!]
    v2              [decimal!]
    v3              [decimal!]
	dst				[int] ;CvArr!
	mask			[int] ;CvArr! CV_DEFAULT(NULL)
]cxcore "cvSubRS"



;dst(idx) = src1(idx) * src2(idx) * scale (scaled element-wise multiplication of 2 arrays)
cvMul: make routine! compose/deep/only [
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst 				[int] ; CvArr! 
	scale				[decimal!] ;CV_DEFAULT(1))
] cxcore "cvMul"

{element-wise division/inversion with scaling: 
dst(idx) = src1(idx) * scale / src2(idx)
or dst(idx) = scale / src2(idx) if src1 == 0}
    
cvDiv: make routine! compose/deep/only [
	src1				[int] ;CvArr!
	src2				[int] ; CvArr!
	dst 				[int] ; CvArr!
	scale				[decimal!] ;CV_DEFAULT(1))
] cxcore "cvDiv"


;dst = src1 * scale + src2 */
cvScaleAdd: make routine! compose/deep/only [
	src1				[int] ;CvArr!
	v0              	[decimal!]    
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!]
	src2				[int] ;CvArr!
	dst 				[int] ;CvArr!
]cxcore "cvScaleAdd"



cvAXPY: func [A real_scalar B C] [cvScaleAdd A real_scalar B C]

; dst = src1 * alpha + src2 * beta + gamma
cvAddWeighted: make routine! compose/deep/only [
	src1				[int] ;CvArr!
	alpha				[decimal!]
	src2				[int] ;CvArr!
	beta				[decimal!]
	gamma				[decimal!]
	dst					[int] ;CvArr!
] cxcore "cvAddWeighted"


;result = sum_i(src1(i) * src2(i)) (results for all channels are accumulated together)
cvDotProduct: make routine! compose/deep/only [
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	return:				[decimal!]
] cxcore "cvDotProduct"

;dst(idx) = src1(idx) & src2(idx)
cvAnd: make routine! compose/deep/only [
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst 				[int] ; CvArr! 
	mask				[int] ;CvArr! CV_DEFAULT(NULL)
] cxcore "cvAnd" 

;dst(idx) = src(idx) & value */
cvAndS: make routine! compose/deep/only [
	src					[int] ;CvArr!
	;value				[struct! (first CvScalar!)]
	v0              	[decimal!]    
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!]
	dst 				[int] ;CvArr!
	mask				[int] ;CvArr!;CV_DEFAULT(NULL)
] cxcore "cvAndS" 




;dst(idx) = src1(idx) | src2(idx)
cvOr: make routine! compose/deep/only [
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst 				[int] ; CvArr! 
	mask				[int] ;CvArr! ;CV_DEFAULT(NULL)
] cxcore "cvOr" 

;dst(idx) = src(idx) | value
cvOrS: make routine! compose/deep/only [
	src					[int] ;CvArr!
	;value				[struct! (first CvScalar!)]
	v0              	[decimal!]    
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!]
	dst 				[int] ;CvArr!
	mask				[int] ;CvArr!;CV_DEFAULT(NULL)
] cxcore "cvOrS" 



;dst(idx) = src1(idx) ^ src2(idx)
cvXor: make routine! compose/deep/only [
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst 				[int] ; CvArr! 
	mask				[int] ;CvArr!;CV_DEFAULT(NULL)
] cxcore "cvXor" 

;dst(idx) = src(idx) ^ value
cvXorS: make routine! compose/deep/only [
	src					[int] ;CvArr!
	v0              	[decimal!]    
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!]
	dst 				[int] ;CvArr!
	mask				[int] ;CvArr!;CV_DEFAULT(NULL)
] cxcore "cvXorS" 


;/* dst(idx) = ~src(idx)
cvNot: make routine! compose/deep/only [
	src					[int] ; CvArr! 
	dst					[int] ; CvArr! 
] cxcore "cvNot"

;dst(idx) = lower(idx) <= src(idx) < upper(idx) */
cvInRange: make routine! compose/deep/only [
	src					[int] ; CvArr! 
	lower               [int] ; CvArr!
    upper               [int] ; CvArr!
	dst					[int] ; CvArr!
] cxcore "cvInRange"

;dst(idx) = lower <= src(idx) < upper */
cvInRangeS: make routine! compose/deep/only [
	src					[int] ; CvArr! 
	;lower              [_CvScalar]
    lower_v0            [decimal!]    
    lower_v1            [decimal!]
	lower_v2            [decimal!]
    lower_v3            [decimal!]
    ;upper              [_CvScalar]
    upper_v0            [decimal!]    
    upper_v1            [decimal!]
    upper_v2            [decimal!]
    upper_v3            [decimal!]
	dst					[int]; [struct! (first CvArr!)] 
] cxcore "cvInRangeS"


; comparaison operators
 
 CV_CMP_EQ:   0
 CV_CMP_GT:   1
 CV_CMP_GE:   2
 CV_CMP_LT:   3
 CV_CMP_LE:   4
 CV_CMP_NE:   5
 

 ;dst(idx) = src1(idx) _cmp_op_ src2(idx) */
 cvCmp: make routine! compose/deep/only [
 "The comparison operation support single-channel arrays only. Destination image should be 8uC1 or 8sC1"
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst					[int] ; CvArr! 
	cmp_op				[integer!]
 ] cxcore "cvCmp"
 

 cvCmpS: make routine! compose/deep/only [
 "dst(idx) = src1(idx) _cmp_op_ value"
	src					[int] ; CvArr!
	value				[decimal!]
	dst					[int] ; CvArr!
	cmp_op				[integer!]
 ] cxcore "cvCmpS"


cvMin: make routine! compose/deep/only [
"dst(idx) = min(src1(idx),src2(idx)"
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst					[int] ; CvArr! 
 ] cxcore "cvMin"


cvMax: make routine! compose/deep/only [
";dst(idx) = max(src1(idx),src2(idx))"
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst					[int] ; CvArr! 
 ] cxcore "cvMax"


 cvMinS: make routine! compose/deep/only [
 "dst(idx) = min(src(idx),value)"
	src					[int] ; CvArr! 
	value				[decimal!]
	dst					[int] ; CvArr! 
 ] cxcore "cvMinS"

cvMaxS: make routine! compose/deep/only [
"dst(idx) = max(src(idx),value)"
	src					[int] ; CvArr! 
	value				[decimal!]
	dst					[int] ; CvArr! 
 ] cxcore "cvMaxS"
 
 cvAbsDiff: make routine! compose/deep/only [
 " dst(x,y,c) = abs(src1(x,y,c) - src2(x,y,c))"
	src1				[int] ; CvArr! 
	src2				[int] ; CvArr! 
	dst					[int] ; CvArr! 
 ] cxcore "cvAbsDiff"
 
 cvAbsDiffS: make routine! compose/deep/only [
 "dst(x,y,c) = abs(src(x,y,c) - value(c))"
	src				    [int] ; CvArr! 
	dst					[int] ; CvArr! 
	v0              	[decimal!] ;CvScalar!
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!]
	
 ] cxcore "cvAbsDiffS"
 
 
cvAbs: func [src dst] [v: cvScalarAll 0 cvAbsDiffS src dst v/v0 v/v1 v/v2 v/v3]

;/****************************************************************************************\
;*                                Math operations                                         *
;\****************************************************************************************

 cvCartToPolar: make routine! compose/deep/only [
 "Does cartesian->polar coordinates conversion. Either of output components (magnitude or angle) is optional"
	x						[int]
	y						[int]
	magnitude				[int]
	angle					[int]; CV_DEFAULT(NULL)
	angle_in_degrees		[integer!]; CV_DEFAULT(0)
 ] cxcore "cvCartToPolar" 
 

cvPolarToCart: make routine! compose/deep/only [
{Does polar->cartesian coordinates conversion.
Either of output components (magnitude or angle) is optional.
If magnitude is missing it is assumed to be all 1's }
	magnitude				[int]
	angle					[int]; CV_DEFAULT(NULL)
	x						[int]
	y						[int]
	angle_in_degrees		[integer!]; CV_DEFAULT(0)
 ] cxcore "cvPolarToCart" 
 
cvPow: make routine! compose/deep/only [
"Does powering: dst(idx) = src(idx)^power"
	src				[int] ; CvArr!
	dst				[int] ; CvArr!
	power			[decimal!]
] cxcore "cvPow"


cvExp: make routine! compose/deep/only [
{Does exponention: dst(idx) = exp(src(idx)).
Overflow is not handled yet. Underflow is handled.
Maximal relative error is ~7e-6 for single-precision input}
	src				[int] ; CvArr!
	dst				[int] ; CvArr!
] cxcore "cvExp"


cvLog: make routine! compose/deep/only [
{Calculates natural logarithms: dst(idx) = log(abs(src(idx))).
Logarithm of 0 gives large negative number(~-700)
Maximal relative error is ~3e-7 for single-precision output}
	src				[int] ; CvArr!
	dst				[int] ; CvArr!
] cxcore "cvLog"

cvFastArctan: make routine! [
"Fast arctangent calculation" 
	y		[decimal!]
	x		[decimal!]
	return: [decimal!]
] cxcore "cvFastArctan"

cvCbrt: make routine! [
"Fast cubic root calculation"
	value	[decimal!]
	return: [decimal!]
] cxcore "cvCbrt" 

{Checks array values for NaNs, Infs or simply for too large numbers
   (if CV_CHECK_RANGE is set). If CV_CHECK_QUIET is set,
   no runtime errors is raised (function returns zero value in case of "bad" values).
   Otherwise cvError is called}
   
CV_CHECK_RANGE:    1
CV_CHECK_QUIET:    2

cvCheckArr: make routine! compose/deep/only [
"Checks array values for NaNs, Infs or simply for too large numbers"
	arr				[int] ; CvArr!
	flags			[integer!] ;CV_DEFAULT(0)
	min_val 		[decimal!]; CV_DEFAULT(0) 
	max_val 		[decimal!];CV_DEFAULT(0))
	return: 		[integer!]
	
] cxcore "cvCheckArr"	
   
alias 'cvCheckArr "cvCheckArray"

CV_RAND_UNI:      0
CV_RAND_NORMAL:   1


cvRandArr: make routine! compose/deep/only [
	rng			   	[struct! (first float-ptr!)] ; pointer to CvRNG funct
	arr				[int] ; CvArr!
	dist_type		[integer!] ; CV_RAND_UNI or CV_RAND_NORMAL 
	;param1			[_CvScalar]
    param1_v0       [decimal!]    
    param1_v1       [decimal!]
    param1_v2       [decimal!]
    param1_v3       [decimal!]
    ;param2			[_CvScalar]
    param2_v0       [decimal!]    
    param2_v1       [decimal!]
    param2_v2       [decimal!]
    param2_v3       [decimal!]	
] cxcore "cvRandArr"

cvRandShuffle: make routine! compose/deep/only [
	mat				[int] ; CvArr!		
	rng				[struct! (first float-ptr!)] ; pointer to CvRNG funct
	iter_factor		[decimal!]; CV_DEFAULT(1.0)
] cxcore "cvRandShuffle"


CV_SORT_EVERY_ROW:		 0
CV_SORT_EVERY_COLUMN:	 1
CV_SORT_ASCENDING:		 0
CV_SORT_DESCENDING:		 16

; only for single channel array for src and dst;
cvSort: make make routine! compose/deep/only [
	src				[int] ; CvArr!
	dst				[int] ; CV_DEFAULT(NULL)
	idxmat			[int] ; CV_DEFAULT(NULL)
	flags			[integer!]				 ; CV_DEFAULT(0))
	
] cxcore "cvSort"

; a specific rebol sort: can be used with multi channel images

cvRSort: func [src dst /local step data roi] [
	&step: as-int!/& src/widthStep
	data: make struct! int-ptr! reduce [src/imageSize]
	&data: struct-address? data 
	roi: make struct! cvSize! reduce [0 0]
	&src: as-pointer! src
	cvGetRawData &src &data &step roi
	&data: data/int          					; get the pointer adress in return
	data: get-memory  &data src/imageSize		; get the data
	sort data									; sort data
	&dst: as-pointer! dst						    
	cvSetData &dst &data src/widthStep			;now use SetData to destination image !
	free-mem data
]




cvSolveCubic: make routine! compose/deep/only [
"Finds real roots of a cubic equation"
	coeffs			[int] ; CvMat!
	roots			[int] ; CvMat!
	return: 		[integer!]
] cxcore "cvSolveCubic"

cvSolvePoly: make routine! compose/deep/only [
"Finds all real and complex roots of a polynomial equation"
	coeffs			[int] ; CvMat!
	roots2			[int] ; CvMat!
	maxiter			[integer!]; CV_DEFAULT(20)
	fig				[integer!]; CV_DEFAULT(100)
] cxcore "cvSolvePoly"


;/****************************************************************************************\
;*                                Matrix operations                                       *
;\****************************************************************************************/

cvCrossProduct: make routine! compose/deep/only [
"Calculates cross product of two 3d vectors"
	src1			[int] ; CvArr!
	src2			[int] ; CvArr!
	dst				[int] ; CvArr!
] cxcore "cvCrossProduct"

cvGEMM: make routine! compose/deep/only [
"Extended matrix transform: dst = alpha*op(A)*op(B) + beta*op(C), where op(X) is X or X^T"
	src1			[int] ; CvArr!
	src2			[int] ; CvArr!
	alpha			[decimal!]
	src3			[int] ; CvArr!
	beta			[decimal!]
	dst				[int] ; CvArr!
	tABC			[integer!];CV_DEFAULT(0)	
] cxcore "cvGEMM"

alias 'cvGEMM "vMatMulAddEx"

;Matrix transform: dst = A*B + C, C is optional 
cvMatMulAdd: func [src1 src2 src3 dst][cvGEMM src1 src2 1.0 src3 1.0 dst 0 ]
cvMatMul: func [src1 src2 dst] [cvMatMulAdd src1 src2 none dst]

CV_GEMM_A_T: 1
CV_GEMM_B_T: 2
CV_GEMM_C_T: 4

cvTransform_: make routine! compose/deep/only [
"transforms each element of source array and stores resultant vectors in destination array"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	transmat	[int] ; CvMat!
	shiftvec	[int]
] cxcore "cvTransform"


cvTransform: func [src dst transmat shiftvec /local v] [
	either shiftvec != none [v: struct-address? shiftvec] [v: none]
	cvTransform_ src dst transmat v
]

alias 'cvTransform "cvMatMulAddS"

cvPerspectiveTransform: make routine! compose/deep/only [
"Does perspective transform on every element of input array "
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	mat			[int] ; CvMat!
] cxcore "cvPerspectiveTransform"

cvMulTransposed_: make routine! compose/deep/only [
"Calculates (A-delta)*(A-delta)^T (order=0) or (A-delta)^T*(A-delta) (order=1)"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	order		[integer!]
	delta		[int] ;CV_DEFAULT(NULL)
	scale		[decimal!];CV_DEFAULT(1.)
] cxcore "cvMulTransposed"

cvMulTransposed: func [src dst order delta scale /local d] [
	either delta != none [d: struct-address? delta ] [d: none]
	cvMulTransposed_ src dst order d scale
]

cvTranspose: make routine! compose/deep/only [
"Tranposes matrix. Square matrices can be transposed in-place"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
] cxcore "cvTranspose"

alias 'cvTranspose "cvT"


cvCompleteSymm: make routine! compose/deep/only [
"Completes the symmetric matrix from the lower (LtoR=0) or from the upper (LtoR!=0) part"
	matrix: 	[int] ; CvMat!
	LtoR: 		[integer!] ; CV_DEFAULT(0) )
] cxcore "cvCompleteSymm"


cvFlip: make routine! compose/deep/only [
{Mirror array data around horizontal (flip=0),
vertical (flip=1) or both(flip=-1) axises:
cvFlip(src) flips images vertically and sequences horizontally (inplace)}
	src			[int] ; CvArr!
	dst			[int] ; CvArr! ;CV_DEFAULT(src)
	flip_mode	[integer!]
] cxcore "cvFlip"


cvFlip_: make routine! compose/deep/only [
{Mirror array data around horizontal (flip=0),
vertical (flip=1) or both(flip=-1) axises:
cvFlip(src) flips images vertically and sequences horizontally (inplace)}
	src			[int]
	dst			[int] ;CV_DEFAULT(src)
	flip_mode	[integer!]
] cxcore "cvFlip"



alias 'cvFlip "cvMirror"

CV_SVD_MODIFY_A:   1
CV_SVD_U_T:        2
CV_SVD_V_T:        4

cvSVD_: make routine! compose/deep/only [
"Performs Singular Value Decomposition of a matrix"
	A			[int] ; CvArr!
	W			[int] ; CvArr!
	U			[int] ;DEFAULT(NULL)
	V			[int] ;DEFAULT(NULL)
	flags		[integer!]
] cxcore "cvSVD"

cvSVD: func [A W U V flags /Local uu vv] [
	either U != none [uu: struct-address? U] [uu: none]
	either V != none [vv: struct-address? V] [vv: none]
	cvSVD_ A W uu vv flags
]


cvSVBkSb: make routine! compose/deep/only [
"Performs Singular Value Back Substitution (solves A*X = B): flags must be the same as in cvSVD"
	W			[int] ; CvArr!
	U			[int] ; CvArr!
	V			[int] ; CvArr!
	B			[int] ; CvArr!
	flags		[integer!]
] cxcore "cvSVBkSb"

CV_LU:  0
CV_SVD: 1
CV_SVD_SYM: 2

cvInvert: make routine! compose/deep/only [
"Inverts matrix  (CV_32F OR CV_64F images!)"
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	method		[integer!]
	return: 	[decimal!];CV_DEFAULT(CV_LU)
] cxcore "cvInvert"

alias 'cvInvert "cvInv"

cvSolve: make routine! compose/deep/only [
"Solves linear system (src1)*(dst) = (src2) (returns 0 if src1 is a singular and CV_LU method is used)"
	src1		[int] ; CvArr!
	src2		[int] ; CvArr!
	dst			[int] ; CvArr!
	method		[integer!];CV_DEFAULT(CV_LU)
	return: 	[integer!]
] cxcore "cvSolve"

cvDet: make routine! compose/deep/only [
"Calculates determinant of input matrix"
	mat			[int] ; CvArr!
	return: 	[decimal!]
] cxcore "cvDet"

cvTrace: make routine! compose/deep/only [
"Calculates trace of the matrix (sum of elements on the main diagonal)"
	mat			[int] ; CvArr!
	return: 	reduce [decimal! decimal! decimal! decimal!] ; CvScalar
] cxcore "cvTrace"


cvEigenVV: make routine! compose/deep/only [
"Finds eigen values and vectors of a symmetric matrix"
	mat			[int] ; CvArr!
	evects		[int] ; CvArr!
	evals		[int] ; CvArr!
	eps			[decimal!];CV_DEFAULT(0)
	lowindex	[integer!]; CV_DEFAULT(-1)
	highindex	[integer!]; CV_DEFAULT(-1))
	
] cxcore "cvEigenVV"


cvSetIdentity: make routine! compose/deep/only [
"Makes an identity matrix (mat_ij = i == j)"
	mat					[int] ; CvArr!
	v0              	[decimal!] ;CvScalar ;CV_DEFAULT(cvRealScalar 1
    v1              	[decimal!]
    v2              	[decimal!]
    v3              	[decimal!] 
] cxcore "cvSetIdentity"

cvRange: make routine! compose/deep/only [
"Fills matrix with given range of numbers"
	mat			[int] ; CvMat!
	start		[decimal!]
	end			[decimal!]
] cxcore "cvRange"

; Calculates covariation matrix for a set of vectors transpose([v1-avg, v2-avg,...]) * [v1-avg,v2-avg,...] 
 CV_COVAR_SCRAMBLED: 0

; [v1-avg, v2-avg,...] * transpose([v1-avg,v2-avg,...]) 
 CV_COVAR_NORMAL:    1

; do not calc average (i.e. mean vector) - use the input vector instead (useful for calculating covariance matrix by parts) 
 CV_COVAR_USE_AVG:   2

; scale the covariance matrix coefficients by number of the vectors 
 CV_COVAR_SCALE:     4

; all the input vectors are stored in a single matrix, as its rows 
 CV_COVAR_ROWS:      8

; all the input vectors are stored in a single matrix, as its columns 
 CV_COVAR_COLS:     16



cvCalcCovarMatrix: make routine! compose/deep/only [
	vects		[int] ; CvArr! ;CvArr**
	count		[integer!]
	cov_mat		[int] ; CvArr!
	avg			[int] ; CvArr!
	flags		[integer!]
] cxcore "cvCalcCovarMatrix"

CV_PCA_DATA_AS_ROW: 	0 
CV_PCA_DATA_AS_COL: 	1
CV_PCA_USE_AVG:		 	2


cvCalcPCA: make routine! compose/deep/only [
	data		[int] ; CvArr!
	mean		[int] ; CvArr!
	eigenvals	[int] ; CvArr!
	eigenvects	[int] ; CvArr!
	flags		[integer!]
] cxcore "cvCalcPCA"
 

cvProjectPCA: make routine! compose/deep/only [
	data		[int] ; CvArr!
	mean		[int] ; CvArr!
	eigenvects	[int] ; CvArr!
	result		[int] ; CvArr!
] cxcore "cvProjectPCA"

cvBackProjectPCA: make routine! compose/deep/only [
	proj		[int] ; CvArr!
	mean		[int] ; CvArr!
	eigenvects	[int] ; CvArr!
	result		[int] ; CvArr!
] cxcore "cvBackProjectPCA"


cvMahalanobis: make routine! compose/deep/only [
"Calculates Mahalanobis(weighted) distance"
	vec1		[int] ; CvArr!
	vec2		[int] ; CvArr!
	mat			[int] ; CvArr!
	return: 	[decimal!]
] cxcore "cvMahalanobis"

alias 'cvMahalanobis "cvMahalonobis"

;/****************************************************************************************\
;*                                    Array Statistics                                    *
;\****************************************************************************************/

cvSum: make routine! compose/deep/only [
"Finds sum of array elements "
	arr		[int] ; CvArr!
	return:	[struct! (first CvScalar!)] ;CvScalar
] cxcore "cvSum"

cvCountNonZero: make routine! compose/deep/only [
"Calculates number of non-zero pixels. The array, must be single-channel array or multi-channel image with COI set. "
	arr		[int] ; CvArr!
	return:	[integer!]
] cxcore "cvCountNonZero"

cvAvg: make routine! compose/deep/only [
"Calculates mean value of array elements"
	arr		[int] ; CvArr!
	mask	[int] ; CvArr!;CV_DEFAULT(NULL)
	return:	[decimal!] ;CvScalar
] cxcore "cvAvg"



cvAvgSdv_: make routine! compose/deep/only [
"Calculates mean and standard deviation of pixel values"
	arr		[int] ; CvArr!
	mean	[struct! (first CvScalar!)]
	std_dev [struct! (first CvScalar!)]
	mask	[int];CV_DEFAULT(NULL)
	return:	[]
] cxcore "cvAvgSdv"

cvAvgSdv: func [arr mean std_dev mask /local m] [
	either mask != none [m: struct-address? mask] [m: none]
	cvAvgSdv_ arr mean std_dev m
]

cvMinMaxLoc: make routine! compose/deep/only [
"Finds global minimum, maximum and their positions"
	arr			[int]       ;CvArr!
	min_val		[struct! (first float-ptr!)] ;[decimal!]
	max_val		[struct! (first float-ptr!)] ;[decimal!]
	min_loc		[struct! (first CvPoint!)];CV_DEFAULT(NULL)
	max_loc		[struct! (first CvPoint!)];CV_DEFAULT(NULL)
	mask	 	[int] ;[struct! (first CvArr!)];CV_DEFAULT(NULL)
	return:		[]
] cxcore "cvMinMaxLoc"

;types of array norm 
 CV_C:            1
 CV_L1:           2
 CV_L2:           4
 CV_NORM_MASK:    7
 CV_RELATIVE:     8
 CV_DIFF:         16
 CV_MINMAX:       32
 CV_DIFF_C:       CV_DIFF OR CV_C
 CV_DIFF_L1:      CV_DIFF OR CV_L1
 CV_DIFF_L2:      CV_DIFF OR CV_L2
 CV_RELATIVE_C:   CV_RELATIVE OR CV_C
 CV_RELATIVE_L1:  CV_RELATIVE OR CV_L1
 CV_RELATIVE_L2:  CV_RELATIVE OR CV_L2
 
 cvNorm: make routine! compose/deep/only [
 "Finds norm, difference norm or relative difference norm for an array (or two arrays)"
	arr1			[int] ; CvArr!
	arr2			[int] ; CvArr!;CV_DEFAULT(NULL)
	norm_type 		[integer!]; CV_DEFAULT(CV_L2)
	mask	 		[int] ; CvArr!;CV_DEFAULT(NULL)
	return:			[decimal!]
 ]cxcore "cvNorm"
 
cvNormalize: make routine! compose/deep/only [
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	a			[decimal!];CV_DEFAULT(1.)
	b			[decimal!];CV_DEFAULT(0.)
	norm_type	[integer!];CV_DEFAULT(CV_L2)
	mask	 	[int] ; CvArr!;CV_DEFAULT(NULL)
	return:		[]
] cxcore "cvNormalize"
 
CV_REDUCE_SUM: 0
CV_REDUCE_AVG: 1
CV_REDUCE_MAX: 2
CV_REDUCE_MIN: 3

cvReduce: make routine! compose/deep/only [
	src			[int] ; CvArr!
	dst			[int] ; CvArr!
	dim 		[integer!];CV_DEFAULT(-1)
	op 			[integer!];CV_DEFAULT(CV_REDUCE_SUM) )
	return:		[]
] cxcore "cvReduce"

;/****************************************************************************************\
;*                      Discrete Linear Transforms and Related Functions                  *
;\****************************************************************************************/

 CV_DXT_FORWARD:  0
 CV_DXT_INVERSE:  1
 CV_DXT_SCALE:    2 ;divide result by size of array 
 CV_DXT_INV_SCALE: CV_DXT_INVERSE + CV_DXT_SCALE
 CV_DXT_INVERSE_SCALE: CV_DXT_INV_SCALE
 CV_DXT_ROWS:     4 ;transform each row individually 
 CV_DXT_MUL_CONJ: 8 ;conjugate the second argument of cvMulSpectrums 
 
 cvDFT: make routine! compose/deep/only [
 "Discrete Fourier Transform: complex->complex,real->ccs (forward),ccs->real (inverse)"
	src				[int] ; CvArr!
	dst				[int] ; CvArr!
	flags			[integer!]
	nonzero_rows 	[integer!];CV_DEFAULT(0)
	return:			[]
] cxcore "cvDFT"

alias 'cvDFT "cvFFT"

cvMulSpectrums: make routine! compose/deep/only [
"Multiply results of DFTs: DFT(X)*DFT(Y) or DFT(X)*conj(DFT(Y))"
	src1			[int] ; CvArr!
	src2			[int] ; CvArr!
	dst				[int] ; CvArr!
	flags			[integer!]
	return:			[]
] cxcore "cvMulSpectrums"

cvGetOptimalDFTSize: make routine! [
"Finds optimal DFT vector size >= size0"
	size0		[integer!]
	return:		[integer!]
] cxcore "cvGetOptimalDFTSize"


cvDCT: make routine! compose/deep/only [
"Discrete Cosine Transform"
	src				[int] ; CvArr!
	dst				[int] ; CvArr!
	flags			[integer!]
] cxcore "cvDCT"

;/****************************************************************************************\
;*                              Dynamic data structures                                   *
;\****************************************************************************************/

cvSliceLength: make routine! compose/deep/only [
"Calculates length of sequence slice (with support of negative indices)"
	slice_start_index       [integer!] ;CvSlice 
    slice_end_index         [integer!]
	seq						[struct! (first CvSeq!)]
	return:					[integer!]
] cxcore "cvSliceLength"
;PAUSE
cvCreateMemStorage: make routine! compose/deep/only [
"Creates new memory storage. block_size = 0 means that default,somewhat optimal size, is used (currently, it is 64K)"
	block_size 		[integer!];CV_DEFAULT(0)
	return:			[struct! (first CvMemStorage!)]
] cxcore "cvCreateMemStorage"

;Creates a memory storage that will borrow memory blocks from parent storage
cvCreateChildMemStorage: make routine! compose/deep/only [
	parent	 		[struct! (first CvMemStorage!)]
	return:			[struct! (first CvMemStorage!)]
] cxcore "cvCreateChildMemStorage"

;Releases memory storage. All the children of a parent must be released before the parent. 
;A child storage returns all the blocks to parent when it is released

;OPENVCV
cvReleaseMemStorage: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] ;CvMemStorage** (address?)
] cxcore "cvReleaseMemStorage"

{Clears memory storage. This is the only way(!!!) (besides cvRestoreMemStoragePos)
to reuse memory allocated for the storage - cvClearSeq,cvClearSet ...
do not free any memory.A child storage returns all the blocks to the parent when it is cleared}

cvClearMemStorage: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] ;CvMemStorage** (address?)
] cxcore "cvClearMemStorage"

;Remember a storage "free memory" position 
cvSaveMemStoragePos: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] 
	pos		 		[struct! (first CvMemStorage!)] 
] cxcore "cvSaveMemStoragePos"

;Restore a storage "free memory" position
cvRestoreMemStoragePos: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] 
	pos		 		[struct! (first CvMemStorage!)] 
] cxcore "cvRestoreMemStoragePos"

;Allocates continuous buffer of the specified size in the storage */
cvMemStorageAlloc: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] 
	size_t		 	[integer!] 
] cxcore "cvMemStorageAlloc"

;Allocates string in memory storage */
cvMemStorageAlloc: make routine! compose/deep/only [
	storage	 		[struct! (first CvMemStorage!)] 
	ptr		 	    [struct! (first int-ptr!)] ; pointer
	len				[integer!];CV_DEFAULT(-1)
	return:			[string!]
] cxcore "cvMemStorageAlloc"

;Creates new empty sequence that will reside in the specified storage 
cvCreateSeq: make routine! compose/deep/only [
	seq_flags		[integer!]	
	header_size		[integer!]
	elem_size		[integer!]
	storage			[struct! (first CvMemStorage!)]
	return: 		[struct! (first CvSeq!)]
] cxcore "cvCreateSeq"

;changes default size (granularity) of sequence blocks. The default size is ~1Kbyte
cvSetSeqBlockSize: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	delta_elems		[integer!]
] cxcore "cvSetSeqBlockSize"

;Adds new element to the end of sequence. Returns pointer to the element
cvSeqPush: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
	return: 		[int]
] cxcore "cvSeqPush"

;Adds new element to the beginning of sequence. Returns pointer to it
cvSeqPushFront: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
	return: 		[int]
] cxcore "cvSeqPushFront"

;Removes the last element from sequence and optionally saves it
cvSeqPop: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
] cxcore "cvSeqPop"

;Removes the first element from sequence and optioanally saves it
cvSeqPopFront: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
] cxcore "cvSeqPopFront"

CV_FRONT: 1
CV_BACK: 0

;Adds several new elements to the end of sequence
cvSeqPushMulti: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
	count			[integer!]
	in_front		[integer!]; CV_DEFAULT(0)
] cxcore "cvSeqPushMulti"

;Removes several elements from the end of sequence and optionally saves them
cvSeqPopMulti: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element 		[integer!];CV_DEFAULT(NULL) pointer
	count			[integer!]
	in_front		[integer!]; CV_DEFAULT(0)
] cxcore "cvSeqPopMulti"

;Inserts a new element in the middle of sequence.cvSeqInsert(seq,0,elem) == cvSeqPushFront(seq,elem)
cvSeqInsert: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	before_index	[integer!]
	element 		[integer!];CV_DEFAULT(NULL) pointer
	return: 		[int]
] cxcore "cvSeqInsert"

;Removes specified sequence element
cvSeqRemove: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	index			[integer!]
] cxcore "cvSeqRemove"

{Removes all the elements from the sequence. The freed memory
can be reused later only by the same sequence unless cvClearMemStorage
or cvRestoreMemStoragePos is called}
cvClearSeq: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
] cxcore "cvClearSeq"

{Retrives pointer to specified sequence element.
Negative indices are supported and mean counting from the end
(e.g -1 means the last sequence element)}
cvGetSeqElem: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	index			[integer!]
	return:			[int]
] cxcore "cvGetSeqElem"

;Calculates index of the specified sequence element. Returns -1 if element does not belong to the sequence 
cvSeqElemIdx: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	element			[integer!] ; pointer to void*
	return:			[struct! (first CvSeqBlock!)]; CV_DEFAULT(NULL) address?
] cxcore "cvSeqElemIdx"

;Initializes sequence writer. The new elements will be added to the end of sequence
cvStartAppendToSeq: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	writer			[struct! (first CvSeqWriter!)]
] cxcore "cvStartAppendToSeq"

;Combination of cvCreateSeq and cvStartAppendToSeq
cvStartWriteSeq: make routine! compose/deep/only [
	seq_flags		[integer!]
	header_size		[integer!]
    elem_size		[integer!]
    storage			[struct! (first CvMemStorage!)]
    writer			[struct! (first CvSeqWriter!)]
] cxcore "cvStartWriteSeq"

{Closes sequence writer, updates sequence header and returns pointer to the resultant sequence
(which may be useful if the sequence was created using cvStartWriteSeq))}
cvEndWriteSeq: make routine! compose/deep/only [
	writer			[struct! (first CvSeqWriter!)]
	return: 		[struct! (first CvSeq!)]
] cxcore "cvEndWriteSeq"

; Updates sequence header. May be useful to get access to some of previously written elements via cvGetSeqElem or sequence reader
cvFlushSeqWriter: make routine! compose/deep/only [
	writer			[struct! (first CvSeqWriter!)]
] cxcore "cvFlushSeqWriter"

;Initializes sequence reader. The sequence can be read in forward or backward direction
cvStartReadSeq: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	reader			[struct! (first CvSeqReader!)]
	_reverse		[integer!];CV_DEFAULT(0)
] cxcore "cvStartReadSeq"

;Returns current sequence reader position (currently observed sequence element)
cvGetSeqReaderPos: make routine! compose/deep/only [
	reader			[struct! (first CvSeqReader!)]
	return:			[integer!]
] cxcore "cvGetSeqReaderPos"

;Changes sequence reader position. It may seek to an absolute or to relative to the current position
cvSetSeqReaderPos: make routine! compose/deep/only [
	reader			[struct! (first CvSeqReader!)]
	index			[integer!]
	is_relative 	[integer!];CV_DEFAULT(0))
] cxcore "cvSetSeqReaderPos"

;Copies sequence content to a continuous piece of memory 
cvCvtSeqToArray: make routine! compose/deep/only [
	seq				[struct! (first CvSeq!)]
	elements		[integer!]; pointer
	slice		 	[struct! (first CvSlice!)];CV_DEFAULT(CV_WHOLE_SEQ)
] cxcore "cvCvtSeqToArray"

;Creates sequence header for array.
;After that all the operations on sequences that do not alter the conten can be applied to the resultant sequence
cvMakeSeqHeaderForArray: make routine! compose/deep/only [
	seq_type			[struct! (first CvSeq!)]
	header_size		 	[integer!]
	elem_size		 	[integer!]
	elements			[integer!]; pointer
	total				[integer!]
	seq					[struct! (first CvSeq!)]
	block				[struct! (first CvSeqBlock!)]
	return:			[struct! (first CvSeq!)]
] cxcore "cvMakeSeqHeaderForArray"

;Extracts sequence slice (with or without copying sequence elements)
cvSeqSlice: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	slice 				[struct! (first CvSlice!)]
	storage				[struct! (first CvMemStorage!)];CV_DEFAULT(NULL)
	copy_data			[integer!];CV_DEFAULT(NULL)
] cxcore "cvSeqSlice"

;inline function
cvCloneSeq: func [seq storage 1]
[
    return cvSeqSlice seq CV_WHOLE_SEQ storage 1
]

;Removes sequence slice
cvSeqRemoveSlice: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	slice 				[struct! (first CvSlice!)]
] cxcore "cvSeqRemoveSlice"

;Inserts a sequence or array into another sequence
cvSeqInsertSlice: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	before_index		[integer!]
	from_arr			[int] ; CvArr!
] cxcore "cvSeqInsertSlice"

;a < b ? -1 : a > b ? 1 : 0 
CvCmpFunc: func [a b userdata][
	tmp: 0
	if a < b [tmp: -1]
	if a > b [tmp: 1]
	return tmp
]
CV_CDECL*: :CvCmpFunc

;Sorts sequence in-place given element comparison function
cvSeqSort: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	CvCmpFunc			[integer!]
	userdata			[integer!];CV_DEFAULT(NULL)
] cxcore "cvSeqSort"

;Finds element in a [sorted] sequence 
cvSeqSearch: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	elem				[integer!]
	CvCmpFunc			[integer!]
	is_sorted			[integer!]
	elem_idx			[struct! (first int-ptr!)]
	userdata			[integer!];CV_DEFAULT(NULL)
	return:				[int]
] cxcore "cvSeqSearch"

;Reverses order of sequence elements in-place
cvSeqInvert: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
] cxcore "cvSeqInvert"

;Splits sequence into one or more equivalence classes using the specified criteria
cvSeqPartition: make routine! compose/deep/only [
	seq					[struct! (first CvSeq!)]
	storage				[struct! (first CvMemStorage!)]
	labels				[struct! (first CvSeq!)]; CvSeq** 
	is_equal			[integer!]
	userdata			[integer!]
	return:				[integer!]
] cxcore "cvSeqPartition"

;/************ Internal sequence functions ************/
cvChangeSeqBlock: make routine![
	reader				[integer!]
	direction			[integer!]
] cxcore "cvChangeSeqBlock"

cvCreateSeqBlock: make routine! compose/deep/only [
	writer				[struct! (first CvSeqWriter!)]
] cxcore "cvCreateSeqBlock"

;Creates a new set
cvCreateSet: make routine! compose/deep/only [
	set_flags			[integer!]
	header_size			[integer!]
	elem_size			[integer!]
	storage				[struct! (first CvMemStorage!)]
	return:				[struct! (first CvSet!)]
] cxcore "cvCreateSet"

;Adds new element to the set and returns pointer to it
cvSetAdd: make routine! compose/deep/only [
	set_header			[struct! (first CvSet!)]
	elem			    [struct! (first CvSetElem!)]; V_DEFAULT(NULL)
	inserted_elem 		[struct! (first CvSetElem!)] ;CvSetElem** V_DEFAULT(NULL)
	return:				[integer!]
] cxcore "cvSetAdd"

;inline Fast variant of cvSetAdd; DO NOT USE WITH REBOL
; revoir pas bonne
cvSetNew: func [set_header]
[
	elem: set_header/free_elems;
    either (elem)
    [
        set_header/free_elems: elem/next_free
        elem/flags: elem/flags and CV_SET_ELEM_IDX_MASK
        ++ set_header/active_count
    ] [cvSetAdd set_header none &elem]; if rebol use address of elem (seek peek and poke func)
    return elem
]

;inline Removes set element given its pointer 
;REBOL !! use CvSet! as first parameter and CvSetElem! as second

cvSetRemoveByPtr: func [set_header elem]
[
    _elem:  make struct! [CvSetElem!] elem
     assert _elem-/flags >= 0 
    _elem/next_free: set_header/free_elems
    _elem/flags: (_elem/flags AND CV_SET_ELEM_IDX_MASK) OR CV_SET_ELEM_FREE_FLAG
    set_header/free_elems:_elem;
    -- set_header/active_count
]

;Removes element from the set by its index 
cvSetRemove: make routine! compose/deep/only [ 
	set_header		[struct! (first CvSet!)]
	index 			[integer!]
] cxcore "cvSetRemove"

;inline func Returns a set element by index. If the element doesn't belong to the set,NULL is returned
cvGetSetElem: func [set_header index ]
[
    elem: cvGetSeqElem set_header index
    tmp: elem AND CV_IS_SET_ELEM elem
    either tmp <> 0 [return tmp] [return 0];
]

;Removes all the elements from the set
cvClearSet: make routine! compose/deep/only [ 
	set_header		[struct! (first CvSet!)]
] cxcore "cvClearSet"

;Creates new graph
cvCreateGraph: make routine! compose/deep/only [
	graph_flags			[integer!]
	header_size			[integer!]
    vtx_size			[integer!]
    edge_size			[integer!]
    storage				[struct! (first CvMemStorage!)]
    return:				[struct! (first CvGraph!)]
] cxcore "cvCreateGraph"

;Adds new vertex to the graph
cvGraphAddVtx: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	vtx				[struct! (first CvGraphVtx!)];CV_DEFAULT(NULL)
	inserted_vtx	[struct! (first CvGraphVtx!)]; pointer address? CV_DEFAULT(NULL)
    return:			[integer!]
] cxcore "cvGraphAddVtx"

;Removes vertex from the graph together with all incident edges

cvGraphRemoveVtx: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	index			[integer!]
    return:			[integer!]
] cxcore "cvGraphRemoveVtx"

cvGraphRemoveVtxByPtr: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	vtx				[struct! (first CvGraphVtx!)];CV_DEFAULT(NULL)
    return:			[integer!]
] cxcore "cvGraphRemoveVtxByPtr"

{Link two vertices specifed by indices or pointers if they
are not connected or return pointer to already existing edge
connecting the vertices. Functions return 1 if a new edge was created, 0 otherwise}
cvGraphAddEdge: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_idx		[integer!]
	end_idx			[integer!]
	edge			[struct! (first CvGraphEdge!)];CV_DEFAULT(NULL)
	inserted_edge	[struct! (first CvGraphEdge!)];pointer address CV_DEFAULT(NULL)
    return:			[integer!]
] cxcore "cvGraphAddEdge"

cvGraphAddEdgeByPtr: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_vtx		[struct! (first CvGraphVtx!)]
	end_vtx			[struct! (first CvGraphVtx!)]
	edge			[struct! (first CvGraphEdge!)];CV_DEFAULT(NULL)
	inserted_edge	[struct! (first CvGraphEdge!)];pointer address CV_DEFAULT(NULL)
    return:			[integer!]
] cxcore "cvGraphAddEdgeByPtr"

;* Remove edge connecting two vertices
cvGraphRemoveEdge: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_idx		[integer!]
	end_idx			[integer!]
] cxcore "cvGraphRemoveEdge"

cvGraphRemoveEdgeByPtr: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_vtx		[struct! (first CvGraphVtx!)]
	end_vtx			[struct! (first CvGraphVtx!)]
] cxcore "cvGraphRemoveEdgeByPtr"

;* Find edge connecting two vertices
cvFindGraphEdge: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_idx		[integer!]
	end_idx			[integer!]
	return:			[struct! (first CvGraphEdge!)]
] cxcore "cvFindGraphEdge"

cvFindGraphEdgeByPtr: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	start_idx		[struct! (first CvGraphVtx!)]
	end_idx			[struct! (first CvGraphVtx!)]
	return:			[struct! (first CvGraphEdge!)]
] cxcore "cvFindGraphEdgeByPtr"

alias 'cvFindGraphEdge "cvGraphFindEdge"
alias 'cvFindGraphEdgeByPtr "cvGraphFindEdgeByPtr"

;Remove all vertices and edges from the graph 
cvClearGraph: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
] cxcore "cvClearGraph"

;Count number of edges incident to the vertex
cvGraphVtxDegree: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	vtx_idx			[integer!]
	return:			[integer!]
] cxcore "cvGraphVtxDegree"

cvGraphVtxDegreeByPtr: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	vtx				[struct! (first CvGraphVtx!)]
	return:			[integer!]
] cxcore "cvGraphVtxDegreeByPtr"

;Retrieves graph vertex by given index
cvGetGraphVtx: func [graph idx] [cvGetSetElem graph idx]
;Retrieves index of a graph vertex given its pointer
cvGraphVtxIdx: func [graph vtx] [vtx/flags AND CV_SET_ELEM_IDX_MASK]
;Retrieves index of a graph edge given its pointer */
cvGraphEdgeIdx: func [graph edge] [edge/flags AND CV_SET_ELEM_IDX_MASK]
cvGraphGetVtxCount: func [graph] [graph/active_count]
cvGraphGetEdgeCount: func [graph] [graph/edges/active_count]

CV_GRAPH_VERTEX:        1
CV_GRAPH_TREE_EDGE:     2
CV_GRAPH_BACK_EDGE:     4
CV_GRAPH_FORWARD_EDGE:  8
CV_GRAPH_CROSS_EDGE:    16
CV_GRAPH_ANY_EDGE:      30
CV_GRAPH_NEW_TREE:      32
CV_GRAPH_BACKTRACKING:  64
CV_GRAPH_OVER:          -1
CV_GRAPH_ALL_ITEMS:     -1

;flags for graph vertices and edges 
CV_GRAPH_ITEM_VISITED_FLAG:  1 shift/left 30 1
CV_GRAPH_SEARCH_TREE_NODE_FLAG:  1 shift/left 29 1
CV_GRAPH_FORWARD_EDGE_FLAG:      1 shift/left 28 1 
IS_GRAPH_VERTEX_VISITED: func [vtx] [CV_IS_GRAPH_VERTEX_VISITED: vtx/flags and CV_GRAPH_ITEM_VISITED_FLAG] ; vtx is CvGraphVtx!
IS_GRAPH_EDGE_VISITED: func [edge] [CV_IS_GRAPH_EDGE_VISITED: edge/flags and CV_GRAPH_ITEM_VISITED_FLAG]; edge is CvGraphEdge!

CvGraphScanner!: make struct! compose/deep/only [ 
    vtx 			[struct! (first CvGraphVtx!)] ; current graph vertex (or current edge origin) 
    dst     		[struct! (first CvGraphVtx!)] ; current graph edge destination vertex 
    edge   			[struct! (first CvGraphEdge!)]  ; current edge 
    graph      		[struct! (first CvGraph!)] ; the graph 
	stack		    [struct! (first CvSeq!)] ; the graph vertex stack 
    index			[integer!]        ; the lower bound of certainly visited vertices 
    mask 			[integer!]        ; event mask 
]
none 

;Creates new graph scanner
cvCreateGraphScanner: make routine! compose/deep/only [
	graph			[struct! (first CvGraph!)]
	vtx 			[struct! (first CvGraphVtx!)] ;CV_DEFAULT(NULL)
	mask			[integer!];V_DEFAULT(CV_GRAPH_ALL_ITEMS))
	return:			[struct! (first CvGraphScanner!)]
] cxcore "cvCreateGraphScanner"

;Releases graph scanner
cvReleaseGraphScanner: make routine! compose/deep/only [
	scanner		[struct! (first CvGraphScanner!)] ; CvGraphScanner** address??
] cxcore "cvReleaseGraphScanner"

; Get next graph element 
cvNextGraphItem: make routine! compose/deep/only [
	scanner		[struct! (first CvGraphScanner!)]
	return:		[integer!]
] cxcore "cvNextGraphItem"

;Creates a copy of graph
cvCloneGraph: make routine! compose/deep/only [
	graph		[struct! (first CvGraph!)]
	storage		[struct! (first CvMemStorage!)]
	return: 	[struct! (first CvGraph!)]
] cxcore "cvCloneGraph"

;/****************************************************************************************\
;*                                     Drawing                                            *
;\****************************************************************************************/

;/****************************************************************************************\
;*       Drawing functions work with images/matrices of arbitrary type.                   *
;*       For color images the channel order is BGR[A]                                     *
;*       Antialiasing is supported only for 8-bit image now.                              *
;*       All the functions include parameter color that means rgb value (that may be      *
;*       constructed with CV_RGB macro) for color images and brightness                   *
;*       for grayscale images.                                                            *
;*       If a drawn figure is partially or completely outside of the image, it is clipped.*
;\****************************************************************************************/

CV_RGB: func [r g b] [cvScalar b g r 0 ]

CV_FILLED:	 -1
CV_AA:		 16
;Draws 4-connected, 8-connected or antialiased line segment connecting two points





cvLine: make routine! compose/deep/only [
	img				[int] ; CvArr!
	pt1_x			[integer!]
	pt1_y 			[integer!]
	pt2_x 			[integer!]
	pt2_y 			[integer!]
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	thickness		[integer!] ;
	line_type		[integer!] ;CV_DEFAULT(8)
	_shift			[integer!] ;CV_DEFAULT(0)
] cxcore "cvLine"

; rebol  version
rcvLine: func [ptr start [pair!] end [pair!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!] 
/local r g b a]
[ tmp: tocvRGB color r: tmp/1 g: tmp/2 b: tmp/3 a: tmp/4
  cvLine ptr start/x start/y end/x end/y r g b a thickness lineType offset
]



;Draws a rectangle given two opposite corners of the rectangle (pt1 & pt2),
;if thickness<0 (e.g. thickness == CV_FILLED), the filled box is drawn 

cvRectangle: make routine! compose/deep/only [
	img				[int] ; CvArr!
	pt1_x			[integer!]
	pt1_y 			[integer!]
	pt2_x 			[integer!]
	pt2_y 			[integer!]
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	thickness		[integer!]
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvRectangle"

;rebol version
rcvRectangle: func [ptr start [pair!] end [pair!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!]
/local r g b a]
[ tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
  cvRectangle ptr start/x start/y end/x end/y r g b a thickness lineType offset
]


;Draws a circle with specified center and radius.
;Thickness works in the same way as with cvRectangle

cvCircle: make routine! compose/deep/only [
	img				[int] ; CvArr!
	center_x		[integer!]
	center_y 		[integer!]
	radius			[integer!]
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	thickness		[integer!];CV_DEFAULT(1)
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvCircle"

;rebol version
rcvCircle: func [ptr center [pair!] radius [integer!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!] 
/local r g b a] 
[ tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
  cvCircle ptr center/x center/y radius r g b a thickness lineType offset
]

{Draws ellipse outline, filled ellipse, elliptic arc or filled elliptic sector,
depending on <thickness>, <start_angle> and <end_angle> parameters. The resultant figure
is rotated by <angle>. All the angles are in degrees}

cvEllipse: make routine! compose/deep/only [
	img				[int] ; CvArr!
	center_x		[integer!]
	center_y 		[integer!]
	width			[integer!]
	height			[integer!]
	angle			[decimal!]
	start_angle		[decimal!]
	end_angle		[decimal!]
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	thickness		[integer!];CV_DEFAULT(1)
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvEllipse"
; rebol version
rcvEllipse: func [ptr center [pair!] axes [pair!] angle [number!] start_angle [number!] end_angle [number!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!]
/local r g b a] 
[  tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
  cvEllipse ptr center/x center/y axes/x axes/y to-decimal angle to-decimal start_angle to-decimal end_angle r g b a thickness lineType offset
]

cvEllipseBox: func [ptr center [pair!] size [pair!] angle [number!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!]
/local r g b a axes]
[ tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
  axes: make struct! cvSize! none
  axes/width: first size 
  axes/height: second size
  cvEllipse ptr center/x center/y axes/width axes/height to-decimal angle 0 360 r g b a thickness lineType offset]


; Fills convex or monotonous polygon.
cvFillConvexPoly: make routine! compose/deep/only [ 
	img				[int] ; CvArr!
	pts				[integer!] ; pointer to array of points 
	npts			[integer!] ; nb of vertices
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvFillConvexPoly"	

; rebol version using a block of pairs as parameter
rcvFillConvexPoly: func [ptr pts [block!] color [tuple!] lineType [integer!] offset [integer!] 
/local r g b a ]
[
	tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
	;how to pass an array of coords as a pointer to cvFillConvexPoly
	npts: length? pts 
	points: make binary! 2 * npts * sizeof 'integer!
	; y first then x
	foreach p pts [insert points convert second p insert points convert first p]
	&pts:  string-address? points ; pointer to array
	cvFillConvexPoly  ptr &pts npts r g b a  lineType offset
]

;Fills an area bounded by one or more arbitrary polygons
cvFillPoly: make routine! compose/deep/only [ 
	img				[int] ; CvArr!
	pts				[integer!] ; pointer to array of array of points 
	npts			[integer!] ;pointer nb of points by polygons
	contours		[integer!] ; nb of polygons to draw
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvFillPoly"


; cvFillPoly is rather complicated to use with rebol: pointer pf pointers! 
; rcvFillPoly does the same job with a repetition of cvFillConvexPoly according to the  numbers of polygons to be drawn
rcvFillPoly:  func [ptr polygons [block!] color [tuple!] lineType [integer!] offset [integer!] 
/local r g b a]
[
	tmp: tocvByteRGB/signed color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
	foreach p polygons [
			npts: length? p ; nbr of vertices in the polygon 
			points: make binary! 2 * npts * sizeof 'integer!
			foreach pp p [insert points convert second pp insert points convert first pp] ; make the array of coordinates in binary
			&pts:  string-address? points ; pointer to array of binary (returns an integer!) 
			cvFillConvexPoly  ptr &pts npts r g b a  lineType offset ; draw polygon
	]
]


;Draws one or more polygonal curves
cvPolyLine: make routine! compose/deep/only [ 
	img				[int] ; CvArr!
	pts				[integer!] ; pointer to array of points 
	npts			[integer!] ;nb of vertices
	contours		[integer!] ; nb of polygons
	is_closed		[integer!] ; 0 or 1 to close the polygon
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
	thickness 		[integer!];CV_DEFAULT(1)
	line_type		[integer!];CV_DEFAULT(8)
	_shift			[integer!];CV_DEFAULT(0)
] cxcore "cvPolyLine"

; idem uses cvLine to make polygons
rcvPolyLine: func [ptr lines [block!] isClosed [logic!] color [tuple!] thickness [integer!] lineType [integer!] offset [integer!] 
/local r g b a ]
[
	tmp: tocvByteRGB/signed color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
	nbofLines: to-integer length? lines
	; transforms pair! in 2 integers
	coords: copy []
	foreach l lines [
		bloc: copy []
		val: first l
		append bloc val/x
		append bloc val/y
	    append/only coords bloc
	]
	
	; if isClosed closes the polygon 
	either isClosed [lastPoint: nbofLines] [lastPoint: nbofLines - 1] 
	
	; get starting and ending point for each lines
	for i 1 lastPoint 1 [
		val1: coords/(i)
		val2: coords/(i + 1)
		if i = nbofLines [val2: coords/1]
		cvLine ptr first val1 second val1 first val2 second val2 r g b a thickness lineType offset
	]
]


;Clips the line segment connecting *pt1 and *pt2 by the rectangular window (0<=x<img_size.width, 0<=y<img_size.height).
cvClipLine: make routine! compose/deep/only [ 
	width 		[integer!];x CvSize
	height 		[integer!]; y CvSize
	*pt1		[integer!]; pointer to cvPoint
	*pt2		[integer!] ; pointer to cvPoint
	return:		[integer!]
] cxcore "cvClipLine"

; OK returns 0
rcvClipLine: func [size [pair!] pt1 [pair!] pt2 [pair!]] [
	w: first size
	h: second size
	; creates pointers to cvPoint
	*pt1: make binary! 2 * sizeof 'integer!
	insert *pt1 convert second pt1 insert *pt1 convert first pt1
	&pt1: string-address? *pt1
	*pt2: make binary! 2 * sizeof 'integer!
	insert *pt2 convert second pt2 insert *pt2 convert first pt2
	&pt2: string-address? *pt2
	ret: cvClipLine w h &pt1 &pt2
	return ret
]

{Initializes line iterator. Initially, line_iterator->ptr will point
to pt1 (or pt2, see left_to_right description) location in the image.
Returns the number of pixels on the line between the ending points}

cvInitLineIterator: make routine! compose/deep/only [ 
	img				[int] ; CvArr!
	pt1_x			[integer!]
	pt1_y 			[integer!]
	pt2_x 			[integer!]
	pt2_y 			[integer!]
	line_iterator   [struct! (first CvLineIterator!)] ; pointer 
	connectivity	[integer!] ;CV_DEFAULT(8)
	left_to_right	[integer!] ;CV_DEFAULT(0)
	return:			[integer!]
] cxcore "cvInitLineIterator"


;Moves iterator to the next line point 
CV_NEXT_LINE_POINT: func [line_iterator] 
[
	either line_iterator/err < 0 [_line_iterator_mask: -1] [_line_iterator_mask: 0]
	line_iterator/err: line_iterator/err + line_iterator/delta + (line_iterator/plus_delta AND _line_iterator_mask)
	line_iterator/ptr: line_iterator/ptr + line_iterator/minus_step + (line_iterator/plus_step AND _line_iterator_mask)
]

;/basic font types */
 CV_FONT_HERSHEY_SIMPLEX:         0
 CV_FONT_HERSHEY_PLAIN:           1
 CV_FONT_HERSHEY_DUPLEX:          2
 CV_FONT_HERSHEY_COMPLEX:         3 
 CV_FONT_HERSHEY_TRIPLEX:         4
 CV_FONT_HERSHEY_COMPLEX_SMALL:   5
 CV_FONT_HERSHEY_SCRIPT_SIMPLEX:  6
 CV_FONT_HERSHEY_SCRIPT_COMPLEX:  7
 
; font flags 
CV_FONT_ITALIC:                 16  

CV_FONT_VECTOR0:    CV_FONT_HERSHEY_SIMPLEX

; Font structure 
CvFont!: make struct! 
[
    font_face 	[integer!]; /* =CV_FONT_* */
    ascii 		[integer!]; int-ptr! /* font data and metrics */
    greek		[integer!]; int-ptr!
    cyrillic	[integer!]; int-ptr!
    hscale 		[decimal!]
    vscale		[decimal!]
    shear		[decimal!] ; /* slope coefficient: 0 - normal, >0 - italic */
    thickness	[integer!] ; /* letters thickness */
    dx			[decimal!]; /* horizontal interval between letters */
    line_type	[integer!];
] none

;Initializes font structure used further in cvPutText

cvInitFont: make routine! compose/deep/only [ 
	*font				[struct! (first CvFont!)] ; pointer to fonts
	font_face			[integer!]
	hscale				[decimal!]
	vscale				[decimal!]
	shear				[decimal!]; CV_DEFAULT(0) ;italic
	thickness			[integer!]; CV_DEFAULT(1)
	line_type			[integer!];CV_DEFAULT(8))
] cxcore "cvInitFont" 

cvFont: func [scale thickness]
[
    font: make struct! CvFont! none;
    cvInitFont font CV_FONT_HERSHEY_PLAIN scale scale 0 thickness CV_AA
    return font;
]

; Renders text stroke with specified font and color at specified location. CvFont should be initialized with cvInitFont
cvPutText: make routine! compose/deep/only [  
	img				[int] ; CvArr!
	text			[string!]
	orgx			[integer!]
	orgy			[integer!]
	font			[struct! (first CvFont!)]; &font pointer 
	r				[decimal!]
	g				[decimal!]
	b				[decimal!]
	a				[decimal!]
] cxcore "cvPutText"

rcvPutText: func [ptr text [string!] org [pair!] font color [tuple!] 
/local r g b a ]
[
	tmp: tocvRGB color r: tmp/3 g: tmp/2 b: tmp/1 a: tmp/4
	cvPutText ptr text org/x org/y font r g b a
]

;Calculates bounding box of text stroke (useful for alignment)
cvGetTextSize: make routine! compose/deep/only [  
	text			[string!]
	;font			[integer!]; pointer
	font			[struct! (first CvFont!)]; pointer
	text_size		[struct! (first CvSize!)]; pointer to cvSize*
	baseline		[struct! (first int-ptr!)]; pointer
] cxcore "cvGetTextSize" 

{ Unpacks color value, if arrtype is CV_8UC?, <color> is treated as
   packed color value, otherwise the first channels (depending on arrtype)
   of destination scalar are set to the same value = <color> }

cvColorToScalar: make routine! compose/deep/only [  
	packed_color	[decimal!]
	arrtype			[integer!]
	return: 		[struct! (first CvScalar!)]		
] cxcore "cvColorToScalar" 

{Returns the polygon points which make up the given ellipse.  The ellipse is define by
the box of size 'axes' rotated 'angle' around the 'center'.  A partial sweep
of the ellipse arc can be done by spcifying arc_start and arc_end to be something
other than 0 and 360, respectively.  The input array 'pts' must be large enough to
hold the result.  The total number of points stored into 'pts' is returned by this function.}

cvEllipse2Poly: make routine! compose/deep/only [  
	center_x			[integer!];cvPoint
	center_y			[integer!];cvPoint
	axe_x				[integer!];cvSize
	axe_y				[integer!];cvSize
	angle				[integer!]
	arc_start			[integer!]
	arc_end				[integer!]
	pts					[integer!]; pointer to cvPoints
	delta				[integer!]; 
	return:				[integer!]
] cxcore "cvEllipse2Poly"   
   
;Draws contour outlines or filled interiors on the image
cvDrawContours: make routine! compose/deep/only [ 
	img				[int] ; CvArr!
	contour			[struct! (first CvSeq!)]
	er				[decimal!]
	eg				[decimal!]
	eb				[decimal!]
	ea				[decimal!]
	hr				[decimal!]
	hg				[decimal!]
	hb				[decimal!]
	ha				[decimal!]
	thickness 		[integer!];CV_DEFAULT(1)
	line_type		[integer!];CV_DEFAULT(8)
	offset_x		[integer!];CV_DEFAULT(0)
	offset_y		[integer!];CV_DEFAULT(0)
] cxcore "cvDrawContours"

;Does look-up transformation. Elements of the source array (that should be 8uC1 or 8sC1) are used as indexes in lutarr 256-element table
cvLUT: make routine! compose/deep/only [ 
	src		[int] ; CvArr!
	dst		[int] ; CvArr!
	lut		[int] ; CvArr!
] cxcore "cvLUT"

;******************* Iteration through the sequence tree *****************/

CvTreeNodeIterator!: make struct!  [
    node                [int]		;pointeur
    level               [integer!]
    max_level           [integer!]  
] none

cvInitTreeNodeIterator:  make routine! compose/deep/only[
        tree_iterator                   [struct! (first CvTreeNodeIterator!)]
        first                           [struct! (first int-ptr!)]
        max_level                       [integer!]
 ] cxcore "cvInitTreeNodeIterator" 
 
 
cvNextTreeNode: make routine! compose/deep/only[
	tree_iterator        [struct! (first CvTreeNodeIterator!)]
] cxcore "cvNextTreeNode" 

cvPrevTreeNode: make routine! compose/deep/only [
	tree_iterator        [struct! (first CvTreeNodeIterator!)]
] cxcore "cvPrevTreeNode" 


cvInsertNodeIntoTree: make routine! compose/deep/only [
    "Inserts sequence into tree with specified parent sequence."
        node                            [struct! (first int-ptr!)] ;*void
        parent                          [struct! (first int-ptr!)] ;*void
        frame                           [struct! (first int-ptr!)] ;*void
] cxcore "cvInsertNodeIntoTree"

cvRemoveNodeFromTree: make routine! compose/deep/only [
    "Inserts sequence into tree with specified parent sequence."
        node                            [struct! (first int-ptr!)] ;*void
        frame                           [struct! (first int-ptr!)] ;*void
] cxcore "cvRemoveNodeFromTree"

cvTreeToNodeSeq: make routine! compose/deep/only [
    "Gathers pointers to all the sequences, accessible from the first, to the single sequence "
        first                           [struct! (first int-ptr!)]
        header_size                     [integer!]
        storage                         [struct! (first CvMemStorage!)]
        return:                         [struct! (first CvSeq!)] 
] cxcore "cvTreeToNodeSeq"

cvKMeans2: make routine! compose/deep/only  [
        samples                         [int] ; CvArr!
        cluster_count                   [integer!]
        labels                          [int] ; CvArr!
        termcrit                        [struct! (first CvTermCriteria!)] 
] cxcore "cvKMeans2"

;/****************************************************************************************\
;*                                    System functions                                    *
;\****************************************************************************************/

cvRegisterModule:  make routine! compose/deep/only  [
    "Add the function pointers table with associated information to the IPP primitives list"
        module_info                     [struct! (first CvModuleInfo!)]
        return:                         [integer!]
] cxcore "cvRegisterModule"

cvUseOptimized: make routine! compose/deep/only  [
    "Loads optimized functions from IPP, MKL etc. or switches back to pure C code"
        on_off                          [integer!]
        return:                         [integer!]
] cxcore "cvUseOptimized"

cvGetModuleInfo: make routine! compose/deep/only  [
    "Retrieves information about the registered modules and loaded optimized plugins"
        module_name                     [string!]; const char* 
        version                         [struct! (first int-ptr!)] ;char**
        loaded_addon_plugins            [struct! (first int-ptr!)] ;char** 
] cxcore "cvGetModuleInfo"

;Get current OpenCV error status
cvGetErrStatus: make routine! [return: [integer!]] cxcore "cvGetErrStatus"
;Sets error status silently
cvSetErrStatus: make routine! [status [integer!]] cxcore "cvSetErrStatus"    

CV_ErrModeLeaf:     0   ;Print error and exit program
CV_ErrModeParent:   1   ;Print error and continue
CV_ErrModeSilent:   2   ;Don't print and continue

;Retrives current error processing mode
cvGetErrMode: make routine! [return: [integer!]] cxcore "cvGetErrMode"
;Sets error processing mode, returns previously used mode
cvSetErrMode: make routine! [mode [integer!] return: [integer!]] cxcore "cvSetErrMode"

cvError:  make routine! [
"Sets error status and performs some additonal actions (displaying message box,writing message to stderr, terminating application etc.)"
        status              [integer!]
        func_name           [string!]
        err_msg             [string!]
        file_name           [string!]
        line                [integer!]
] cxcore "cvError"
    
cvErrorStr: make routine! [
"Retrieves textual description of the error given its code"
        status              [integer!]
        return:             [string!]     
] cxcore "cvErrorStr"

cvGetErrInfo: make routine! compose/deep/only [
"Retrieves detailed information about the last error occured"
        errcode_desc            [struct! (first int-ptr!)] ;char**
        description             [struct! (first int-ptr!)] ;char**
        filename                [struct! (first int-ptr!)] ;char**
        line                    [struct! (first int-ptr!)]
        return:                 [integer!]    
] cxcore "cvGetErrInfo"

cvErrorFromIppStatus: make routine!  [
"Maps IPP error codes to the counterparts from OpenCV"
        ipp_status              [integer!]
        return:                 [integer!]   
] cxcore "cvErrorFromIppStatus"



;RED/S version of orginal typedef int (CV_CDECL *CvErrorCallback)
CvErrorCallback!: make struct! [
    status              [integer!]
    func_name           [string!]
    err_msg             [string!]
    file_name           [string!]
    line                [integer!]
    userdata            [int]   ; pointer
] none

cvRedirectError: make routine! compose/deep/only  [
        error_handler           [struct! (first CvErrorCallback!)]
        userdata                [struct! (first int-ptr!)]         ;void*
        prev_userdata           [struct! (first int-ptr!)]  ; double pointer void**
] cxcore "cvRedirectError"


;Output to:
;    cvNulDevReport - nothing
;    cvStdErrReport - console(fprintf(stderr,...))
;    cvGuiBoxReport - MessageBox(WIN32)

cvNulDevReport: make routine! compose/deep/only [
        status              [integer!]
        func_name           [string!]
        err_msg             [string!]
        file_name           [string!]
        line                [integer!]
        userdata            [struct! (first int-ptr!)]
        return:             [integer!]
] cxcore "cvNulDevReport"

cvStdErrReport: make routine! compose/deep/only  [
        status              [integer!]
        func_name           [string!]
        err_msg             [string!]
        file_name           [string!]
        line                [integer!]
        userdata            [struct! (first int-ptr!)]
        return:             [integer!]
] cxcore "cvStdErrReport"
    
 cvGuiBoxReport: make routine! compose/deep/only  [
        status              [integer!]
        func_name           [string!]
        err_msg             [string!]
        file_name           [string!]
        line                [integer!]
        userdata            [struct! (first int-ptr!)]
        return:             [integer!]
] cxcore "cvGuiBoxReport"

; old IPL compatibility
;typedef void* (CV_CDECL *CvAllocFunc)(size_t size, void* userdata);
;typedef int (CV_CDECL *CvFreeFunc)(void* pptr, void* userdata);
; prefer use Red/S
cvSetMemoryManager: make routine! compose/deep/only [
        alloc_func           [struct! (first int-ptr!)] ; CvAllocFunc function pointer
        free_func            [struct! (first int-ptr!)] ; CvFreeFunc function pointer
        userdata             [struct! (first int-ptr!)]
]cxcore "cvSetMemoryManager" 
    
; Makes OpenCV use IPL functions for IplImage allocation/deallocation (see stdcall below)
cvSetIPLAllocators: make routine! compose/deep/only  [
    "Use stdcall old ipl functions" ; 
        create_header       [int] ; IplImage! ; Cv_iplCreateImageHeader  result
        allocate_data       [struct! (first int-ptr!)] ;Cv_iplAllocateImageData
        deallocate          [struct! (first int-ptr!)] ;Cv_iplDeallocate
        create_roi          [struct! (first IplROI!)]   ;Cv_iplCreateROI
        clone_image         [int] ; IplImage! ;Cv_iplCloneImage
] cxcore "cvSetIPLAllocators"

CV_TURN_ON_IPL_COMPATIBILITY: [(cvSetIPLAllocators iplCreateImageHeader iplAllocateImage iplDeallocate iplCreateROIiplCloneImage)]


;*                                    Data Persistence                                    *
;********************************** High-level functions ********************************

cvOpenFileStorage: make routine! compose/deep/only  [
"opens existing or creates new file storage"
        filename                [string!]
        memstorage              [struct! (first CvMemStorage!)]
        flags                   [integer!]
        return                  [struct! (first CvFileStorage!)]
] cxcore "cvOpenFileStorage"
    
cvReleaseFileStorage: make routine! compose/deep/only  [
"closes file storage and deallocates buffers"
        fs                      [struct! (first int-ptr!)] ; double pointer CvFileStorage** 
] cxcore "cvReleaseFileStorage"

cvAttrValue: make routine! compose/deep/only [
"returns attribute value or 0 (NULL) if there is no such attribute"
        attr                    [struct! (first CvAttrList!)]
        attr_name               [string!]
        return:                 [byte!] ; 0 or null
] cxcore "cvAttrValue" 
    

cvStartWriteStruct: make routine! compose/deep/only [
"starts writing compound structure (map or sequence)"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        flags                   [integer!]
        type_name               [string!]  ;CV_DEFAULT(NULL)
        attribute               [struct! (first CvAttrList!)] ;CV_DEFAULT(cvAttrList()
] cxcore "cvStartWriteStruct"

cvEndWriteStruct: make routine! compose/deep/only [
"finishes writing compound structure"
    	fs                      [struct! (first CvFileStorage!)]
] cxcore "cvEndWriteStruct"

cvWriteInt: make routine! compose/deep/only  [
"writes an integer"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        value                   [integer!]  
] cxcore "cvWriteInt"
    
    
cvWriteReal: make routine! compose/deep/only  [
"writes a floating-point number"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        value                   [decimal!]  
] cxcore "cvWriteReal" 

cvWriteString: make routine! compose/deep/only  [
"writes a string"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        str                     [string!]
        quote                   [integer!]  ; CV_DEFAULT(0)
] cxcore "cvWriteString"

cvWriteComment: make routine! compose/deep/only  [
"writes a comment"
        fs                      [struct! (first CvFileStorage!)]
        comment                 [string!]
        eol_comment             [integer!]          
] cxcore "cvWriteComment"

cvWrite:  make routine! compose/deep/only  [
"writes instance of a standard type (matrix, image, sequence, graph etc.)  or user-defined type"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        ptr                     [struct! (first int-ptr!)]
        attributes              [struct! (first CvAttrList!)] ;CV_DEFAULT(cvAttrList()    
] cxcore "cvWrite"

cvStartNextStream:  make routine! compose/deep/only [
"starts the next stream"
        fs                      [struct! (first CvFileStorage!)]
] cxcore "cvStartNextStream" 

cvWriteRawData: make routine! compose/deep/only [
"helper function: writes multiple integer or floating-point numbers"
        fs                      [struct! (first CvFileStorage!)]
        src                     [struct! (first int-ptr!)] ; *void on data
        len                     [integer!]
        dt                      [struct! (first int-ptr!)]  
] cxcore "cvWriteRawData"

cvGetHashedKey: make routine! compose/deep/only  [
"returns the hash entry corresponding to the specified literal key string or 0 if there is no such a key in the storage"
        fs                      [struct! (first CvFileStorage!)]
        name                    [string!]
        len                     [integer!]
        create_missing          [integer!] ;CV_DEFAULT(0)
        return:                 [struct! (first CvStringHashNode!)]
] cxcore "cvGetHashedKey"

cvGetRootFileNode: make routine! compose/deep/only  [
"returns file node with the specified key within the specified map (collection of named nodes)"
        fs                      [struct! (first CvFileStorage!)]
        stream_index            [integer!]
        return:                 [struct! (first CvFileNode!)]
] cxcore "cvGetRootFileNode"

cvGetFileNodeByName: make routine! compose/deep/only  [
    "this is a slower version of cvGetFileNode that takes the key as a literal string"
        fs                      [struct! (first CvFileStorage!)]
        map                     [struct! (first CvFileNode!)]
        name                    [string!]
        return:                 [struct! (first CvFileNode!)]
] cxcore "cvGetFileNodeByName"

cvRead: make routine! compose/deep/only  [
"decodes standard or user-defined object and returns it"
        fs                      [struct! (first CvFileStorage!)]
        node                    [struct! (first CvFileNode!)]
        attributes              [struct! (first CvAttrList!)] ;CV_DEFAULT(NULL)    
] cxcore "cvRead"

cvStartReadRawData: make routine! compose/deep/only  [
"starts reading data from sequence or scalar numeric node"
        fs                      [struct! (first CvFileStorage!)]
        src                     [struct! (first CvFileNode!)]
        reader                  [struct! (first CvSeqReader!)]
] cxcore "cvStartReadRawData"

cvReadRawData: make routine! compose/deep/only  [
"combination of two previous functions for easier reading of whole sequences"
        fs                      [struct! (first CvFileStorage!)]
        src                     [struct! (first CvFileNode!)]
        dst                     [struct! (first int-ptr!)] 
        dt                      [integer!]
] cxcore "cvReadRawData"

cvWriteFileNode: make routine! compose/deep/only  [
"writes a copy of file node to file storage"
        fs                      [struct! (first CvFileStorage!)]
        new_node_name           [string!]
        node                    [struct! (first CvFileNode!)]
        embed                   [integer!]
] cxcore "cvWriteFileNode"

cvGetFileNodeName: make routine! compose/deep/only  [
    "returns name of file node"
     node                       [struct! (first CvFileNode!)]
     return:                    [string!]
] cxcore "cvGetFileNodeName"
    
;*********************************** Adding own types ***********************************

cvRegisterType: make routine! compose/deep/only [info [struct! (first CvTypeInfo!)]] cxcore "cvRegisterType"
cvUnregisterType: make routine!  [type_name [string!]] cxcore "cvUnregisterType"
cvFirstType:  make routine! compose/deep/only [ return:    [struct! (first CvTypeInfo!)]] cxcore "cvFirstType"
cvFindType:  make routine! compose/deep/only [type_name [string!] return: [struct! (first CvTypeInfo!)]] cxcore "cvFindType"
cvTypeOf: make routine! compose/deep/only  [struct_ptr [struct! (first int-ptr!)] return: [struct! (first CvTypeInfo!)]] cxcore "cvTypeOf"
cvClone:  make routine! compose/deep/only  [struct_ptr [struct! (first int-ptr!)] return: [struct! (first int-ptr!)]] cxcore "cvClone"

;universal functions
cvRelease:  make routine! compose/deep/only  [struct_ptr [struct! (first int-ptr!)]] cxcore "cvRelease"

;simple API for reading/writing data
cvSave: make routine! compose/deep/only [
        filename                [string!]
        struct_ptr              [struct! (first int-ptr!)]
        name                    [string!]     ;CV_DEFAULT(NULL)
        comment                 [string!]     ;CV_DEFAULT(NULL)
        attributes              [struct! (first CvAttrList!)]  ;CV_DEFAULT(cvAttrList() 
] cxcore "cvSave"


cvLoad: make routine! compose/deep/only  [
		filename				[string!]
        memstorage              [struct! (first CvMemStorage!)]
        name                    [int];[string!]     ;CV_DEFAULT(NULL)
        real_name               [int];struct! (first int-ptr!)]
        return:					[long] ;void*
] cxcore "cvLoad"

;*********************************** Measuring Execution Time ***************************
;helper functions for RNG initialization and accurate time measurement: uses internal clock counter on x86 
cvGetTickCount:  make routine!  [return: [decimal!]] cxcore "cvGetTickCount"
cvGetTickFrequency:  make routine!  [return: [decimal!]] cxcore "cvGetTickFrequency"

;*********************************** Multi-Threading ************************************
cvGetNumThreads: make routine! [return: [integer!]] cxcore "cvGetNumThreads" 
cvSetNumThreads:  make routine! [threads [integer!]] cxcore "cvSetNumThreads"
;get index of the thread being executed
cvGetThreadNum:  make routine! [return: [integer!]] cxcore "cvGetThreadNum"   

; we dont need ipl data with stdcall


