function imSeriesShowMasked( imgs, masks, sliceIndex )
%IMSERIESSHOWMASKED Summary of this function goes here
%   Detailed explanation goes here
    intitalMaskIndex=sliceIndex;

    figureHandle=figure;
    %imshow(initialMaskImg);

    img = imgs(:,:,sliceIndex);
    mask = masks(:,:,sliceIndex);
    imshowMasked( img, mask );
    title(sprintf('Current DCM Image Index: %d',intitalMaskIndex));

    set(figureHandle,'windowscrollWheelFcn', {@showDCMImagesColorMapped,imgs,masks,size(imgs,3)});
end

