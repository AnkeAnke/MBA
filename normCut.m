function [eVec1, eVec2, eVec3] = normCut( img, neighborhood )

% Save sizes to variables.
sImg = size(img);
xS = sImg(1);
yS = sImg(2);
sSqr = sImg(1) * sImg(2);
imshow(img)

% Initialize graph for graph cut.
graph= zeros(xS, yS, xS, yS);
Dvec = zeros(sSqr);

% Neighbor differences in X and Y direction
xMax = ones(xS-1, yS);
xDiff = img(1:xS-1, :) - img(2:xS, :);
xDiff = xMax - abs(xDiff);
yDiff = img(:, 1:yS-1) - img(:, 2:yS);
yDiff = xMax' - abs(yDiff);

figure, imshow(xDiff, [0,1]);
figure, imshow(yDiff, [0,1]);

 for x=1:xS
     for y=1:xS
         % Position in the connection graph
         iLoc = x+y*xS;
         
         % Left
         graph(x,y, max(1,x-1),y) = xDiff(max(1,x-1),y);
         % Up
         graph(x,y, x,max(1,y-1)) = yDiff(x,max(1,y-1));
     end
 end
 
graph = reshape(graph, sSqr, sSqr);
graph = graph + graph';

Dvec = sum(graph);
D = diag(Dvec);
% for x=2:sSqr-1
%     for y=2:sSqr-1
%         
%         gLoc = img(x, y);
%         pLoc = x + y*sSqr;
%         for neigh=1:numNeigh
%             pNeigh = [x y] + neighbors(neigh);
%             gNeigh = img( pNeigh(1), pNeigh(2) );
%             weight = (gLoc - gNeigh);
%             weight = 255*255 - weight * weight;
%             graph(pNeigh(1) + sSqr*pNeigh(2), pLoc) = weight;
%         end
%     end
% end

figure, imshow(graph, [0,1]);
% For LU:  + 10*eps*speye() ?

[eigVec,eigVal] = eigs(D-graph,D,5,'sm');
% [eigVec,eigVal] = eig(D-graph,D,'qz');

display('Minimal Eigenvalues');

eVec1  = reshape(eigVec(:,1), xS, yS);

eVec2  = reshape(eigVec(:,2), xS, yS);

eVec3  = reshape(eigVec(:,3), xS, yS);

eVec4  = reshape(eigVec(:,4), xS, yS);

eVec5  = reshape(eigVec(:,5), xS, yS);

display(eigVal);

% Display
eMax = max( max(max(eVec1)), -min(min(eVec1)) );
eVec1 = eVec1 / eMax;
display(eigVal(1,1));
figure, imshow(eVec1, [-1,1]);
title('Eigenvalue 1');

eMax = max( max(max(eVec2)), -min(min(eVec2)) );
eVec2 = eVec2 / eMax;
display(eigVal(2,2));
figure, imshow(eVec2, [-1,1]);
title('Eigenvalue 2');

eMax = max( max(max(eVec3)), -min(min(eVec3)) );
eVec3 = eVec3 / eMax;
display(eigVal(3,3));
figure, imshow(eVec3, [-1,1]);
title('Eigenvalue 3');

eMax = max( max(max(eVec4)), -min(min(eVec4)) );
eVec4 = eVec4 / eMax;
display(eigVal(4,4));
figure, imshow(eVec4, [-1,1]);
title('Eigenvalue 4');

eMax = max( max(max(eVec5)), -min(min(eVec5)) );
eVec5 = eVec5 / eMax;
display(eigVal(5,5));
figure, imshow(eVec5, [-1,1]);
title('Eigenvalue 5');

end

