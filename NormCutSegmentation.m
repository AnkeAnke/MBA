function [result] = NormCutSegmentation( img, mask, neighborhood, minval, variant)
%NORMCUTSEGMENTATION Segment the image recursively
%   Split the image in half using normalized cuts. Reinitialize the 
%   Possible variants: minvar, 

if nargin < 5
    variant = 'minvar'
end

numSlices = size(img,3);
imgOld = img;
if ndims(img) == 3
    img  =  img(:,:,1);
    mask = mask(:,:,1);
end

figure;
subplot(1,2,1); imshowMasked(img, mask);

% Reduce the image to the minimal axis-parallel box around the mask.
[minBox,maxBox] = MaskBox(mask);
img  =  img(minBox(1):maxBox(1), minBox(2):maxBox(2));
mask = mask(minBox(1):maxBox(1), minBox(2):maxBox(2));

subplot(1,2,2); imshowMasked(img, mask);

% Setup a new figure
% figure;
sEigs = 4;
h = sEigs/2 + 1;

% Show initial image
% subplot(2,h,1); imshow(img, [min(min(img)) max(max(img))]);
% colormap(gray);
% freezeColors;

% ======= Display cut eigenvectors ======= %
% Cut out num eigenvector.
currentSegmentation = mask - 1;
currentMask = mask;

if strcmp(variant, 'recursive')
    [segNew] = RecursiveCut(1, img, currentMask, neighborhood, minval, currentSegmentation, 2); 
elseif strcmp(variant, 'equalarea')
    [segNew] = EqualSizedNormCut(img, currentMask, neighborhood, minval, currentSegmentation, 2); 
elseif strcmp(variant, 'minvar')
    [segNew] = MinVarNormCut(img, currentMask, neighborhood, minval, currentSegmentation, 1); 
elseif strcmp(variant, 'eigen')
     [segNew] = normCut(img, currentMask, neighborhood, minval, currentSegmentation, 4, true); 
else
    display('Warning: no known variant! Aborting.');
    return;
end
    
    figure;
    imshowSegments(img, segNew+1);  
    freezeColors;
    
    maxMask = max(max(max(segNew)));

% ======= Final Segmentation ======= %

result = zeros(size(segNew));
vars = result;
% Recursion for each segment.
for m = 0:maxMask
    mMask = segNew;
    mMask(mMask ~= m) = 0;
    mMask(segNew == m) = 1;
    
    % If the mask is empty, continue.
    sumMask = sum(sum(sum(mMask)));
    if sumMask == 0
        continue;
    end
    
    % Choose filling or not.
    avg = mean(img(mMask==1));
    % variance = var(img(mMask==1))
    
    vars(mMask==1) = avg;
    if avg < 60 %avg-variance < minval && avg+variance > minval
        result(mMask==1) = 1;
    end
end

% Show final image
subplot(1,2,1);
imshow(vars, [0, max(max(max(vars)))]);
title('Variance per Segment');
freezeColors;

subplot(1,2,2);
imshowMasked(img, result);
title('Resulting Segmentation');
freezeColors;

resFull = zeros(size(imgOld,1), size(imgOld,2));
resFull(minBox(1):maxBox(1), minBox(2):maxBox(2)) = result;
result = repmat(resFull,1,1,numSlices);

end

