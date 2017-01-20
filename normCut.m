function [segmentation,stop] = ...
normCut( img, mask, neighborhood, minval, currentSegmentation, numCuts, output)

% ======= Standard Parameters ====== %
% Set masked-out ares to nan.
% This will invalidate all edges to and from this area.
img(mask <= 0) = nan;

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

% If no cut number is given, take 2 for now (-> 4 segments each step)
if nargin < 6
   numCuts = 2;
end

% If nothing is specified, don't print debug output.
if nargin < 7
   output = true;
end

% ======= Initialization ====== %

segmentation = currentSegmentation;
stop = false;

bigImg = img;
maskNew = mask;
% segNew = currentSegmentation;
% Reduce the image to the minimal axis-parallel box around the mask.
[minBox,maxBox] = MaskBox(mask);
img  =  img(minBox(1):maxBox(1), minBox(2):maxBox(2));
mask = mask(minBox(1):maxBox(1), minBox(2):maxBox(2));

% Save sizes to variables.
sImg = size(img);
sX = sImg(1);
sY = sImg(2);
sSqr = sImg(1) * sImg(2);

% Number of elements in mask.
% sMask = sum(sum(mask > 0));
mask = double(mask);
% mask(mask>0) = 1:sMask;

indexImg = reshape(1:sSqr, sX, sY);

% Minus middle, only compute half the entries (rest in transposed)
numN = ((2*neighborhood+1) * (2*neighborhood+1) - 1)/2;
nX = zeros(numN,1);
nY = zeros(numN,1);

% ======= Build Connectivity Graph ====== %

% Slow but small: Get all indices of neighbors.
count = 1;
for x = -neighborhood:neighborhood
    for y = -neighborhood:neighborhood
        if (x > 0) || (x == 0 && y > 0)
           nX(count) = x;
           nY(count) = y;
           count = count + 1;
        end
    end
end 

% Diagonal: Connection to themselves.
selfDist = reshape(abs(img-minval), sSqr, 1);

% Here the graph will be stored. Upper bound on neighbors: numN.
graph = sparse(1:sSqr, 1:sSqr, selfDist, sSqr, sSqr, sSqr * numN);
variance = var(img(mask > 0));

% Fill with submatrices and compute connectivity.
for neigh = 1:numN
   x = nX(neigh);
   y = nY(neigh);
   
   if y>=0
       s0x = 1:sX-x;
       s0y = 1:sY-y;
       s1x = x+1:sX;
       s1y = y+1:sY;
   else
       s0x = 1:sX-x;
       s0y = 1-y:sY;
       s1x = x+1:sX;
       s1y = 1:sY+y;
   end
   
   conn = (img(s0x,s0y) - img(s1x,s1y));
   % Shi & Malik paper
   conn = exp((conn .* conn)/variance);
   % Shi & Malik paper uses differently
   conn = conn / sqrt(x*x + y*y);
  
    % All x/y combinations.
    so0 = indexImg(s0x, s0y);
    so1 = indexImg(s1x, s1y);

   % Add to graph.
   graph = graph + sparse( ...
        so0, ...
        so1, ...
        conn, sSqr, sSqr);
    graph = graph + sparse( ...
        so1, ...
        so0, ...
        conn, sSqr, sSqr);
end

% ======= Solve Eigenvalue Problem ====== %

graph( ~any(graph,2), : ) = [];  %rows
graph( :, ~any(graph,1) ) = [];  %columns

if output
    figure
    subplot(2,(numCuts+2)/2,1);
    spy(graph)
end

% Sum up connection.
Dvec = sum(graph);
D = diag(Dvec);
Dimg = mask;
Dimg(mask>0) = full(Dvec) / max(Dvec);
% figure, imshow(Dimg);

% Solve eigenvalue problem.
% Probably the most expensive line in this script.
[eigVec,eigVal] = eigs(D-graph,D,numCuts+1,'sm');

% Check whether the matrix is nearly singular.
% [~, LASTID] = lastwarn;
% if strcmp(LASTID, 'MATLAB:nearlySingularMatrix')
%     stop = true;
%     return;
% end

display('Minimal Eigenvalues');

% Map to range [-1,1]
eigVec = eigVec * diag(1./sum(eigVec,1))';

% ======= Display original image ======= %
if output
    % Plot input segmented image (color overlay)
    subplot(2,(numCuts+2)/2,2); 
    imshowSegments(bigImg, currentSegmentation);
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
for v = 1:numCuts
    
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
    cuts(v) = OptimizeNcut(graph, evec);
    
    % Update this sub-mask
%     subMask = subMask * 2;
%     subMask(fullImg > cuts(v)) = subMask(fullImg > cuts(v)) + 1;
    
    % Update segmentation
    segmentation = segmentation *2;
    segmentation(fullImg > cuts(v)) = segmentation(fullImg > cuts(v)) + 1; % = maxID + v;

    % Intermediate segmentation result.
    if output
        % Plot input segmented image (color overlay)
        subplot(2,(numCuts+2)/2,v+2); 
        imshowSegments(bigImg, segmentation);
        title(['Cut ' num2str(v)]);
        freezeColors;
    end

end

% % subMask(subMask<0) = -1;
% % maskNew = zeros(size(fullImg));
% % maskNew(minBox(1):maxBox(1), minBox(2):maxBox(2))
% segNew(maskNew>0) = segmentation(mask>0);



% segmentation(segmentation<0) = -1;

% % Split to segments.
% segs = zeros(size(eigVec(:,1)));
% 
% % Binary representation as ID. Map to color for viewing.
% for i = 1:sEigs
%     segs(eigVec(:,i) > cuts(i)) = segs(eigVec(:,i) > cuts(i)) + 2^(i-1);
% end

% Display segments.
% fullImg = mask;
% fullImg(mask > 0) = segs;

% Plot segmented image (color overlay)
% subplot(2,h,2*h); 
% imshowSegments(original, fullImg); %imshow(fullImg, [0,size(map,1)]);
% title('Segments');
% freezeColors;

end

