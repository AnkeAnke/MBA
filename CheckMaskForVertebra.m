function containVertebra = CheckMaskForVertebra( initialMask, maskToCheck )
%CHECKMASKFORVERTEBRA Summary of this function goes here
%   Detailed explanation goes here

    containVertebra=true;
    %First criteria - Connected components
    CC = bwconncomp(maskToCheck);
    CC.NumObjects;
    
    if CC.NumObjects>1
        containVertebra = false;
        return;
    end
    
    %Second criteria - non zero elements
%     nnzInitMask = nonzeros(initialMask);
%     nnzMaskToCheck = nonzeros(maskToCheck);
%     
%     nnzDifference = abs(length(nnzInitMask)-length(nnzMaskToCheck))
%     
%     if nnzDifference > 500
%         containVertebra = false;
%     end
    
    %Third criteria
%     bbInitialMask = MaskBox(initialMask);
%     bbMaskToCheck = MaskBox(maskToCheck);
%     
%     if abs(bbInitialMask(1)-bbMaskToCheck(1)) > bbInitialMask(1)/100*7.5 % 10%
%         containVertebra = false;
%         return;
%     end
%     if abs(bbInitialMask(2)-bbMaskToCheck(2)) > bbInitialMask(2)/100*12.0 % 10%
%         containVertebra = false;
%         return;
%     end
    
    %Fourth criteria
    [m,n] = size(initialMask);
    
    indicesInitialMask=[];
    indicesMaskToCheck=[];
    
    countIndicesInitialMask=0;
    countIndicesMaskToCheck=0;
    
    for i=1:m
        for j=1:n
            if initialMask(i,j) ~= 0
                indicesInitialMask=[indicesInitialMask; i j];
                countIndicesInitialMask=countIndicesInitialMask+1;
            end
            if maskToCheck(i,j) ~= 0
                indicesMaskToCheck=[indicesMaskToCheck; i j];
                countIndicesMaskToCheck=countIndicesMaskToCheck+1;
            end
        end
    end
    sumInitMaskIndices=sum(indicesInitialMask);
    sumMaskToCheckIndices=sum(indicesMaskToCheck);
    centerInitMask=1/countIndicesInitialMask*sumInitMaskIndices;
    centerMaskToCheck=1/countIndicesMaskToCheck*sumMaskToCheckIndices;
    
    centerMaskDifference = abs(centerInitMask-centerMaskToCheck);
    norm(centerMaskDifference)
    if norm(centerMaskDifference) > 12.0
        containVertebra = false;
        return;
    end
end

