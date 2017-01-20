function [segNew] = MinVarNormCut(img, mask, neighborhood, minval, currentSegmentation, numCuts )
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
    % Chose lowest variance within segment.
    maxVar = 0;
    maxVarSeg = -1;
    for m = 0:maxSegUpdating
        % Count sizes to break if the segment is small.
        if numel(segNew(segNew==m)) < 10
            continue;
        end
        
        sSeg = var(segNew(segNew==m));

        if sSeg > maxVar
           maxVar = sSeg;
           maxVarSeg = m;
        end
    end
    
    % If all segments are small already, break.
    if maxVar == 0
        return;
    end
    
    subMask = segNew;
    subMask(subMask ~= maxVarSeg) = -1;
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

