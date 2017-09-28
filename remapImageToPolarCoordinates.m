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

[rows, cols] = size(im);
props = regionprops(mask,'Centroid');
centerRow = props.Centroid(1);
centerCol = props.Centroid(2);
angleResolution = 96;
radialResolution = 56;
imShow = insertMarker(im,props.Centroid,'o','color','red','size',1);

%% cart2pol
%    [theta,rho] = cart2pol(x,y)
% theta = (0:1/4:2)*pi;
% rad = 0:5;
% [T, R] = meshgrid(theta, rad);
% [X, Y] = pol2cart(T, R);


maxRadius = floor(min([rows - centerRow; centerRow; cols - centerY; centerY]) - 2);

[x, y] = meshgrid(centerRow - maxRadius : centerRow + maxRadius, ...
    centerY - maxRadius : centerY + maxRadius);

[theta, rho] = cart2pol(x, y);

figure; imagesc(imShow) ; axis square; colormap gray

subplot(221), imshow(im), axis on;
hold on;
subplot(221), plot(xCenter,yCenter, 'r+');
subplot(222), warp(theta, rho, zeros(size(theta)), im);
view(2), axis square;

% These is the spacing of your radius axis (columns)
rhoRange = linspace(0, max(rho(:)), 100);

% This is the spacing of your theta axis (rows)
thetaRange = linspace(-pi, pi, 100);

% Generate a grid of all (theta, rho) coordinates in your destination image
[T,R] = meshgrid(thetaRange, rhoRange);

% Now map the values in img to your new image domain
theta_rho_image = griddata(theta, rho, double(im), T, R);

%%

[rows, cols] = size(im);

[X,Y] = meshgrid((1:cols) - centerCol, (1:rows) - centerRow);

[theta, rho] = cart2pol(X, Y);

rhoRange = linspace(0, max(rho(:)), 1000);
thetaRange = linspace(-pi, pi, 1000);

[T, R] = meshgrid(thetaRange, rhoRange);

theta_rho_image = griddata(theta, rho, double(im), T, R);

figure
subplot(1,2,1);
imagesc(im);
title('Original Image'); axis image; colormap gray

subplot(1,2,2);
imagesc(theta_rho_image);
title('Polar Image'); axis image; colormap gray
%% function polarIm = remapImageToPolarCoordinates(im, centerPoint, ...
%     angleResolution, radialResolution)

[Y, X, z] = find(im);
centerRow = centerPoint(1);
centerY = centerPoint(2);
X = X - centerRow;
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
    centerRow = round(rows/2);
    centerY = round(cols/2);
else
    centerRow = centerPoint(1);
    centerY = centerPoint(2);
end % Extract centerpoint, set to middle of the image if input is missing.

if exist('radius','var') == 0
    nRadius = floor(min([rows - centerRow; centerRow; cols - centerY; centerY]) - 1);
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
            round(centerRow + r*cos(theta)));
        insertCol = insertCol + 1;
    end
end


subplot(1,2,1); imagesc(im) ; axis square; colormap gray
subplot(1,2,2); imagesc(polarIm) ; axis square; colormap gray
