function polarIm = imToPolarCoordinates(im, centerPoint, nRadius, nAngle)
% IMGPOLARCOORD converts a given image from cartesian coordinates to polar
% coordinates.
%
% Input:
%        img  : bidimensional image.
%      radius : radius length (# of pixels to be considered).
%      angle  : # of angles to be considered for decomposition.
%
% Output:
%       pcimg : polar coordinate image.

if nargin < 1
    error('Please specify an image.');
else if nargin < 2
        error('Please specify a centerpoint.');
    end
end
[rows, cols] = size(im);

if exist('centerPoint','var') == 0
    centerX = round(rows/2);
    centerY = round(cols/2);
else
    centerX = centerPoint(1);
    centerY = centerPoint(2);
end % Extract centerpoint, set to middle of the image if input is missing.

if exist('radius','var') == 0
    nRadius = floor(min([rows - centerX; centerX; cols - centerY; centerY]) - 1);
end % Sample the image to the edge from the centerpoint if input is missing.

if exist('nAngle','var') == 0
    nAngle = 96;  % Taken from referred article.
end % Set angle samples if input is missing.


%    [theta,rho] = cart2pol(x,y)
% theta = (0:1/4:2)*pi;
% rad = 0:5;
% [T, R] = meshgrid(theta, rad);
% [X, Y] = pol2cart(T, R);


% Sample the image in polar coordinates.
insertCol = 1;
for r = 0:nRadius
    for theta = 0:2*pi/nAngle : 2*pi - 2*pi/nAngle'
        polarIm(r + 1, insertCol) = im(round(centerY + r*sin(theta)), ...
            round(centerX + r*cos(theta)));
        insertCol = insertCol + 1;
    end
end