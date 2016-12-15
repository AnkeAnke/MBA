function [ cut ] = RefineCut( img, numRec )
    % Standard arg.
    if nargin < 2
            numRec = 10;
    end    

    cut = 0;
    lowerBound = -1;
    upperBound = 1;

    % Binary search.
    for rec=1:numRec
        i = numel(img);
        numPos = sum(sum(img > cut));
        numNeg = sum(sum(img < cut));

        if numPos == numNeg
            return;
        end
        % More positive values.
        if numPos > numNeg
            lowerBound = cut;
            cut = cut + (upperBound - cut)/2;
        else
            upperBound = cut;
            cut = lowerBound + (cut - lowerBound)/2;
        end

    end
end

