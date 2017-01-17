function [eVec1, eVec2, eVec3] = normCut( img, mask, neighborhood, minval )

img(mask <= 0) = nan;

% Save sizes to variables.
sImg = size(img);
sX = sImg(1);
sY = sImg(2);
sSqr = sImg(1) * sImg(2);

% Number of elements in mask.
sMask = sum(sum(mask > 0));
mask = double(mask);
mask(mask>0) = 1:sMask;

indexImg = reshape(1:sSqr, sX, sY);

% Minus middle, only compute half the entries (rest in transposed)
numN = ((2*neighborhood+1) * (2*neighborhood+1) - 1)/2;
nX = zeros(numN,1);
nY = zeros(numN,1);

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
   conn = 1.0 - sqrt(sqrt(sqrt(sqrt(abs(conn)))));
   conn = conn / sqrt(x*x + y*y);
  
    % All x/y combinations.
    so0 = indexImg(s0x, s0y);
    so1 = indexImg(s1x, s1y);

   % Add to graph.
   graph = graph + sparse( ...
        [so0], ...
        [so1], ...
        [conn], sSqr, sSqr);
    graph = graph + sparse( ...
        [so1], ...
        [so0], ...
        [conn], sSqr, sSqr);
end

graph( ~any(graph,2), : ) = [];  %rows
graph( :, ~any(graph,1) ) = [];  %columns

figure, spy(graph)

% Sum up connection.
Dvec = sum(graph);
D = diag(Dvec);
Dimg = mask;
Dimg(mask>0) = full(Dvec) / max(Dvec);
figure, imshow(Dimg);

% Solve eigenvalue problem.
% Probably the most expensive line in this script.
sEigs = 9;
[eigVec,eigVal] = eigs(D-graph,D,sEigs,'sm');

display('Minimal Eigenvalues');

% Map to range [-1,1]
eigVec = eigVec * diag(1./sum(eigVec,1))';

% ======= Display original image ======= %
display(eigVal);

% Height of subplot
h = (sEigs+1)/2;

figure
subplot(2,h,1); imshow(img);
colormap(gray);
freezeColors;

% eMax = max( max(eigVec(:,sEigs), -min(eigVec(:,sEigs))) );
% subplot(2,3,2); imshow(eigVec(:,sEigs), [-1,1]);
% title(['Eigenvector 1: ' num2str(eigVal(5,5))]);



% ======= Display cut eigenvectors ======= %
% Cut out each eigenvector by mask.

% Save cut values here.
cuts = zeros(sEigs,1);
for v = 1:(sEigs-1)
    
    evec = eigVec(:,v);

    % Compute maximal absolute value for colormapping.
    eMax = max( max(evec), -min(evec) );
    
    % Refill to full image.
    fullImg = mask;
    fullImg(mask>0) = evec;
    fullImg(mask<=0) = -10;
    
    % Plot. Map image to range [-1,1]
    subplot(2,h,sEigs+1-v); imshow(fullImg/eMax, [-1,1]);
    title(['Eigenvalue' num2str(eigVal(v,v))]);
    
    % Compute the optimal cut value and build a colormap from it.
    cuts(v) = OptimizeNcut(graph, evec);
    colormap(HalfColormap(cuts(v))); %RefineCut(eVec4)));
    %colorbar;
    freezeColors;
end

% Split to segments.
segs = zeros(size(eigVec(:,1)));

% Binary representation as ID. Map to color for viewing.
for i = 1:(sEigs-1)
    segs(eigVec(:,i) > cuts(i)) = segs(eigVec(:,i) > cuts(i)) + 2^i;
end

% Random color per ID.
map = rand((2^sEigs)+2,3);
map(1,:) = 0;

% Display segments.
fullImg = mask;
fullImg(mask > 0) = segs;
subplot(2,h,2*h); imshow(fullImg, [0,size(map,1)]);
title('Segments');

colormap(map);
%colorbar;
freezeColors;

end

