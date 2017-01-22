function imshowSegments(img, segments, slice)
%IMSHOWSEGMENTS Show the image colored by segments. Random colormap.
    
% Assume 2D image or 3D image with slice chosen.
    if nargin < 3 && ndims(img) > 2
            display('choose a slice please');
    end
    
    % Some important variables.
    maxVal = max(max(max(img))); % Offset to circumvent wrong interpolation at cuts.
    numSegs = max(max(max(segments)));

    % Use this as random seed. Should produce the same segment colors in
    % all slices of an image
    rng(numel(segments) + numSegs);
    permutation = randperm(numSegs + 1);
    
    if nargin >= 3
        img = img(:,:,slice);
        segments = segments(:,:,slice);
    end
    
    
    img(img < 0) = 0;
    if isnan(maxVal)
        imshow(zeros(size(img)));
        return;
    end
    
    stackSegs = segments;
    stackSegs(~(stackSegs>=0)) = numSegs + 1;
        % Normal grey map, linear
    halfMap = zeros(128*max(numSegs+1,1), 3);
    %linspace(0,1,128)' linspace(0,1,128)' linspace(0,1,128)';...
               
    % For each segment ID, add the colormap with a random color.
    colors = jet(numSegs+1)*0.5 + 0.5;
    % Interleave colors.
    % One cut always changes the ID by 1, do this to hichen the contrast.
    % colors(2:2:numSegs+1, :) = colors(2*floor((numSegs+1)/2):-2:2, :);
    
    
    colors = [colors(permutation, :) ; [1 1 1]];
    for s=0:numSegs+1
%         % Some green pixels to find errors in mapping.
%         % As long as you don't see them, everything is fine.
%         halfMap((s*128+1):(s*128+7), : ) = repmat([0 1 0], 7,1);
        halfMap( (s*128+1):((s+1)*128), : ) = ...
            [linspace(0.1,0.8,128)' linspace(0.1,0.8,128)' linspace(0.1,0.8,128)'] * diag(colors(s+1,:));
    end
    
    imshow(img+stackSegs*maxVal+10, [0 (numSegs+2)*maxVal]);

    colormap(halfMap);
end

