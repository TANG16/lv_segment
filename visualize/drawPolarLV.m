function drawPolarLV(im, endoContour, epiContour, plotTitle)
% Function to draw the LV in polar coordinates with the endo/epi-cardial
% contour.

% Define colours.
endoColor = 'r-';
epiColor = 'g-';

% Draw image.
imagesc(im); hold on;

% Define plot parameters.
colormap gray; axis image; title(plotTitle)
colorbar; caxis([0 0.6]);

% Draw LV Contours.
plot(1:size(im,2), endoContour, endoColor);
plot(1:size(im,2), epiContour, epiColor);
drawnow;
pause;
end