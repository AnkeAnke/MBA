function [segNew] = RecursiveCut(depth, img, mask, neighborhood, minval, currentSegmentation, viewSlice, numCuts )
%RECURSIVECUT Recursively cut the image.
%   Input: Number of subdivisions per step. Default: 2

if depth > 4
    segNew = currentSegmentation;
    return;
end

% Default: Cut into 4 pieces.
if nargin < 7
    viewSlice = 1;
end

% Default: Cut into 4 pieces.
if nargin < 8
    numCuts = 1;
end


% One step.
[segNew, stop] = normCut(img,mask,neighborhood,minval, currentSegmentation, viewSlice, numCuts);
maxMask = max(max(max(segNew)));

if stop
    % Check if anything changed.
    diff = sum(sum(sum( abs(currentSegmentation-segNew) )));
    if diff == 0
        return; 
    end
end

% Recursion for each segment.
for m = 0:maxMask
    mMask = segNew;
    mMask(mMask ~= m) = 0;
    mMask(segNew == m) = 1;
    
    % If the mask is empty or very small, continue.
    sumMask = sum(sum(sum(mMask)));
    if sumMask < 8
        continue;
    end
    
    % We can split again.
    [segNew] = RecursiveCut(depth+1,img, mMask, neighborhood, minval, segNew, numCuts);
end
    
end

