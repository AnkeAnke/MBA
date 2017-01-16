clear;
close;
clc;

%img = imgToGrey(imread('test.png'));
img = DicomSeriesViewT1T2();
imshow(img);

normCut(img, 8);
