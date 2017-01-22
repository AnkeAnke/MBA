%Call here the normalized graph cut segmentation.
function space_key_pressed_fnc( figureObject, ~, dcmImgsT1, dcmImgsT2)
    if strcmp(get(figureObject, 'CurrentKey'),'space')
        % Get the structure using guidata in the local function
        myhandles = guidata(gcbo);
        sliceIndex = myhandles.scrollViewIndex+1;
        mask2D=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,sliceIndex)), uint16(dcmImgsT2(:,:,sliceIndex)) );
        resultMask = ComputeAllMasksSimple(dcmImgsT2, mask2D);
        %close(figureObject);
        
        MaskDebugHelperFnc(dcmImgsT1, dcmImgsT2, resultMask, sliceIndex);
        
        %figure;
        %imshow(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1)));
        
        %figure;
        %imshow(uint16(resultMask).*(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1))));
        
        %Call here the normalized graph cut segmentation.
        %img = (dcmImgsT2(:,:,sliceIndex));

        %threshold=200;
        %thresheldDcmImgsT2=ThresholdImages(uint16(dcmImgsT2), threshold);
        
        % If we have a better "hole indicator", exchange the parameter.
        [mask3D,seg3D] = NormCutSegmentation(dcmImgsT2, resultMask, 2, 30, sliceIndex, 'eigen');
        
%         segments3D=[];
%         maxIndex=size(segments3D,3);
        figureHandle = figure;
        set(figureHandle,'windowscrollWheelFcn', {@showImagesSegmented,dcmImgsT2,seg3D});
        %imSeriesShowMasked( dcmImgsT2, result3D, sliceIndex );
        %imSeriesShowMasked( thresheldDcmImgsT2, result3D, sliceIndex );
    end
end