% dcmImgs as dicom image series strip (containing all), 
% dcmImgSize as dimension of one image on the dicom image series strip, 
% dcmImageIndex as index of image on the dicom image series strip
function VertebraSegmentation( dcmImgs, dcmImgSize, dcmImageIndex )
%VERTEBRASEGMENTATION Segmentation of a chosen (via user input) vertebra.
    % Span a rectangle on dicom image (from left to right only, at the
    % moment!).
    [left,top] = ginput(1);
    [right,bottom] = ginput(1);
    
    %halfLength = 25;
    %[centerX,centerY] = ginput(1);

    % Fill initial mask with ones, for following iterative active contour algotihm.
    mask = zeros(dcmImgSize);
    mask(floor(top):floor(bottom),floor(left):floor(right)) = 1;
    
    %mask = zeros(dcmImgSize);
    %mask(floor(centerX),floor(centerY)) = 1;

    % Initial rectangular box mask, imshow here for debug purposes.
    figure, imshow(mask);
    title('Initial Contour Location');
    
    % Get the current image of the dicom image series strip.
    dcmImg=dcmImgs(1:dcmImgSize(1),1+dcmImageIndex*dcmImgSize(2):dcmImgSize(2)+dcmImageIndex*dcmImgSize(2));
    
    if ~isempty(dcmImg)
        % This will be the final output
        
        figure; 
        
        H = fspecial('laplacian',0.75);
        Laplacian = imfilter(dcmImg,H,'replicate');
        %figure, imshow(Laplacian);
        subplot(2,3,1);imshow(Laplacian);
        title('Laplacian');
        
        bw = activecontour(dcmImg,mask,200,'Chan-Vese',3.0); %Additional parameter 
                                                             %'SmoothFactor' makes a 
                                                             %huge difference (set 
                                                             %to 1.5 gives really 
                                                             %good
                                                             %results).
                                                             
        %figure, imshow(bw);
        subplot(2,3,2);imshow(bw);
        title('Segmented Image');
        
        % Clipped original image with the iteratively obtained segmentation
        % mask.
        segmentedVertebraImgContourMaskClipped = uint16(bw) .* dcmImg;
        %segmentedVertebraImgContourMaskClipped = double(bw) .* dcmImg;

        %figure, imshow(segmentedVertebraImgContourMaskClipped);
        subplot(2,3,3);imshow(segmentedVertebraImgContourMaskClipped);
        title('Segmented Dicom Image');
        
        % Previous result clipped with the initial rectangular box mask to
        % potentially give an even more desired result.
        segmentedVertebraImgInitialMaskClipped = uint16(mask) .* segmentedVertebraImgContourMaskClipped;
        %segmentedVertebraImgInitialMaskClipped = double(mask) .* segmentedVertebraImgContourMaskClipped;
        
        %figure, imshow(segmentedVertebraImgInitialMaskClipped);
        subplot(2,3,4);imshow(segmentedVertebraImgInitialMaskClipped);
        title('Segmented Dicom Image');
    end
end

