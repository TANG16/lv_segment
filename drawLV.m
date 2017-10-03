function h = drawLV(im, endoContour, epiContour, plotTitle)

endocolor = 'r-';
epicolor = 'g-';
[centerX, centerY] = findLVCenter(endoContour(:,:));

h = figure(10);
imagesc(im); colormap gray; axis image; colorbar; caxis([0 0.6]);
hold on
plot(endoContour(:,2), ...
    endoContour(:,1), endocolor);
plot(epiContour(:,2), ...
    epiContour(:,1), epicolor);
plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
title(plotTitle);
drawnow;
end