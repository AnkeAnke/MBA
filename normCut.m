function [segmentation,stop, Wfull] = ...
normCut( img, mask, neighborhood, minval, currentSegmentation, viewSlice, numCuts, W)

% ======= Standard Parameters ====== %
% Set masked-out ares to nan.
% This will invalidate all edges to and from this area.
img(mask <= 0) = nan;
output = true;
% If no neighborhood value is given, take a small one.
if nargin < 3
   neighborhood = 5;
end

% If no indicator value is given, take a standard value.
if nargin < 4
   minval = 0; 
end

% If no segmentation is given, set all to ID 0
if nargin < 5
   currentSegmentation = zeros(size(mask));
end

% If no viewing slice is specified, don't print debug output.
if nargin < 6 || viewSlice <= 0
   output = false;
end

% If no cut number is given, take 2 for now (-> 4 segments each step)
if nargin < 7
   numCuts = 2;
end

% ======= Initialization ====== %

segmentation = currentSegmentation;
stop = false;

bigImg = img;
maskNew = mask;
% segNew = currentSegmentation;
% Reduce the image to the minimal axis-parallel box around the mask.
[minBox,maxBox] = MaskBox(mask);
img  =  img(minBox(1):maxBox(1), minBox(2):maxBox(2), minBox(3):maxBox(3));
mask = mask(minBox(1):maxBox(1), minBox(2):maxBox(2), minBox(3):maxBox(3));

mask = double(mask);

if nargin < 8
    [W] = SetupNormCutMatrix(img, mask, neighborhood,minval);
    Wfull = W;
    % No need to drop any rows - they will all be empty anyways.
else
    % Cut all afterwards - this way, it does not matter what mask was used
    % to create the matrices.
    Wfull = W;
    W(maskNew(:)<1, :) = [];
    W(:, maskNew(:)<1) = [];
end

% Shold be none, actually.
W( ~any(W,2), : ) = [];  %rows
W( :, ~any(W,1) ) = [];  %columns

% Get D from W -> sum up connection.
Dvec = sum(W);
D = diag(Dvec);


if output
    % Assume screen ratio is about 3:2
    gridSize = floor(sqrt((numCuts + 2)/1.5));
    sImg = [gridSize, ceil((numCuts + 2)/gridSize)];
%     sImg = [1 numCuts+2];
%     if numCuts > 2
%         sImg = [2 ceil((numCuts+2)/2)];
%     end
    figure
    subplot(sImg(1), sImg(2) ,1);
    spy(W)
end


% Solve eigenvalue problem.
% Probably the most expensive line in this script.
[eigVec,eigVal] = eigs(D-W,D,numCuts+1,'sm');
display('Eigenvalue computation complete.')
% Check whether the matrix is nearly singular.
% [~, LASTID] = lastwarn;
% if strcmp(LASTID, 'MATLAB:nearlySingularMatrix')
%     stop = true;
%     return;
% end

display('Minimal eigenvalues:')

% Map to range [-1,1]
eigVec = eigVec * diag(1./sum(eigVec,1))';

% ======= Display original image ======= %
if output
    % Plot input segmented image (color overlay)
    subplot(sImg(1), sImg(2) ,2); 
    imshowSegments(bigImg, currentSegmentation, viewSlice);
    title('Input');
    freezeColors;
end

if output
    display(eigVal);
end

% ======= Display cut eigenvectors ======= %
% Cut out each eigenvector by mask.
% Save cut values here.
cuts = zeros(numCuts,1);
% subMask = mask - 1;
for v = 1:numCuts%numCuts+1:-1:2
    
    evec = eigVec(:,v);
    if ~CheckStability(evec)
        stop = true;
       break; 
    end
    
    % Refill to full image.
    fullImg = maskNew;
    fullImg(fullImg>0) = evec;
    fullImg(fullImg<=0) = -10;
    
    % Compute the optimal cut value and build a colormap from it.
    cuts(v) = OptimizeNcut(W, evec);
    
    
    % Update segmentation
    segmentation = segmentation *2;
    segmentation(fullImg > cuts(v)) = segmentation(fullImg > cuts(v)) + 1; % = maxID + v;

    % Intermediate segmentation result.
    if output
        % Plot input segmented image (color overlay)
        subplot(sImg(1), sImg(2) ,v+2);
        imshowSegments(bigImg, segmentation, viewSlice);
        title(['Cut ' num2str(v)]);
        freezeColors;
    end

end

% figureHandle = figure;
% set(figureHandle,'windowscrollWheelFcn', {@showImagesSegmented,segmentation,segmentImgSize,maxIndex});

end

