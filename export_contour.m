% 
%Export contour. Ask what contour to take.
global SET NO DATA

[x,y,name] = segment('askcontour','Choose which contour to export.');
      
% if isempty(x)
%   myfailed('User aborted or no contour available.',DATA.GUI.Segment);
%   return;
% end;

%Find slices with contour
totinslice = size(x,1)*size(x,2);
slices = find(squeeze(sum(sum(isnan(x),1),2))~=totinslice); % GÖTT

%l1 <filename>: <contour>  <resolutionx> <resolutiony>
%l2 filename contourname xres yres
%l3 empty line
%l4 <slice> <xtf1> <ytf1> <xtf2> <ytf3>
%l5 
outdata = cell(5+length(slices)*size(x,1),1+2*size(x,2));

%write header
outdata{1,1} = 'Filename:';
outdata{2,1} = SET(NO).FileName;
outdata{1,2} = 'Contour:';
outdata{2,2} = name;
outdata{1,3} = 'ResolutionX';
outdata{2,3} = SET(NO).ResolutionX;
outdata{1,4} = 'ResolutionY';
outdata{2,4} = SET(NO).ResolutionY;

outdata{4,1} = 'Slice';
for tloop=1:size(x,2)
  outdata{4,2+2*(tloop-1)} = sprintf('X_tf%02d',tloop);
  outdata{4,3+2*(tloop-1)} = sprintf('Y_tf%02d',tloop);  
end;
for zloop=1:length(slices)
  %write slice number
  for nloop=1:size(x,1)
    outdata{4+(zloop-1)*size(x,1)+nloop,1} = slices(zloop);
  end;
  for tloop=1:size(x,2)
    for nloop=1:size(x,1)
      outdata{4+(zloop-1)*size(x,1)+nloop,2+2*(tloop-1)} = SET(NO).ResolutionX*x(nloop,tloop,slices(zloop));
      outdata{4+(zloop-1)*size(x,1)+nloop,3+2*(tloop-1)} = SET(NO).ResolutionY*y(nloop,tloop,slices(zloop));      
    end;
  end;
end;

segment('cell2clipboard',outdata);