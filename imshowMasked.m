function imshowMasked( img, mask, slice )
%IMSHOWMASKED Show the image in the set figure with red highlight on masked
%area
%   Will highlight points where mask = 1.
%   Assume 0 or nan everywhere else.
%   Works on 3D tensors as well.
    
% Assume 2D image or 3D image with slice chosen.
    if nargin < 3 && ndims(img) > 2
            display('choose a slice please');
    end

    if nargin == 3
        img = img(:,:,slice);
        mask = mask(:,:,slice);
    end
    
    img = double(img);
    mask = double(mask);
    
    maxVal = max(max(max(img)));
    
    imshow(img+mask*maxVal, [0 2*maxVal]);
    halfMap = [linspace(0,1,128)' linspace(0,1,128)' linspace(0,1,128)'
               linspace(0.5,1,128)' linspace(0,1,128)' linspace(0,1,128)'];
    colormap(halfMap);
end

