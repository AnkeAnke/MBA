function [mask] = NormCutSegmentation( img, mask, neighborhood, minval )
%NORMCUTSEGMENTATION Segment the image recursively
%   Split the image in half using normalized cuts. Reinitialize the 

figure;
subplot(1,2,1); imshowMasked(img, mask);

% Reduce the image to the minimal axis-parallel box around the mask.
[minBox maxBox] = MaskBox(mask);
img  =  img(minBox(1):maxBox(1), minBox(2):maxBox(2));
mask = mask(minBox(1):maxBox(1), minBox(2):maxBox(2));

subplot(1,2,2); imshowMasked(img, mask);
original = img;

% Setup a new figure
figure;
sEigs = 4;
h = sEigs/2 + 1;

% Show initial image
subplot(2,h,1); imshow(img, [min(min(img)) max(max(img))]);
colormap(gray);
freezeColors;

% ======= Display cut eigenvectors ======= %
% Cut out one eigenvector.



currentSegmentation = zeros(size(img));
currentMask = mask;
% % Save cut values here.
% cuts = zeros(sEigs,1);
for v = 1:sEigs
%     
%     evec = eigVec(:,v);
% 
%     % Compute maximal absolute value for colormapping.
%     eMax = max( max(evec), -min(evec) );
%     
%     % Refill to full image.
%     fullImg = mask;
%     fullImg(mask>0) = evec;
%     fullImg(mask<=0) = -10;
%     
    % Plot. Map image to range [-1,1]
%     subplot(2,h,sEigs+1-v);
%     imshow(fullImg/eMax, [-1,1]);
%     title(['Eigenvalue' num2str(eigVal(v,v))]);
%     
%     % Compute the optimal cut value and build a colormap from it.
%     cuts(v) = OptimizeNcut(graph, evec);
%     colormap(HalfColormap(cuts(v))); %RefineCut(eVec4)));
    subplot(2,h,sEigs+1-v);    
    [maskNew,segmentationNew] = normCut(img, currentMask, neighborhood, minval, currentSegmentation); 
    imshowSegments(img, segmentationNew);
    
    % Update these variables.
    currentSegmentation = segmentationNew;
    currentMask = maskNew;
    
    freezeColors;
end

% Split to segments.
% segs = zeros(size(eigVec(:,1)));

% Binary representation as ID. Map to color for viewing.
% for i = 1:sEigs
%     segs(eigVec(:,i) > cuts(i)) = segs(eigVec(:,i) > cuts(i)) + 2^(i-1);
% end
% 
% % Random color per ID.
% map = rand((2^sEigs)+2,3);
% map(1,:) = 0;
% 
% % Display segments.
% fullImg = mask;
% fullImg(mask > 0) = segs;
% 
% subplot(2,h,2*h); imshowSegments(original, fullImg); %imshow(fullImg, [0,size(map,1)]);
% title('Segments');
% figure;
% subplot(2,h,2*h); imshow(fullImg, [0,size(map,1)]);
% colormap(map);
% freezeColors;
% 
% end


end

