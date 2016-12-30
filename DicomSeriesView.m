function DicomSeriesView()
%DICOMSERIESVIEW Implementation of a simple dicom image series scroll 
%viewer and segmenting a chosen area (in this case works well with a 
%vertebra).

%   Choosing a vertebra, as intended:
%       - scroll through dicom image series
%       - if you settled for one press the 'space' key
%       - span a rectangular box, with two points, which you determine via
%         two clicks on the dicom image (first upper left point, then lower 
%         right point, currently only works that way!)
%       - for a desired result rectangular box must enclose whole damaged 
%         vertebra area and its both spanning points should lie on the
%         darkest area surrounding the vertebra

close all;
clear all;
clc;

% This index contains the current index of a dicom image series.
persistent dcmImageIndex;
dcmImageIndex = 0;

dcmFileListing = dir('Working_Data');

% Path contains current dicom image series. Can handle only one dicom seris
% at a time at the moment.
addpath('Working_Data');

% Load all images of 
dcmImgs = [];
dcmImgSize = [0 0];
maxIndex = 0;
for i=1:length(dcmFileListing)
    index=strfind(dcmFileListing(i).name,'.0.dcm');
    if ~isempty(index)
        maxIndex=maxIndex+1;
        dcmImgs = [dcmImgs dicomread(dcmFileListing(i).name)];
        if dcmImgSize(1)<=0 || dcmImgSize(2)<=0
            dcmImgSize=size(dicomread(dcmFileListing(i).name));
        end
    end
end

% 'Normalize' dicom image values. (Works well as is)
dcmImgs=(max(dcmImgs(:)/4.0))*dcmImgs;
%dcmImgs2=double(1.0/(2.0*max(dcmImgs(:))))*double(dcmImgs);

figureHandle=figure;
imshow(dcmImgs(1:dcmImgSize(1),1+dcmImageIndex*dcmImgSize(2):dcmImgSize(2)+dcmImageIndex*dcmImgSize(2)));
title(sprintf('Current DCM Image Index: %d',dcmImageIndex));

set(figureHandle,'windowscrollWheelFcn', {@showDCMImage,dcmImgs,dcmImgSize,maxIndex});
set(figureHandle,'KeyPressFcn', {@key_pressed_fcn,dcmImgs,dcmImgSize});

% Following callback functions are implemented as nested for the sake of 
% simplicity and because currently i am not aware of a other/better way.

% Nested callback function to scroll and show images of the dicom image
% series strip.
function showDCMImage(~,eventData,dcmImgs,dcmImgSize,maxIndex)

    persistent scrollViewIndex;
    if isempty(scrollViewIndex)
        scrollViewIndex = 0;
    else
        if eventData.VerticalScrollCount > 0
            scrollViewIndex = mod(scrollViewIndex-1,maxIndex);
        else
            scrollViewIndex = mod(scrollViewIndex+1,maxIndex);
        end
    end;
    dcmImageIndex=scrollViewIndex;
    imshow(dcmImgs(1:dcmImgSize(1),1+scrollViewIndex*dcmImgSize(2):dcmImgSize(2)+scrollViewIndex*dcmImgSize(2)));
    title(sprintf('Current DCM Image Index: %d',scrollViewIndex));
end

% Nested callback function to call the 'VertebraSegmmentation' function 
% upon pressing the space key.
function key_pressed_fcn( figureObject, ~, dcmImgs, dcmImgSize)
    if strcmp(get(figureObject, 'CurrentKey'),'space')
        VertebraSegmentation( dcmImgs, dcmImgSize, dcmImageIndex );
    end
end

rmpath('Working_Data');

end





