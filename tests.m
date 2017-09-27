%% Initialize
% Create X x Y x N matrixes of images and masks, these should probably be
% entered into the function as input instead, but for now we do it like
% this.
load lv_contours.mat
IM = cat(3,Outdata.SYSIM, Outdata.DIAIM);
MASK = cat(3,Outdata.SYSMASK, Outdata.DIAMASK);
N = size(IM,3); % Number of images.

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

%% imgpolarcoord

mask = MASK(:,:,3);
im = double(IM(:,:,13));
props = regionprops(mask,'Centroid');
figure;
imShow = insertMarker(im,props.Centroid,'o','color','red','size',1);

pcimg = remapImageToPolarCoordinates(im, props.Centroid, 128, 128);

%%
figure;
subplot(2,2,1); imagesc(imShow);
colormap gray; axis image; title('Input image');
subplot(2,2,2); imagesc(pcimg);
colormap gray; axis image; title('Polar Input image');

%% PolarToIm

im = IM(:,:,2);
% im = double(im)/255.0;
figure(1); imagesc(im);
colormap gray; axis image; title('Input image');

imP = ImToPolar(im, 0, 1, 50, 200);
figure(2); imagesc(imP);
colormap gray; axis image; title('Polar mapped image');

imR = PolarToIm(imP, 0.6, 1, 250, 250);
figure(3); imshow(imR);
colormap gray; axis image; title('Reconstructed image');
