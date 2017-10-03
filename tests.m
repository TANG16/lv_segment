%% Initialize
% Create X x Y x N matrixes of images and masks, these should probably be
% entered into the function as input instead, but for now we do it like
% this.
load lv_contours.mat
IM = cat(3,Outdata.SYSIM, Outdata.DIAIM);
MASK = cat(3,Outdata.SYSMASK, Outdata.DIAMASK);
N = size(IM,3); % Number of images.

%% Show images with segmentation
figure(2)

for loop = 1:N
    im = IM(:,:,loop);
    mask = MASK(:,:,loop);
    imsize = size(im,1);
    
    props = regionprops(mask,'Centroid');
    centerX = props.Centroid(1);
    centerY = props.Centroid(2); 
    
    imagesc(im); colormap gray; axis image; colorbar; caxis([0 0.6]);
    hold on
    colour = cat(3, ones(imsize), ...
        ones(imsize), ones(imsize));
    h = imagesc(colour);
    set(h, 'AlphaData', mask.*0.5);
    plot(centerX, centerY, 'Marker', '*', 'Color', [1 0 0], 'MarkerSize', 10);
    drawnow;
    pause;
end

%% Test image polar remapping

imNo = 25;
load lv_contours.mat
IM = cat(3,Outdata.SYSIM, Outdata.DIAIM);
MASK = cat(3,Outdata.SYSMASK, Outdata.DIAMASK);
im = IM(:,:,imNo);
mask = MASK(:,:,imNo);

props = regionprops(mask,'Centroid');
centerX = props.Centroid(1);
centerY = props.Centroid(2);    
nAngle = 96;
nRadius = 56;

polarIm = imToPolarCoordinates(im, [centerX, centerY], nRadius, nAngle);
interpolationMode = cell(1,3);
interpolationMode{1,1} = 'nearest';
interpolationMode{1,2} = 'bilinear'; 
interpolationMode{1,3} = 'bicubic';
for i = 1:3
    
    polarIm = imToPolarCoordinates(im, [centerX, centerY], nRadius, nAngle,...
        interpolationMode{i});
    figure;
    suptitle(['Polar remapping using ' interpolationMode{i} ' interpolation']);
    subplot(2,1,1); imagesc(im); colormap gray; axis image;
    hold on
    plot(centerX, centerY, 'Marker', '*', 'Color', [1 0 0], 'MarkerSize', 12);
    hold off
    title('Input image');
    subplot(2,1,2); imagesc(polarIm); colormap gray; axis image;
    title('Polar Input image'); colorbar; caxis([0 0.6]);
end