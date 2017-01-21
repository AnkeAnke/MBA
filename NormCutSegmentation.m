function [result] = NormCutSegmentation( img, mask, neighborhood, minval, viewSlice, variant)
%NORMCUTSEGMENTATION Segment the image recursively
%   Split the image in half using normalized cuts. Reinitialize the 
%   Possible variants: minvar, 

if nargin < 5
    viewSlice = ceil(size(img,3)/3);
end

if nargin < 6
    variant = 'minvar';
end

%numSlices = size(img,3);


imgOld = img;
% if ndims(img) == 3
%     img  =  img(:,:,ceil(size(img,3)/2) );
%     mask = mask(:,:,ceil(size(img,3)/2));
% end

% ===== Filter Image ===== %
% Emphasize the calue region around the minval, where we expect the cement.
% Map to qurtic root.
% img = sqrt(img);

figure;
subplot(1,2,1); imshowMasked(img, mask, viewSlice);

% Reduce the image to the minimal axis-parallel box around the mask.
[minBox,maxBox] = MaskBox(mask);
img  =  img(minBox(1):maxBox(1), minBox(2):maxBox(2), minBox(3):maxBox(3));
mask = mask(minBox(1):maxBox(1), minBox(2):maxBox(2), minBox(3):maxBox(3));

subplot(1,2,2); imshowMasked(img, mask, viewSlice);

% ======= Display cut eigenvectors ======= %
% Cut out num eigenvector.
currentSegmentation = mask - 1;
currentMask = mask;

if strcmp(variant, 'recursive')
    [segNew] = RecursiveCut(1, img, currentMask, neighborhood, minval, currentSegmentation, viewSlice, 1); 
elseif strcmp(variant, 'equalarea')
    [segNew] = EqualSizedNormCut(img, currentMask, neighborhood, minval, currentSegmentation, viewSlice, 1); 
elseif strcmp(variant, 'minvar')
    [segNew] = MinVarNormCut(img, currentMask, neighborhood, minval, currentSegmentation, viewSlice, 1); 
elseif strcmp(variant, 'eigen')
     [segNew] = normCut(img, currentMask, neighborhood, minval, currentSegmentation, viewSlice, 4, true); 
else
    display('Warning: no known variant! Aborting.');
    return;
end
    
    figure;
    imshowSegments(img(:,:,viewSlice), segNew+1);  
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
imshow(vars(:,:,viewSlice), [0, max(max(max(vars)))]);
title('Variance per Segment');
freezeColors;

subplot(1,2,2);
imshowMasked(img(:,:,viewSlice), result);
title('Resulting Segmentation');
freezeColors;

resFull = zeros(size(imgOld));
resFull(minBox(1):maxBox(1), minBox(2):maxBox(2), minBox(3):maxBox(3)) = result;
result = repmat(resFull,1,1,numSlices);

end

