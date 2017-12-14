function drawLV(im, endoContour, epiContour, centerX, centerY, plotTitle)

endoColor = 'r-';
epiColor = 'g-';

imagesc(im); colormap gray; axis image; colorbar; caxis([0 0.6]);
hold on
plot(endoContour(:,2), ...
    endoContour(:,1), endoColor);
plot(epiContour(:,2), ...
    epiContour(:,1), epiColor);
plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
title(plotTitle);
drawnow;
end