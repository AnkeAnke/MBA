function [ masks ] = ComputeAllMasksV3( dcmImgsT1, dcmImgsT2, resultMask, index)
%COMPUTEALLMASKS Summary of this function goes here
%   Detailed explanation goes here
    masks=[];

    masks(:,:,index)=resultMask;

    containsVertebra=true;
    for i=index+1:size(dcmImgsT1,3)
        i
        if containsVertebra
            mask=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), resultMask );
            containsVertebra = CheckMaskForVertebra( resultMask, mask );
            masks(:,:,i)=mask.*resultMask;
        end
        if ~containsVertebra
            masks(:,:,i)=zeros(size(dcmImgsT1,1),size(dcmImgsT1,2));
        end
    end
    containsVertebra=true;
    for i=index-1:-1:1
        i
        if containsVertebra
            mask=VertebraSegmentationT1T2V2( uint16(dcmImgsT1(:,:,i)), uint16(dcmImgsT2(:,:,i)), resultMask );
            containsVertebra = CheckMaskForVertebra( resultMask, mask );
            masks(:,:,i)=mask.*resultMask;
        end
        if ~containsVertebra
            masks(:,:,i)=zeros(size(dcmImgsT1,1),size(dcmImgsT1,2));
        end
    end

end

