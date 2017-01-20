%Call here the normalized graph cut segmentation.
function space_key_pressed_fnc( figureObject, ~, dcmImgsT1, dcmImgsT2)
    if strcmp(get(figureObject, 'CurrentKey'),'space')
        % Get the structure using guidata in the local function
        myhandles = guidata(gcbo);
        sliceIndex = myhandles.scrollViewIndex+1;
        resultMask=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,sliceIndex)), uint16(dcmImgsT2(:,:,sliceIndex)) );
        %close(figureObject);
        
        %MaskDebugHelperFnc(dcmImgsT1, dcmImgsT2, resultMask, sliceIndex);
        
        %figure;
        %imshow(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1)));
        
        %figure;
        %imshow(uint16(resultMask).*(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1))));
        
        %Call here the normalized graph cut segmentation.
        %img = (dcmImgsT2(:,:,sliceIndex));

        threshold=200;
        thresheldDcmImgsT2=ThresholdImages(uint16(dcmImgsT2), threshold);
        
        % If we have a better "hole indicator", exchange the parameter.
        result3D = NormCutSegmentation(dcmImgsT2, resultMask, 8, 30);
        
        %imSeriesShowMasked( dcmImgsT2, result3D, sliceIndex );
        imSeriesShowMasked( thresheldDcmImgsT2, result3D, sliceIndex );
    end
end