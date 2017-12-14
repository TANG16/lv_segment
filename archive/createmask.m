%---------------------------------------
function mask = createmask(outsize,y,x)
%---------------------------------------
%Function to generate a mask from a polygon represented with the vectors x
%and y. 
global DATA 

%Check if NaN then return empty
if any(isnan(x)) || any(isnan(y))
  mask = false(outsize);  
  return;
end;

if not(DATA.Pref.IncludeAllPixelsInRoi)
  %mask = roipoly(repmat(uint8(0),outsize),y,x);  
  mask = poly2mask(y,x,outsize(1),outsize(2));
else
  mask = false(outsize);  
  mx = round(mean(x));
  my = round(mean(y));
  x = interp1(x,linspace(1,length(x),1000));
  y = interp1(y,linspace(1,length(y),1000));
  mask(sub2ind(outsize,round(x),round(y))) = true;
  mask = imfill(mask,[mx my],4);
end;