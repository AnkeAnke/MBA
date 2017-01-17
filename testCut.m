clear all;
close all;
clc;

% This index contains the current index of a dicom image series.
addpath('./Working_Data/T1');
addpath('./Working_Data/T2');

dcmFileListingT1 = dir('Working_Data/T1');
dcmFileListingT2 = dir('Working_Data/T2');

% Path contains current dicom image series. Can handle only one dicom seris
% at a time at the moment.
addpath('Working_Data');

% Load all images of dicom into a multidimensional array.
% Weirdly dicom image values are initially stored as double, convert needed
% to uint16. Cant stay like this if no information loss as uint16 to double.
dcmImgsT1 = [];
dcmImgsT2 = [];
dcmImgSize = [0 0];
maxIndex = 0;
for i=1:length(dcmFileListingT1)
    index=strfind(dcmFileListingT1(i).name,'.0.dcm');
    if ~isempty(index)
        maxIndex=maxIndex+1;
        dcmImgsT1(:,:,maxIndex) = dicomread(dcmFileListingT1(i).name);
        dcmImgsT2(:,:,maxIndex) = dicomread(dcmFileListingT2(i).name);
        if dcmImgSize(1)<=0 || dcmImgSize(2)<=0
            dcmImgSize=size(dicomread(dcmFileListingT1(i).name));
        end
    end
end

%originalDcmImgsT1=dcmImgsT1;
%originalDcmImgsT2=dcmImgsT2;

% 'Normalize' dicom image values. (Works well as is)
%dcmImgsT1=(max(dcmImgsT1(:)/4.0))*dcmImgsT1;
%dcmImgsT2=(max(dcmImgsT2(:)/2.0))*dcmImgsT2;
%dcmImgs2=double(1.0/(2.0*max(dcmImgs(:))))*double(dcmImgs);

intitaldcmIndex=0;
initialDCMImg = max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,intitaldcmIndex+1));

figureHandle=figure;
imshow(initialDCMImg);
title(sprintf('Current DCM Image Index: %d',intitaldcmIndex));

% create structure of handles
myhandles = guihandles(figureHandle); 
% Add some additional data as a new field called numberOfErrors
myHandles.scrollViewIndex = intitaldcmIndex; 
% Save the structure
guidata(figureHandle,myHandles);

set(figureHandle,'windowscrollWheelFcn', {@showDCMImages,max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2),maxIndex});
set(figureHandle,'KeyPressFcn', {@space_key_pressed_fnc,dcmImgsT1,dcmImgsT2});

rmpath('./Working_Data/T1');
rmpath('./Working_Data/T2');

% Normalized cut test
%normCut(img, 8);

% Your part
%img = imgToGrey(imread('test.png'));
% img = DicomSeriesViewT1T2();
% imshow(img)

%mask = ones(size(img));
%mask = imread('testmask.png');
%mask = mod(mask(:,:,1),2);
%minVal = min(img(mask>0))

%display('min val found. Going on');
%normCut(img, mask, 8, minVal);
%normCut(img, mask, 8, minVal);
