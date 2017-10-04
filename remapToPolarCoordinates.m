function [polarIm, polarContour] = remapToPolarCoordinates( ...
    im, endoContour, epiContour, centerX , centerY, ...
    radius, nRadPoints, nAngle, interpolationMethod)
%

if nargin < 5
    error('Not enough input arguments')
end

if nargin < 6
    radius = 25; % Investigate what limit is suitable.
end % Set radius if not specified.

if nargin < 7
    nRadPoints = 56;   % Taken from article.
end % Sample the image to the edge from the centerpoint if not specified.

if nargin < 8
    nAngle = 96;  % Taken from article.
end % Set angle samples if not specified

if nargin < 9
    interpolationMethod = 'nearest';
end % Set interpolation method if not specified.

% Preallocate polar image and contour.
polarIm = NaN(nRadPoints, nAngle);
polarContour = NaN(nAngle,2);

iInsert = 1;    % Radial counter
% Sample the image in polar coordinates.
for iTheta = 0:2*pi/nAngle : 2*pi - 2*pi/nAngle
    rLineX = [centerX, centerX + radius*sin(iTheta)];
    rLineY = [centerY, centerY + radius*cos(iTheta)];
    
    % Interpolate in radial direction from the centerpoint to rLimit.
    polarIm(:,iInsert) = improfile(im, rLineY, rLineX, ...
        nRadPoints, interpolationMethod)';
    
    % Find the radial distances to the endo- and epicardial contours.
    [endoX, endoY] = intersections(rLineX, rLineY, endoContour(:,1), ...
        endoContour(:,2), false);
    polarContour(iInsert,1) = sqrt((endoX - centerX)^2 + ...
        (endoY - centerY)^2)/(radius/nRadPoints);
    [epiX, epiY] = intersections(rLineX, rLineY, epiContour(:,1), ...
        epiContour(:,2), false);
    polarContour(iInsert,2) = sqrt((epiX - centerX)^2 + ...
        (epiY - centerY)^2)/(radius/nRadPoints);
    
    iInsert = iInsert + 1;
end
