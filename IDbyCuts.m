function [ IDs ] = IDbyCuts( masks )
%IDBYCUTS Generate IDs for recursive masks

IDs = masks(:,:,1);

% Binary masking
for m = 2:size(masks,3)
   IDs = IDs + masks(:,:,m) * 2^(m-1); 
end

end

