%Call here the normalized graph cut segmentation.
function space_key_pressed_fnc( figureObject, ~, dcmImgsT1, dcmImgsT2)
    if strcmp(get(figureObject, 'CurrentKey'),'space')
        % Get the structure using guidata in the local function
        myhandles = guidata(gcbo);
        [resultMask]=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,myhandles.scrollViewIndex+1)), uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1)) );
        close(figureObject);
        
        %figure;
        %imshow(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1)));
        
        %figure;
        %imshow(uint16(resultMask).*(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1))));
        
        %Call here the normalized graph cut segmentation.
    end
end