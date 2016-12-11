function [A] = Untitled( img )
     sImg = size(img);
%     chans = sImg(3);
%     A = img(:,:,1);
%     for c=2:chans
%        A = A + img(:,:,c); 
%     end
    % A = A/chans;
    A = double(img(:,:,1));
    reshape( A, sImg(1), sImg(2) );
    A = A/255.0;
end

