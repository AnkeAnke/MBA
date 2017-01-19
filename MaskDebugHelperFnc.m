function MaskDebugHelperFnc( dcmImgsT1, dcmImgsT2, resultMask, index)
%MASKDEBUGHELPERFNC Summary of this function goes here
%   Detailed explanation goes here
    masks=ComputeAllMasks( dcmImgsT1, dcmImgsT2, resultMask, index);

    intitalMaskIndex=0;
    initialMaskImg = (masks(:,:,intitalMaskIndex+1));

    figureHandle=figure;
    imshow(initialMaskImg);
    title(sprintf('Current DCM Image Index: %d',intitalMaskIndex));

    set(figureHandle,'windowscrollWheelFcn', {@showDCMImagesColorMapped,dcmImgsT1,masks,size(dcmImgsT1,3)});

end

