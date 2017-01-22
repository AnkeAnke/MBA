function [ W ] = SetupNormCutMatrix( img, mask, neighborhood, minval)
%SETUPNORMCUTMATRIX Set up the Laplacian system matrix.
%   Minimal Normalized Cuts can be found as smallest
%   eigenvectors/eigenvalues
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

anisotrophyZ = 6;
% ======= Initialization ====== %

% Save sizes to variables.
sImg = size(img);
sX = sImg(1);
sY = sImg(2);
sZ = sImg(3);
sSqr = prod(sImg);


indexImg = reshape(1:sSqr, sX, sY, sZ);

% Minus middle, only compute half the entries (rest in transposed)
numN = ((2*neighborhood+1)^2 - 1)/2;

% Add third dimension.
zNeigh = ceil(neighborhood/anisotrophyZ);
numN = numN + (2*neighborhood+1)^2 * zNeigh;

% Save coordinates here.
neighs = zeros(numN, 3);
% ======= Build Connectivity Graph ====== %

% Slow but small: Get all indices of neighbors.
count = 1;
for x = -neighborhood:neighborhood
    for y = -neighborhood:neighborhood
        for z = -zNeigh:zNeigh
            if (z>0) ||((z==0) && ((x > 0) || (x == 0 && y > 0)))
               neighs(count,:) = [x y z]';
               count = count + 1;
            end
        end
    end
end 

display(['Computing distances for ' num2str(count) ' neighbors'])

% Diagonal: Connection to themselves.
selfDist = reshape(abs(img-minval), sSqr, 1);

% Here the graph will be stored. Upper bound on neighbors: numN.
W = sparse(1:sSqr, 1:sSqr, selfDist, sSqr, sSqr, sSqr * numN);
variance = var(img(mask > 0));

% Fill with submatrices and compute connectivity.
for neigh = 1:numN
    if mod(neigh,50) == 0
        display(['Computing neighbor ' num2str(neigh)])
    end
   coord = neighs(neigh,:);
   x = coord(1); y = coord(2); z = coord(3);
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
   W = W + sparse( ...
        so0(:), ...
        so1(:), ...
        conn(:), sSqr, sSqr);
    W = W + sparse( ...
        so1(:), ...
        so0(:), ...
        conn(:), sSqr, sSqr);
end
display('Graph setup complete.')
% ======= Solve Eigenvalue Problem ====== %

end

