function [ masks ] = ComputeAllMasks( dcmImgsT1, dcmImgsT2, resultMask, index)
%COMPUTEALLMASKS Summary of this function goes here
%   Detailed explanation goes here
    masks=[];

    masks(:,:,index)=resultMask;

    for i=index+1:size(dcmImgsT1,3)
        i
        masks(:,:,i)=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), masks(:,:,i-1) );
    end

    for i=index-1:-1:1
        i
        masks(:,:,i)=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), masks(:,:,i+1) );
    end

end

