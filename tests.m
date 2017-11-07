%% Test image polar remapping
clear all
close all
load lv_contours.mat
endoColor = 'r-';
epiColor = 'g-';

for nPat = 1 %:length(outdata)
    
    IM = outdata(nPat).DiaIm;
    for nIm = 1:size(IM,3)
        [centerX, centerY] = findLVCenter(outdata(nPat).DiaEpi(:,:,nIm));
        
        %         h1 = figure(10);
        figure;
        drawLV(IM(:,:,nIm), ...
            outdata(nPat).DiaEndo(:,:,nIm), ...
            outdata(nPat).DiaEpi(:,:,nIm), ...
            ['Diastolic LV for patient ' num2str(nPat) ', slice ' num2str(nIm)]);
        %         movegui(h1,'northwest');
        
        [polarIm, polarContour] = remapToPolarCoordinates(IM(:,:,nIm), ...
            outdata(nPat).DiaEndo(:,:,nIm), outdata(nPat).DiaEpi(:,:,nIm), ...
            centerX, centerY);
        
        figure;
        %         h2 = figure(11);
        imagesc(polarIm); hold on;
        colormap gray; axis image; title('Polar image with segmentation');
        colorbar; caxis([0 0.6]);
        plot(1:size(polarIm,2), polarContour(:,1), endoColor);
        plot(1:size(polarIm,2), polarContour(:,2), epiColor);
        title(['Polar diastolic LV for patient ' num2str(nPat) ', slice ' num2str(nIm)]);
        %         movegui(h2,'southwest');
        drawnow;
        %         disp('waiting');
        %         pause;
    end
    %     close(h1);
    %     close(h2);
    
    IM = outdata(nPat).SysIm;
    for nIm = 1 %:length(outdata)
        [centerX, centerY] = findLVCenter(outdata(nPat).DiaEpi(:,:,nIm));
        %         h3 = figure(12);
        figure;
        drawLV(outdata(nPat).SysIm(:,:,nIm), ...
            outdata(nPat).SysEndo(:,:,nIm), ...
            outdata(nPat).SysEpi(:,:,nIm), ...
            ['Systolic LV for patient ' num2str(nPat) ', slice' num2str(nIm)]);
        %         movegui(h3, 'northeast');
        
        %         h4 = figure(13);
        figure;
        imagesc(polarIm); hold on;
        colormap gray; axis image; title('Polar image with segmentation');
        colorbar; caxis([0 0.6]);
        % Draw contour.
        plot(1:size(polarIm,2), polarContour(:,1), endoColor);
        plot(1:size(polarIm,2), polarContour(:,2), epiColor);
        title(['Polar systolic LV for patient ' num2str(nPat) ', slice ' num2str(nIm)]);
        %         movegui(h4,'southeast');
        drawnow;
        %         disp('waiting');
        %         pause;
    end
    %     close(h3);
    %     close(h4);
end