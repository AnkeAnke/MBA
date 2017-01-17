% dcmImgs as dicom fimage series strip (containing all), 
% dcmImgSize as dimension of one image on the dicom image series strip, 
% dcmImageIndex as index of image on the dicom image series strip
function [resultMask] = VertebraSegmentationT1T2V2(dcmImgT1, dcmImgT2, initialMask)
%VERTEBRASEGMENTATION Segmentation of a chosen (via user input) vertebra.
    mask = zeros(size(dcmImgT1));
    if nargin == 3
        mask=initialMask;
    end
    if nargin < 3
        % Span a rectangle on dicom image (from left to right only, at the
        % moment!).
        [left,top] = ginput(1);
        [right,bottom] = ginput(1);
        % Fill initial mask with ones, for following iterative active contour algotihm.
        mask = zeros(size(dcmImgT1));
        mask(floor(top):floor(bottom),floor(left):floor(right)) = 1;
    end
    % Initial rectangular box mask, imshow here for debug purposes.
    %figure;
    %subplot(2,3,1);imshow(mask);
    %title('Initial Contour Location');
    
    if ~isempty(dcmImgT1) && ~isempty(dcmImgT2)
        bwT1 = activecontour(dcmImgT1,mask,200,'Chan-Vese',3.0); %Additional parameter 
                                                                 %'SmoothFactor' makes a 
                                                                 %huge difference (set 
                                                                 %to 3.0 gives really 
                                                                 %good
                                                                 %results).
        bwT2 = activecontour(dcmImgT2,mask,200,'Chan-Vese',3.0);
                                  
        %subplot(2,3,2);imshow(bwT1);
        %title('Segmented Image T1');
        %subplot(2,3,3);imshow(bwT2);
        %title('Segmented Image T2');
        
        % This will be the final output.
        combinedmaskT1T2 = bwT1.*bwT2;
        %subplot(2,3,4);imshow(combinedmaskT1T2);
        %title('Segmented Image combinedmaskT1T2');
        
        % Clipped original image with the iteratively obtained segmentation
        % mask.
        %segmentedVertebraImgContourMaskClippedT1 = uint16(combinedmaskT1T2) .* dcmImgT1;

        %subplot(2,3,5);imshow(segmentedVertebraImgContourMaskClippedT1);
        %title('Segmented Dicom Image T1');
        
        %segmentedVertebraImgContourMaskClippedT2 = uint16(combinedmaskT1T2) .* dcmImgT2;

        %subplot(2,3,6);imshow(segmentedVertebraImgContourMaskClippedT2);
        %title('Segmented Dicom Image T2');
        
        %figure;
        %imshow(segmentedVertebraImgContourMaskClippedT2);
        %title('Segmented Dicom Image T2');
    end
    
    resultMask = combinedmaskT1T2;
    
    %figure;
    %imshow(resultImage);
    %title('resultImage');
    
    %figure;
    %imshow(resultMask);
    %title('resultMask');
        
    return;
end



