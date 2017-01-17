clear;
close;
clc;

img = imgToGrey(imread('test.png'));
% img = DicomSeriesViewT1T2();
% imshow(img)

%mask = ones(size(img));
mask = imread('testmask.png');
mask = mod(mask(:,:,1),2);
minVal = min(img(mask>0))

display('min val found. Going on');
%normCut(img, mask, 8, minVal);
normCut(img, mask, 8, minVal);
