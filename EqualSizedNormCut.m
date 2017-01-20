function [segNew] = EqualSizedNormCut(img, mask, neighborhood, minval, currentSegmentation, numCuts )
%RECURSIVECUT Recursively cut the image.
%   Input: Number of subdivisions per step. Default: 2

% Default: Cut into 4 pieces.
if nargin < 6
    numCuts = 1;
end


% Initialize ssegmentation.
[segNew, stop] = normCut(img,mask,neighborhood,minval, currentSegmentation, numCuts);

% Maximum number of subdivisions.
for s = 1:5
    
    maxSeg = max(max(max(segNew)));
    maxSize = 0;
    maxSizeSeg = -1;
    
    maxSegUpdating = maxSeg;

    % For each segmeent.
    for m = 0:maxSeg
        bw = zeros(size(segNew));
        bw(segNew==m) = 1;
        CC = bwconncomp(bw);
        nSubSegs = CC.NumObjects;
        subSeg = CC.PixelIdxList;
        
        for s = 2:nSubSegs
            maxSegUpdating = maxSegUpdating + 1;
            seg = cell2mat( subSeg(1,s) );
            segNew(seg) = maxSegUpdating;
        end
    end

    
    % Recursion for each segment.
    for m = 0:maxSeg
        sSeg = numel(segNew(segNew==m));

        if sSeg > maxSize
           maxSize = sSeg;
           maxSizeSeg = m;
        end
    end
    
    if maxSize < 10
        return;
    end
%     % If all segments are small already, break.
%     if maxSize < 10
%         return;
%     end
    
    subMask = segNew;
    subMask(subMask ~= maxSizeSeg) = -1;
    subMask(subMask ~= -1) = 0;
    subMask = subMask + 1;
    
    % We can split again.
    [segNew, stop] = normCut(img,subMask,neighborhood,minval, segNew, numCuts);
    
    if stop
        % Check if anything changed.
        diff = sum(sum(sum( abs(currentSegmentation-segNew) )));
        if diff == 0
            return; 
        end
    end  
end

display('Khalas');
end

