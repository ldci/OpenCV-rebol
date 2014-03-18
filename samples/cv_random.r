#! /usr/bin/rebolREBOL [	Title:		"OpenCV Tests: Random functions "	Author:		"Fran�ois Jouen"	Rights:		"Copyright (c) 2012-2014 Fran�ois Jouen. All rights reserved."	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"]do %../opencv.rset 'appDir what-dir wName: "Image 1 [space to continue]"depth: IPL_DEPTH_32F; size: make struct! CvSize! [640 480]isource: cvCreateImage size/width size/height depth 3&isource: as-pointer! isourcecvZero &isourcecvNamedWindow wName CV_WINDOW_AUTOSIZE cvShowImage wName &isource cvWaitKey 0cvRNG nowp1: cvScalar 0 0 0 0p2: cvScalar random 255  random 255 random 255 random 255ptr: make struct! [float [decimal!]] reduce [random 255];CV_RAND_UNIcvRandArr ptr &isource CV_RAND_UNI p1/v0 p1/v1 p1/v2 p1/v3 p2/v0 p2/v1 p2/v2 p2/v3cvShowImage wname &isourcecvWaitKey 0;CV_RAND_NORMALcvRandArr ptr &isource CV_RAND_NORMAL p1/v0 p1/v1 p1/v2 p1/v3 p2/v0 p2/v1 p2/v2 p2/v3cvShowImage wname &isourcecvWaitKey 0cvRandShuffle &isource ptr 1.0cvShowImage wname &isourcecvWaitKey 0print "Done"cvReleaseImage &isourcepicture:  to-string to-local-file join appDir "images/lena.tiff"img: cvLoadImage picture CV_LOAD_IMAGE_COLOR&img: as-pointer! imgcvShowImage "Test" &imgcvShowImage wname &isourcecvWaitKey 0s0: cvCreateImage img/width img/height IPL_DEPTH_8U 1s1: cvCreateImage img/width img/height IPL_DEPTH_8U 1s2: cvCreateImage img/width img/height IPL_DEPTH_8U 1&s0: as-pointer! s0&s1: as-pointer! s1&s2: as-pointer! s2cvNamedWindow "Sorted Image" CV_WINDOW_AUTOSIZEcvSplit &img &s0 &s1 &s2 nonecvSort &s0 none none CV_SORT_EVERY_ROW + CV_SORT_DESCENDINGcvShowImage "Sorted Image" &s0cvWaitKey 0; test with REBOLcvRSort s2 s0 cvShowImage "Sorted Image" &s0cvWaitKey 0print "Done"cvReleaseImage img