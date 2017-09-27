clear all
clc

%% test
imNo = 13;
load lv_contours.mat
IM = cat(3,Outdata.SYSIM, Outdata.DIAIM);
MASK = cat(3,Outdata.SYSMASK, Outdata.DIAMASK);
N = size(IM,3); % Number of images.
im = IM(:,:,imNo);
mask = MASK(:,:,imNo);

props = regionprops(mask,'Centroid');
centerPoint = props.Centroid;
angleResolution = 96;
radialResolution = 56;
imShow = insertMarker(im,props.Centroid,'o','color','red','size',1);

%% function polarIm = remapImageToPolarCoordinates(im, centerPoint, ...
%     angleResolution, radialResolution)

[Y, X, z] = find(im);
centerX = centerPoint(1);
centerY = centerPoint(2);
X = X - centerX;
Y = Y - centerY;
theta = atan2(Y,X);
rho = sqrt(X.^2+Y.^2);

% Determine the minimum and the maximum x and y values:
rmin = min(rho); tmin = min(theta);
rmax = max(rho); tmax = max(theta);

F = scatteredInterpolant(rho, theta, z, 'natural');
%  TriScatteredInterp(rho,theta,z,'natural');

% Evaluate the interpolant at the locations (rhoi, thetai).
% The corresponding value at these locations is polarIm:
[rhoi, thetai] = meshgrid(linspace(rmin, rmax, radialResolution), ...
    linspace(tmin, tmax, angleResolution));
polarIm = F(rhoi, thetai);

subplot(1,2,1); imagesc(imShow) ; axis image; colormap gray
subplot(1,2,2); imagesc(polarIm) ; axis image; colormap gray

%% function polarIm = imToPolarCoordinates(im, centerPoint, radialResolution, angleResolution)

% if nargin < 1
%     error('Please specify an image.');
%   else if nargin < 2
%         error('Please specify a centerpoint.');
%     end
% end
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


subplot(1,2,1); imagesc(im) ; axis square; colormap gray
subplot(1,2,2); imagesc(polarIm) ; axis square; colormap gray
