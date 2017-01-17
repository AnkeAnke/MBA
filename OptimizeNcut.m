function [ threshold ] = OptimizeNcut( graph, eigs, numTests )
% OPTIMIZENCUT Find the splitting point in the eigenvector image.
%   Compute numTests NCUT values and choose the best among them.

    % Standard arg.
    if nargin < 3
            numTests = 20;
    end    
    
    % Eigenvector to vector
    eig = reshape(eigs, numel(eigs),1);

    maxAbs = max(max(eig),-min(eig));
    
    % Sample some positions around zero.
    tests = maxAbs * (rand(numTests, 1)*2 - 1);
    % ncuts = zeros(numTests,1);
    cut = inf;
    minIdx = 0;
    % normrnd(0,maxAbs / 2, numTests, 1);
    
    for t = 1:numTests
       mask = 1:numel(eig); %zeros(size(eig));
       
       % Positions that are smaller than the current test.
%        negMask = mask;
%        negMask(eig <= tests(t)) = 0;
%        mask(eig > tests(t)) = 0;
       
       graphCopy = graph;
       
       % Sum of all edges from points in A (or B) to any point.
       assocAV = sum(sum( graphCopy(:,eig >=tests(t)) ));
       assocBV = sum(sum( graphCopy(:,eig < tests(t)) ));
       
        % Find CUT <- sum of all edges from A to B.
        graphCopy(:,eig >= tests(t)) = [];
        graphCopy(eig < tests(t),:) = [];
        cutAB = sum(sum(graphCopy));
        
        % Definition of the NCUT <- cut cost normalized by total
        % connectivity of parts.
        ncut = cutAB/assocAV + cutAB/assocBV;
        
        % Select minimum NCUT.
        if ncut < cut
            cut = ncut;
            minIdx = t;
            
            
        end     
    end
    
    if minIdx < 1
        display('something went wrong here');
    end
    % Take threshold that lead to minimal NCUT value.
    threshold = tests(minIdx);
end

