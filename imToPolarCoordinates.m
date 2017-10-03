function [polarIm, polarEndoContour, polarEpiContour] = imToPolarCoordinates( ...
    im, endoContour, epiContour, centerPoint, rLimit, ...
    nRadius, nAngle, interpolationMethod)
%

if nargin < 4
    error('Not enough input arguments')
end

if nargin < 5
    rLimit = 25;
    % rLimit = floor(min([rows - centerY; centerY; cols - centerX; centerX]) - 1);
end

if nargin < 6
    nRadius = 56;   % Taken from article.
end % Sample the image to the edge from the centerpoint if input is missing.

if nargin < 7
    nAngle = 96;  % Taken from article.
end % Set angle samples if input is missing.

if nargin < 8
    interpolationMethod = 'bilinear';
end

% Preallocate output.
polarIm = NaN(nRadius, nAngle);
polarEndoContour = NaN(2,nAngle);
polarEpiContour = NaN(2,nAngle);

insertCol = 1;
% Sample the image in polar coordinates.
for theta = 0:2*pi/nAngle : 2*pi - 2*pi/nAngle
    polarIm(:,insertCol) = improfile(im, ...
        [centerX, centerX + rLimit*cos(theta)], ...
        [centerY, centerY + rLimit*sin(theta)], ...
        nRadius, interpolationMethod)';
%     polarEndoContour() = 
    insertCol = insertCol + 1;
end