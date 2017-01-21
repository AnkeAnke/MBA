function thresheldImgs = ThresholdImages( imgs, threshold )
%THRESHHOLDIMAGES Summary of this function goes here
%   Detailed explanation goes here
%     thresheldImgs=zeros(size(imgs));
%     for i=1:size(imgs,3)
%         indicesToCut=find(imgs(:,:,i)>threshold);
%         tmpImgs = imgs(:,:,i);
%         tmpImgs(indicesToCut) = 0;
%         thresheldImgs(:,:,i) = tmpImgs;
%     end
thresheldImgs=imgs;
thresheldImgs(thresheldImgs>threshold) = threshold;

end

