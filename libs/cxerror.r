#! /usr/bin/rebol
REBOL[
	Title:		"OpenCV Binding"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012-2013 François Jouen. All rights reserved."
	License: 	"BSD-3 - https:;github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;do %cxcore.r ; we need for cvGetErrStatus
;/************Below is declaration of error handling stuff in PLSuite manner**/

CVStatus: 	make integer! 0

;this part of CVStatus is compatible with IPLStatus. Some of below symbols are not [yet] used in OpenCV

CV_StsOk:                    0  ; everithing is ok                
CV_StsBackTrace:            -1  ; pseudo error for back trace     
CV_StsError:                -2  ; unknown /unspecified error      
CV_StsInternal:             -3  ; internal error (bad state)      
CV_StsNoMem:                -4  ; insufficient memory             
CV_StsBadArg:               -5  ; function arg/param is bad       
CV_StsBadFunc:              -6  ; unsupported function            
CV_StsNoConv:               -7  ; iter. didn't converge           
CV_StsAutoTrace:            -8  ; tracing                         
CV_HeaderIsNull:            -9  ; image header is NULL            
CV_BadImageSize:            -10 ; image size is invalid           
CV_BadOffset:               -11 ; offset is invalid               
CV_BadDataPtr:              -12 ;
CV_BadStep:                 -13 ;
CV_BadModelOrChSeq:         -14 ;
CV_BadNumChannels:          -15 ;
CV_BadNumChannel1U:         -16 ;
CV_BadDepth:                -17 ;
CV_BadAlphaChannel:        -18 ;
CV_BadOrder:                -19 ;
CV_BadOrigin:               -20 ;
CV_BadAlign:                -21 ;
CV_BadCallBack:             -22 ;
CV_BadTileSize:             -23 ;
CV_BadCOI:                  -24 ;
CV_BadROISize:              -25 ;
CV_MaskIsTiled:             -26 ;
CV_StsNullPtr:                -27 ; null pointer 
CV_StsVecLengthErr:           -28 ; incorrect vector length 
CV_StsFilterStructContentErr: -29 ; incorr. filter structure content 
CV_StsKernelStructContentErr: -30 ; incorr. transform kernel content 
CV_StsFilterOffsetErr:        -31 ; incorrect filter ofset value 
;extra for CV 
CV_StsBadSize:                -201 ; the input/output structure size is incorrect  
CV_StsDivByZero:              -202 ; division by zero 
CV_StsInplaceNotSupported:    -203 ; in-place operation is not supported 
CV_StsObjectNotFound:         -204 ; request can't be completed 
CV_StsUnmatchedFormats:       -205 ; formats of input/output arrays differ 
CV_StsBadFlag:                -206 ; flag is wrong or not supported   
CV_StsBadPoint:               -207 ; bad CvPoint  
CV_StsBadMask:                -208 ; bad format of mask (neither 8uC1 nor 8sC1)
CV_StsUnmatchedSizes:         -209 ; sizes of input/output structures do not match 
CV_StsUnsupportedFormat:      -210 ; the data format/type is not supported by the function
CV_StsOutOfRange:             -211 ; some of parameters are out of range 
CV_StsParseError:             -212 ; invalid syntax/structure of the parsed file 
CV_StsNotImplemented:         -213 ; the requested function/feature is not implemented 
CV_StsBadMemBlock:            -214 ; an allocated block has been corrupted 
