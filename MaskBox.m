function [ minBox maxBox ] = MaskBox( mask )
%MASKBOX Find minimal enclosing box around a masked area
%   Find axis-parallel borders in each dimension of the mask.
%   Returns a [dim x 1] vector of minima and maxima in each dimension.

% Initialize result
dims = ndims(mask);
minBox = zeros(dims,1);
maxBox = minBox;

sums = mask;

    % For each dimension: Get minimal and maximal index.
    for d = 1:dims
        positions = 1:size(mask,d);
        sums = mask;
        
        % Reduce dimension, starting from the end
        % (if not, indices would change)
        for dd = dims:-1:1
            if d == dd
                continue;
            end
            
            % Reduce along this dimension.
            sums = sum(sums,dd);
        end
        
        % Get all 'rows' where at least one value is positive.
        positions = positions(sums>0);
        minBox(d) = positions(1);
        maxBox(d) = positions(end);
    end

end

