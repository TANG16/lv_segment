%% Draw images with segmentation and centerpoint.
load lv_contours.mat
endocolor = 'r-';
epicolor = 'g-';

for nPat = 4:length(outdata)
    IM = outdata(nPat).DiaIm;
    for nIm = 1:size(IM,3)
        h = drawLV(IM(:,:,nIm), ...
            outdata(nPat).DiaEndo(:,:,nIm), ...
            outdata(nPat).DiaEpi(:,:,nIm), ...
            ['Diastolic LV for patient ' num2str(nPat) ', slice ' num2str(nIm)]);
        pause;
    end
    close(h);
    
    IM = outdata(nPat).SysIm;
    for nIm = 1:size(IM,3)
        h = drawLV(outdata(nPat).SysIm(:,:,nIm), ...
            outdata(nPat).SysEndo(:,:,nIm), ...
            outdata(nPat).SysEpi(:,:,nIm), ...
            ['Systolic LV for patient ' num2str(nPat) ', slice' num2str(nIm)]);
        pause;
    end
    close(h);
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