orignialim = imSet.IM(:,:,3);

endoColor = 'r-';
epiColor = 'g-';
figure;
imagesc(orignialim); colormap gray; axis image; colorbar;
hold on
plot(imSet.Endo(:,2,3), imSet.Endo(:,1,3), endoColor);
plot(imSet.Epi(:,2,3), imSet.Epi(:,1,3), epiColor);
% plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
drawnow;

%%
imSet = resampleImages(imSet, 1.5);
im = imSet.IM(:,:,3);

endoColor = 'r-';
epiColor = 'g-';
figure;
imagesc(im); colormap gray; axis image; colorbar;
hold on
plot(imSet.Endo(:,2,3), imSet.Endo(:,1,3), endoColor);
plot(imSet.Epi(:,2,3), imSet.Epi(:,1,3), epiColor);
% plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
drawnow;

%%
radius = 29;
centerX = round(imSet.Center(1,3));
centerY = round(imSet.Center(2,3));
iImage = 3;
im = imSet.IM(:,:,3);
im = imresize(im((centerX - radius):(centerX + radius), ...
    (centerY - radius):(centerY + radius)),[128 128]);

endoX = (imSet.Endo(:,1,iImage) - (centerX - radius))*128/(radius*2 + 1);
endoY = (imSet.Endo(:,2,iImage) - (centerY - radius))*128/(radius*2 + 1);
epiX = (imSet.Epi(:,1,iImage) - (centerX - radius))*128/(radius*2 + 1);
epiY = (imSet.Epi(:,2,iImage) - (centerY - radius))*128/(radius*2 + 1);
mask = im2uint8(poly2mask([endoY; epiY], [endoX; epiX], 128, 128));
%%
endoColor = 'r-';
epiColor = 'g-';
figure;
imagesc(im); colormap gray; axis image; colorbar;
hold on
plot(endoY, endoX, endoColor);
plot(epiY, epiX, epiColor);
plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
drawnow;


%%
figure;
imagesc(orignialim); colormap gray; axis image; colorbar;


%%
%-----------------------------------
function imSet = resampleImages(imSet, resolution)
%-----------------------------------
% Upsamples current image stack (in slice only). Takes care of
% segmentation in the upsampling process.

% Stolen and adapted from Segment (functions upsampleimage_Callback,
% upsamplevolume and resamplehelper).

f = imSet.ResolutionX/resolution; % Resample factor.

imSet.IM = upsamplevolume(f, imSet.IM);

% Resample contours.
imSet.Endo = resamplehelper(f,imSet.Endo);
imSet.Epi = resamplehelper(f,imSet.Epi);

% Resample renter.
imSet.Center = resamplehelper(f,imSet.Center);

% Resample resolution.
imSet.ResolutionX = imSet.ResolutionX/f;
imSet.ResolutionY = imSet.ResolutionY/f;
end

%-------------------------------
function x = resamplehelper(f,x)
%-------------------------------
%Helper function to resample image stacks.
%factor 2 => x' = 2*x-0.5
%factor 3 => x' = 3*x-1
%factor 4 => x' = 4*x-1.5
%factor 5 => x' = 5*x-2
%factor 2.5 => x' = 2.5*x-1
%factor 3.5 => x' = 3.5*x-1.5
%factor 0.5 => x' = x'*0.5 (a odd)
%factor 0.5 => x' = x'*0.5+0.5 (a even)

if f>0
    d = (ceil(f)-1)/2;
else
    d = 0;
end

if isa(x,'double')
    x = x*f-d;
else
    for xloop=1:size(x,1)
        for yloop=1:size(x,2)
            x{xloop,yloop} = x{xloop,yloop}*f-d;
        end
    end
end
end

%--------------------------------------
function newvol = upsamplevolume(f,vol)
%--------------------------------------
%Helper function to upsample a volume vol.

%Find new size
newsize = size(imresize(vol(:,:,1,1),f,'nearest'));

%Reserve memory
if isa(vol,'single')
    newvol = repmat(single(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
elseif isa(vol,'int16')
    newvol = repmat(int16(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
else
    newvol = zeros(newsize(1),newsize(2),size(vol,3),size(vol,4));
end

%Loop over image volume
for tloop=1:size(vol,3)
    for zloop=1:size(vol,4)
        if isa(vol,'single')
            newvol(:,:,tloop,zloop) = single(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        elseif isa(vol,'int16')
            newvol(:,:,tloop,zloop) = int16(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        else
            newvol(:,:,tloop,zloop) = imresize(vol(:,:,tloop,zloop),f,'bicubic');
        end
    end
end
end