%Call here the normalized graph cut segmentation.
function space_key_pressed_fnc( figureObject, ~, dcmImgsT1, dcmImgsT2)
    if strcmp(get(figureObject, 'CurrentKey'),'space')
        % Get the structure using guidata in the local function
        myhandles = guidata(gcbo);
        index = myhandles.scrollViewIndex+1;
        resultMask=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,index)), uint16(dcmImgsT2(:,:,index)) );
        close(figureObject);
        
        masks=[];
        
        masks(:,:,index)=resultMask;
        
        for i=index+1:size(dcmImgsT1,3)
            i
            masks(:,:,i)=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), masks(:,:,i-1) );
        end
        
        for i=index-1:-1:1
            i
            masks(:,:,i)=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), masks(:,:,i+1) );
        end
        
        intitalMaskIndex=0;
        initialMaskImg = (masks(:,:,intitalMaskIndex+1));
        
        figureHandle=figure;
        imshow(initialMaskImg);
        title(sprintf('Current DCM Image Index: %d',intitalMaskIndex));
        
        set(figureHandle,'windowscrollWheelFcn', {@showDCMImagesColorMapped,dcmImgsT1,masks,size(dcmImgsT1,3)});
        
        %figure;
        %imshow(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1)));
        
        %figure;
        %imshow(uint16(resultMask).*(max(dcmImgsT2(:)/2.0)*uint16(dcmImgsT2(:,:,myhandles.scrollViewIndex+1))));
        
        %Call here the normalized graph cut segmentation.
    end
end