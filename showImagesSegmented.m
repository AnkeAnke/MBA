%color map hard coded.
function showImagesSegmented(~,eventData,dcmImgs,segments,maxIndex)

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

    img = dcmImgs(:,:,scrollViewIndex+1);
    segment = segments(:,:,scrollViewIndex+1);
    imshowSegments( img, segment );
    title(sprintf('Current DCM Image Index: %d',scrollViewIndex));
end

