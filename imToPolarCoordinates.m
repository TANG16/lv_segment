function polarIm = imToPolarCoordinates(im, centerPoint, nRadius, nAngle, ...
    interpolationMethod)
%IMTOPOLARCOORDINATES Summary of this function goes here
%   Detailed explanation goes here

[rows, cols] = size(im);

if exist('centerPoint','var') == 0
    centerX = round(rows/2);
    centerY = round(cols/2);
else
    centerX = centerPoint(1);
    centerY = centerPoint(2);
end % Extract centerpoint, set to middle of the image if input is missing.

if exist('nRadius','var') == 0
    nRadius = 56;
end % Sample the image to the edge from the centerpoint if input is missing.

if exist('nAngle','var') == 0
    nAngle = 96;  % Taken from referred article.
end % Set angle samples if input is missing.

if exist('interpolationMethod','var') == 0
    interpolationMethod = 'bilinear';
end

% This should be set to a certain max.
% rLimit = floor(min([rows - centerY; centerY; cols - centerX; centerX]) - 1);
rLimit = 25;

polarIm = NaN(nRadius, nAngle);
insertCol = 1;
% Sample the image in polar coordinates.
for theta = 0:2*pi/nAngle : 2*pi - 2*pi/nAngle
    polarIm(:,insertCol) = improfile(im,...
        [centerX, centerX + rLimit*cos(theta)], ...
        [centerY, centerY + rLimit*sin(theta)], ...
        nRadius, interpolationMethod)';
    % Interpolation method bilinear and bicubic yields similar results.
    insertCol = insertCol + 1;
end