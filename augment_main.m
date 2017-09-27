%% augment_main
%-------------------------------------------------
% Main script to apply augmentation on exported short-axis images of the 
% left ventricle. [.mat] files can be loaded and will save the files as png images into a folder
% chosen below.
%
% The augmentations are:
% Rotation - To be implemented
% Translation - TBI
% Scaling - TBI
% Elastic deformation - TBI
%
% written by Mattis Nilsson, 2017

%% Initialize
% Create X x Y x N matrixes of images and masks, these should probably be
% entered into the function as input instead, but for now we do it like
% this.
% load lv_contours.mat
[fileName, pathName] = uigetfile('*.mat','Choose .mat file with images to augment');
loadPath = [pathName linesep fileName];
load loadPath;

if ~exist('Outdata','var')
    warning('.mat file did not contain proper data');
    
end
% IM = cat(3,Outdata.SYSIM, Outdata.DIAIM);
% MASK = cat(3,Outdata.SYSMASK, Outdata.DIAMASK);
% N = size(IM,3); % Number of images.

%% Extract center points
centroids = zeros(N,2);

for loop = 1:N
    mask = MASK(:,:,loop);
    imsize = size(mask,1);
    imagesc(mask)
    drawnow;
    pause;
    %props = regionprops(mask,'Centroid');
end
%% Checking augmentations

A = outdata.systolicIm(:,:,12);
figure(1)
imagesc(A)
B = imrotate(A,5);
figure(2)
imagesc(B)

x = 10; y = 20;
B = imtranslate(A, [x y]);
figure(3)
imagesc(B)

% One could perform edge detection on the mask to get a contour, thus
% allowing one to draw the contour on the images as well.

%% Show images
figure(1)
for loop = 1:N
    imagesc(IM)
    drawnow;
    pause(0.2)
end

%% Show images with segmentation
figure(2)

for loop = 1:N
    im = IM(:,:,loop);
    mask = MASK(:,:,loop);
    imsize = size(im,1);
    
    props = regionprops(mask,'Centroid');
    % GÖR DET MED INSIDAN AV KONTUREN ISTÄLLET!!!
    im = insertMarker(im,props.Centroid,'o','color','red','size',1);
    imagesc(im);
    colour = cat(3, ones(imsize), ...
        ones(imsize), ones(imsize));
    h = imagesc(colour);
    hold on
    set(h, 'AlphaData', mask.*0.5);
    drawnow;
    pause;
end

%% Systolic augmentation loop
for loop = 1:size(outdata.SYSIM,3)
    outdata.systolicIm(:,:,loop);
end

%% Diastolic augmentation loop
for loop = 1:size(outdata.DIAIM,3)
    
end

%%
save('LV_images_with_contours_augmented.mat','output');