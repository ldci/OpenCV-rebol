#! /usr/bin/rebol
REBOL[
	Title:		"OpenCV cvtypes"
	Author:		"François Jouen"
	Rights:		"Copyright (c) 2012 François Jouen. All rights reserved."
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

do %cxtypes.r ;for stand alone testing

;spatial and central moments
CvMoments!: make struct! [
	;/* spatial moments */ all values should be double
    m00: [decimal!]
    m10: [decimal!]
    m01: [decimal!]
    m20: [decimal!]
    m11: [decimal!]
    m02: [decimal!]
    m30: [decimal!]
    m21: [decimal!]
    m12: [decimal!]
    m03: [decimal!]
    ; /* central moments */ 
    mu20: [decimal!]
    mu11: [decimal!]
    mu02: [decimal!]
    mu30: [decimal!]
    mu21: [decimal!]
    mu12: [decimal!]
    mu03: [decimal!]
    inv_sqrt_m00: [decimal!]		; /* m00 != 0 ? 1/sqrt(m00) : 0 */
] none 

;Hu invariants
CvHuMoments!: make struct! [
    hu1: [decimal!] 
    hu2: [decimal!] 
    hu3: [decimal!] 
    hu4: [decimal!] 
    hu5: [decimal!] 
    hu6: [decimal!] 
    hu7: [decimal!] 
] none

;**************************** Connected Component  **************************************
CvConnectedComp!: make struct! [
    area		[decimal!]	;area of the connected component
    value 		[int]  		; cvScalar!average color of the connected component
    rect 		[int]		;CvRect! ROI of the component
    contour 	[int]		;CvRect!optional component boundary (the contour might have child contours corresponding to the holes)
] none

;typedef struct _CvContourScanner* CvContourScanner;

;contour retrieval mode
CV_RETR_EXTERNAL:			 0
CV_RETR_LIST:			     1
CV_RETR_CCOMP:			     2
CV_RETR_TREE:			     3

;contour approximation method
CV_CHAIN_CODE:               0
CV_CHAIN_APPROX_NONE:        1
CV_CHAIN_APPROX_SIMPLE:      2
CV_CHAIN_APPROX_TC89_L1:     3
CV_CHAIN_APPROX_TC89_KCOS:   4
CV_LINK_RUNS:                5


;Freeman chain reader state 

;use array 8 lines 2 columns and pass as binary to the structure
_delta: array/initial [8 2] none
delta: to-binary mold _delta 

CvChainPtReader!: make struct! [
    csrf			[int] 		;CV_SEQ_READER_FIELDS!
    code			[integer!]
    pt				[int]		;cvPoint!
    deltas			[binary!]	;un tableau deltas[8][2];
] none

;initializes 8-element array for fast access to 3x3 neighborhood of a pixel
CV_INIT_3X3_DELTAS: func [step [integer!] nch [integer!] /local deltas] [       
	deltas: array/initial 8 0
	deltas/1: nch
	deltas/2: negate step + nch
	deltas/3: negate step
	deltas/4: negate step - nch
	deltas/5: negate nch
	deltas/6: step - nch
	deltas/7: step
	deltas/8: step + nch
	return deltas
]

;Contour tree header */ REVOIR pour CV_SEQUENCE_FIELDS
CvContourTree!: make struct! [
    csf			[integer!] 	;pointer to the result of CV_SEQUENCE_FIELDS funtion (see cxtypes.r)
    p1			[int] 		;cvPoint! the first point of the binary tree root segment
    p2			[int] 		;cvPoint!the last point of the binary tree root segment
] none

;Finds a sequence of convexity defects of given contour

CvConvexityDefect: make struct! [
    start		[int]			;cvPoint! point of the contour where the defect begins 
    end			[int]			;cvPoint! point of the contour where the defect ends 
    depth_point	[int]			;cvPoint!the farthest from the convex hull point within the defect
    depth		[decimal!]		;distance between the farthest point and the convex hull
] none

;************ Data structures and related enumerations for Planar Subdivisions ************/

CvSubdiv2DEdge: make integer! 4

CV_QUADEDGE2D_FIELDS!: make struct! [
	flags			[integer!]               
    pt_4			[int]		;pointer to struct CvSubdiv2DPoint* ];
    next_4          [int]   	;CvSubdiv2DEdge;
] none


CV_SUBDIV2D_POINT_FIELDS!: make struct!  [
    flags			[integer!]
    _first			[int] ;CvSubdiv2DEdge;
    pt              [int] ;CvPoint2D32f!
] none

CV_SUBDIV2D_VIRTUAL_POINT_FLAG:  Shift/left 1 30 

CvQuadEdge2D:func [edge]
[
    return (first CV_QUADEDGE2D_FIELDS!)
] 

CvSubdiv2DPoint!: make struct! [
    ptr		[int] ;CV_SUBDIV2D_POINT_FIELDS!
] none

CV_SUBDIV2D_FIELDS!: make struct! [ 
    ptr					[int] 		;CV_GRAPH_FIELDS!
    quad_edges			[integer!]         
    is_geometry_valid	[integer!]
    recent_edge			[integer!]
    topleft				[int] 		;CvPoint2D32f!
    bottomright			[int] 		;CvPoint2D32f!
] none


CvSubdiv2D!: make struct! compose/deep/only [
	ptr					[int] ;CV_SUBDIV2D_FIELDS!)
] none

CvSubdiv2DPointLocation: [
    CV_PTLOC_ERROR: -2
    CV_PTLOC_OUTSIDE_RECT: -1
    CV_PTLOC_INSIDE: 0
    CV_PTLOC_VERTEX: 1
    CV_PTLOC_ON_EDGE: 2
]

CvNextEdgeType: [
    CV_NEXT_AROUND_ORG:	#00
    CV_NEXT_AROUND_DST:	#22
    CV_PREV_AROUND_ORG:	#11
    CV_PREV_AROUND_DST:	#33
    CV_NEXT_AROUND_LEFT: #13
    CV_NEXT_AROUND_RIGHT: #31
    CV_PREV_AROUND_LEFT: #20
    CV_PREV_AROUND_RIGHT: #02
]

;get the next edge with the same origin point (counterwise)
CV_SUBDIV2D_NEXT_EDGE: func [edge]
[
	CvQuadEdge2D edge
	
	; & ~3))->next[(edge)&3])
]
 
;Defines for Distance Transform
CV_DIST_USER:    -1  ; User defined distance 
CV_DIST_L1:      1   ; distance = |x1-x2| + |y1-y2| 
CV_DIST_L2:      2   ; the simple euclidean distance 
CV_DIST_C:       3   ; distance = max(|x1-x2|,|y1-y2|) 
CV_DIST_L12:     4   ; L1-L2 metric: distance = 2(sqrt(1+x*x/2) - 1)) 
CV_DIST_FAIR:    5   ; distance = c^2(|x|/c-log(1+|x|/c)), c = 1.3998 
CV_DIST_WELSCH:  6   ; distance = c^2/2(1-exp(-(x/c)^2)), c = 2.9846 
CV_DIST_HUBER:   7   ; distance = |x|<c ? x^2/2 : c(|x|-c/2), c=1.345 

CvFilter:
[
    CV_GAUSSIAN_5x5: 7
]

CV_GAUSSIAN_5x5: 7

;/****************************************************************************************/
;/*                                    Older definitions                                 */
;/****************************************************************************************/
 
tCvVect32f: make decimal! 0.0
CvMatr32f: make decimal! 0.0
CvVect64d: make decimal! 0.0
CvMatr64d: make decimal! 0.0

_m: array/initial [3 3] none
m: to-binary mold _delta 
CvMatrix3!: struct!
[
    m;
]
 
CvConDensation!: make struct! [
    MP					[integer!]
    DP					[integer!]
    DynamMatr			[decimal!]		;Matrix of the linear Dynamics system
    State				[decimal!]		;Vector of State 
    SamplesNum          [integer!]		;Number of the Samples
    flSamples			[integer!]		;pointer array of the Sample Vectors (float**)
    flNewSamples		[integer!]		;pointer to temporary array of the Sample Vectors (float**)
    flConfidence		[integer!]		;pointer Confidence for each Sample (float*)
    flCumulative		[integer!]		;idem Cumulative confidence
    Temp				[integer!]		;idem Temporary vector
    RandomSample		[integer!]		;idem RandomVector to update sample set
    RandS				[integer!]		; pointer to Array of structures to generate random vectors
] none


;standard Kalman filter (in G. Welch' and G. Bishop's notation):
;  x(k)=A*x(k-1)+B*u(k)+w(k)  p(w)~N(0,Q)
;  z(k)=H*x(k)+v(k),   p(v)~N(0,R)

CvKalman!: make struct! [
    MP						[integer!] 	; number of measurement vector dimensions */
    DP						[integer!]	; number of state vector dimensions */
    CP						[integer!]	; number of control vector dimensions */
    Cstate_pre         		[int]   	;CvMat! predicted state (x'(k)): x(k)=A*x(k-1)+B*u(k) */
    state_post				[int]		;CvMat! corrected state (x(k)): x(k)=x'(k)+K(k)*(z(k)-H*x'(k)) */
    transition_matrix		[int]		;CvMat! state transition matrix (A) */
    control_matrix			[int]		;CvMat! control matrix (B) (it is not used if there is no control)*/
    measurement_matrix		[int]		;CvMat! measurement matrix (H) */
    process_noise_cov		[int]		;CvMat! process noise covariance matrix (Q) */
    measurement_noise_cov	[int]		;CvMat! measurement noise covariance matrix (R) */
    error_cov_pre			[int]		;CvMat! priori error estimate covariance matrix (P'(k)):P'(k)=A*P(k-1)*At + Q)*/
    gain					[int]		;CvMat! Kalman gain matrix (K(k))  K(k)=P'(k)*Ht*inv(H*P'(k)*Ht+R)*/
    error_cov_post			[int]		;CvMat! posteriori error estimate covariance matrix (P(k)):P(k)=(I-K(k)*H)*P'(k) */
    temp1					[int]		;CvMat! temporary matrices */
    temp2					[int]		;CvMat!
    temp3					[int]		;CvMat!
    temp4					[int]		;CvMat!
    temp5					[int]		;CvMat!
] none

;/*********************** Haar-like Object Detection structures **************************/
CV_HAAR_MAGIC_VAL:    #42500000
CV_TYPE_NAME_HAAR:    "opencv-haar-classifier"


CV_IS_HAAR_CLASSIFIER: func [haar] [                                                   
	(haar != none!) && (CvHaarClassifierCascade!/flags & CV_MAGIC_MASK) = CV_HAAR_MAGIC_VAL
]
CV_HAAR_FEATURE_MAX:	3

CvHaarFeature!: struct! [
    tilted 		[integer!];
    rect 		[struct! [
    				r [CvRect!];
        			weight [decimal!];
    			]]CV_HAAR_FEATURE_MAX
] none

CvHaarClassifier!: make struct!  [
    count				[integer!]
    haar_feature		[int]		; CvHaarFeature! 
    threshold			[decimal!]
    left				[integer!]
    right				[integer!]
    alpha				[decimal!]
] none

CvHaarStageClassifier!: make struct! [
    count				[integer!];
    threshold			[decimal!]
    classifier			[int] 		;CvHaarClassifier!
    _next				[integer!]
    child				[integer!]
    parent				[integer!]
] none

CvHaarClassifierCascade!: make struct! [
    flags				[integer!]
    count				[integer!]
    orig_window_size 	[int] 		;CvSize!
    real_window_size	[int] 		;CvSize!
    scale				[decimal!]
    stage_classifier	[int] 		;CvHaarClassifier!
    hid_cascade			[int] 		;CvHaarClassifier!
] none

CvHidHaarClassifierCascade!: [ 
	ptr 				[int] 		;CvHaarClassifierCascade!
] none

CvAvgComp!: make struct!
[
    rect				[int] 		; CvRect!
    neighbors			[integer!]
]none 