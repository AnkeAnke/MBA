function imshowSegments( img, segments)
%IMSHOWSEGMENTS Show the image colored by segments. Random colormap.
    
% Assume 2D image or 3D image with slice chosen.
    if nargin < 3 && ndims(img) > 2
            display('choose a slice please');
    end

    if nargin == 3
        img = img(slice);
    end
    
    % Some important variables.
    maxVal = max(max(max(img)));
    minVal = min(min(min(img)));
    numSegs = max(max(max(segments)));
    imshow(img+segments*maxVal, [minVal numSegs*maxVal]);
    
    % Normal grey map, linear
    halfMap = [linspace(0,1,128)' linspace(0,1,128)' linspace(0,1,128)'
               zeros(128*numSegs, 3)];
    
    % For each segment ID, add the colormap with a random color.
    colors = jet(numSegs);
    for s=1:numSegs
        halfMap( ((s)*128+1):((s+1)*128), : ) = ...
            [linspace(0.1,0.8,128)' linspace(0.1,0.8,128)' linspace(0.1,0.8,128)'] * diag(colors(s,:));
    end
           
    colormap(halfMap);
    
%     figure;
%     imshow(reshape(halfMap,128, numSegs+1,3)); 
end

