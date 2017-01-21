function [ masks ] = ComputeAllMasksSimple( dcmImgsT1, resultMask)
%COMPUTEALLMASKS Summary of this function goes here
%   Detailed explanation goes here
    masks=zeros(size(dcmImgsT1));

    for i=1:size(masks,3)
        masks(:,:,i)=resultMask;
    end
end

