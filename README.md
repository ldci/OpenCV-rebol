# REBOL Bindings for OpenCV
### http://opencv.org/

This binding has been tested with Mac OSX 10.9.1, Windows XP and Seven.
This binding allows access OpenCV functions (http://en.wikipedia.org/wiki/OpenCV).
This binding can be used with 1.0, 2.0 and higher version of the library.

## New version!!!
Simplification in using rebol structures. 
Routines devoted to memory (e.g. cvReleaseImage image)  are now defined as rebol functions.
In order to be coherent with Red/System wrapping routines require (in most cases) pointer as parameter.
Included as-pointer! function which returns structure address. this will be progressively extended to all routines. Be patient :)

## Warning
You must use 32-bit version of dynamically linked libraries. 
Work under progress!

### opencv.r 
All you need for using OpenCV with REBOL. Enjoy!

### libs dir
This directory includes different files for the wrapping.

### samples dir
Several scripts which demonstrate how to use OpenCV with REBOL.
These scripts allow to play with camera, images and matrices.
cv_files.r are translations from c code to REBOL and some tests I wrote for debugging.
r_files.r demonstrate how to integrate OpenCV functions inside REBOL code. 
rg_files.r use wonderful Ashley Truter's  graphical libary for Rebol
This dir also includes an images dir and a movies dir with some graphical files to play with.
Cascades dir includes some sample of classifiers required for some programs

## enjoy


