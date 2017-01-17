%color map hard coded.
function showDCMImagesColorMapped(~,eventData,dcmImgs,masks,maxIndex)

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
    
    % Get the structure using guidata in the local function
    myhandles = guidata(gcbo);
    % Modify the value of your counter
    myhandles.scrollViewIndex = scrollViewIndex;
    % Save the change you made to the structure
    guidata(gcbo,myhandles);
    
    img = dcmImgs(:,:,scrollViewIndex+1) + masks(:,:,scrollViewIndex+1)*max(max(dcmImgs(:,:,scrollViewIndex+1)));
    imshow(img, [min(min(img)), max(max(img))] );
    
    title(sprintf('Current DCM Image Index: %d',scrollViewIndex));
    
    halfMap = [linspace(0,1,128)' linspace(0,1,128)' linspace(0,1,128)'
               linspace(0.2,1,128)' linspace(0,1,128)' linspace(0,1,128)'];
    colormap(halfMap);
    colorbar;
end

