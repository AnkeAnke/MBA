function imshowSegments(img, segments, slice)
%IMSHOWSEGMENTS Show the image colored by segments. Random colormap.
    
% Assume 2D image or 3D image with slice chosen.
    if nargin < 3 && ndims(img) > 2
            display('choose a slice please');
    end

    if nargin == 3
        img = img(:,:,slice);
        segments = segments(:,:,slice);
    end
    
    % Some important variables.
    maxVal = max(max(max(img)))+20; % Offset to circumvent wrong interpolation at cuts.
    img(img < 0) = 0;
    numSegs = max(max(max(segments)));
    imshow(img+segments*maxVal+10, [0 (numSegs+1)*maxVal]);
    
    % Normal grey map, linear
    halfMap = [linspace(0,1,128)' linspace(0,1,128)' linspace(0,1,128)'
               zeros(128*max(numSegs-1,0), 3)];
    
    % For each segment ID, add the colormap with a random color.
    colors = jet(numSegs+1)*0.5 + 0.5;
    % Interleave colors.
    % One cut always changes the ID by 1, do this to hichen the contrast.
    colors(2:2:numSegs+1, :) = colors(2*floor((numSegs+1)/2):-2:2, :);
    for s=0:numSegs
        % Some green pixels to find errors in mapping.
        % As long as you don't see them, everything is fine.
        halfMap((s*128+1):(s*128+7), : ) = repmat([0 1 0], 7,1);
        halfMap( ((s)*128+1):((s+1)*128), : ) = ...
            [linspace(0.1,0.8,128)' linspace(0.1,0.8,128)' linspace(0.1,0.8,128)'] * diag(colors(s+1,:));
    end
           
    colormap(halfMap);
    freezeColors;
end

