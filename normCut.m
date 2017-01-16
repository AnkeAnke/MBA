function [eVec1, eVec2, eVec3] = normCut( img, neighborhood )

% Save sizes to variables.
sImg = size(img);
sX = sImg(1);
sY = sImg(2);
sSqr = sImg(1) * sImg(2);

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
selfDist = reshape(img.*img, sSqr, 1);

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

figure, spy(graph)

% Sum up connection.
Dvec = sum(graph);
D = diag(Dvec);
figure, imshow(reshape(full(Dvec)/max(Dvec), sX,sY));
[eigVec,eigVal] = eigs(D-graph,D,5,'sm');
% [eigVec,eigVal] = eig(D-graph,D,'qz');

display('Minimal Eigenvalues');

eVec1  = reshape(eigVec(:,1), sX, sY);

eVec2  = reshape(eigVec(:,2), sX, sY);

eVec3  = reshape(eigVec(:,3), sX, sY);

eVec4  = reshape(eigVec(:,4), sX, sY);

eVec5  = reshape(eigVec(:,5), sX, sY);

% ========= Display =========

display(eigVal);




figure
subplot(2,3,1); imshow(img);
colormap(gray);
freezeColors;

eMax = max( max(max(eVec5)), -min(min(eVec5)) );
eVec5 = eVec5 / eMax;
subplot(2,3,2); imshow(eVec5, [-1,1]);
title(['Eigenvector 1: ' num2str(eigVal(5,5))]);


eMax = max( max(max(eVec4)), -min(min(eVec4)) );
eVec4 = eVec4 / eMax;
subplot(2,3,3); imshow(eVec4, [-1,1]);
title(['Eigenvector 2: ' num2str(eigVal(4,4))]);
colormap(HalfColormap(RefineCut(eVec4)));
colorbar;
freezeColors;

eMax = max( max(max(eVec3)), -min(min(eVec3)) );
eVec3 = eVec3 / eMax;
subplot(2,3,4); imshow(eVec3, [-1,1]);
title(['Eigenvector 3: ' num2str(eigVal(3,3))]);
colormap(HalfColormap(RefineCut(eVec3)));
colorbar;
freezeColors;

eMax = max( max(max(eVec2)), -min(min(eVec2)) );
eVec2 = eVec2 / eMax;
subplot(2,3,5); imshow(eVec2, [-1,1]);
title(['Eigenvector 4: ' num2str(eigVal(2,2))]);
colormap(HalfColormap(RefineCut(eVec2)));
colorbar;
freezeColors;

eMax = max( max(max(eVec1)), -min(min(eVec1)) );
eVec1 = eVec1 / eMax;
subplot(2,3,6); imshow(eVec1, [-1,1]);
title(['Eigenvector 5: ' num2str(eigVal(1,1))]);
colormap(HalfColormap(RefineCut(eVec1)));
colorbar;
freezeColors;

end

