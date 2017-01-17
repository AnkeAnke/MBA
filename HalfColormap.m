% Colormap that is cut at the given value:
% All values higher than val are colored slightly red.
function [ map ] = HalfColormap( val )
cut = (val+1)/2;
map = [linspace(0,cut,200*cut)' linspace(0,cut,200*cut)' linspace(0,cut,200*cut)'
       linspace(cut*1.15,1,200*(1.0-cut))' linspace(cut*0.9,1,200*(1.0-cut))' linspace(cut*0.9,1,200*(1.0-cut))'];
end

