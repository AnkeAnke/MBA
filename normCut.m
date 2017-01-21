function [segmentation,stop] = ...
normCut( img, mask, neighborhood, minval, currentSegmentation, viewSlice, numCuts)

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
if nargin < 6
   output = false;
end

% If no cut number is given, take 2 for now (-> 4 segments each step)
if nargin < 7
   numCuts = 2;
end

anisotrophyZ = 6;
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
sZ = sImg(2);
sSqr = prod(sImg);

mask = double(mask);

indexImg = reshape(1:sSqr, sX, sY, sZ);

% Minus middle, only compute half the entries (rest in transposed)
numN = ((2*neighborhood+1)^2 - 1)/2;

% Add third dimension.
zNeigh = ceil(neighbor/anisotrophyZ);
numN = numN + (2*neighborhood+1)^2 * zNeigh;

% Save coordinates here.
neighs = zeros(numN, 3);
% ======= Build Connectivity Graph ====== %

% Slow but small: Get all indices of neighbors.
count = 1;
for x = -neighborhood:neighborhood
    for y = -neighborhood:neighborhood
        for z = -zNeigh:zNeigh
            if (z>0) ||(z==0) && ...
                      ((x > 0) || (x == 0 && y > 0))
               neighs(count) = [x y z]';
               count = count + 1;
            end
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
   [x,y,z] = neighs(neigh);
   
   % When we have negative offsets, the direction needs to change.
   if y>=0
       s0y = 1:sY-y;
       s1y = y+1:sY;
   else
       s0y = 1-y:sY;
       s1y = 1:sY+y;
   end
   % Same for x (in neighboring z slices).
   if x>=0
       s0x = 1:sX-x;
       s1x = x+1:sX;
   else
       s0x = 1-x:sX;
       s1x = 1:sX+x;
   end
   
   % z is always positive or zero.
   s0z = 1:sZ-z;
   s1z = z+1:sZ;
   
   conn = (img(s0x,s0y,s0z) - img(s1x,s1y,s1z));
   % Shi & Malik paper
   conn = exp(-(conn .* conn)/variance);
   % Shi & Malik paper normalizes this by the size variance.
   % Anisotropic voxels: 6 times as large in z as in x or y.
   conn = conn / sqrt(x*x + y*y + (z*anisotrophyZ)^2);
  
    % All x/y combinations.
    so0 = indexImg(s0x, s0y, s0z);
    so1 = indexImg(s1x, s1y, s1z);

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
    sImg = [1 numCuts+2];
    if numCuts > 2
        sImg = [2 ceil((numCuts+2)/2)];
    end
    figure
    subplot(sImg(1), sImg(2) ,1);
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
    subplot(sImg(1), sImg(2) ,2); 
    imshowSegments(bigImg(:,:,viewSlice), currentSegmentation(:,:,viewSlice));
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
    cuts(v) = OptimizeNcut(graph, evec);
    
    
    % Update segmentation
    segmentation = segmentation *2;
    segmentation(fullImg > cuts(v)) = segmentation(fullImg > cuts(v)) + 1; % = maxID + v;

    % Intermediate segmentation result.
    if output
        % Plot input segmented image (color overlay)
        subplot(sImg(1), sImg(2) ,v+2);
        imshowSegments(bigImg(:,:,viewSlice), segmentation(:,:,viewSlice));
        title(['Cut ' num2str(v)]);
        freezeColors;
    end

end

end

