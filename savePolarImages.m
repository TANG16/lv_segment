function savePolarImages(imSet, resolution, savePath, silent)
% Also resamples the images.

if nargin < 1
    error('Not enough input arguments')
end

% Radial and angular sampling.
% Taken from the article "Convolutional neural network for short-axis left
% ventricle segmentation in cardiac cine MR sequences" Tan et al, 2017.
nAngPoints = 96;
nRadPoints = 56;
radius = 30; % Cropping radius from centerpoint.
interpolationMethod = 'bilinear';

% Resample image set.
imSet = resampleImages(imSet, resolution);

% Initiate polar representations.
nImages = size(imSet.IM,3);
polarIm = NaN(nRadPoints, nAngPoints);
polarContour = NaN(2, nAngPoints);

% Create the save folder.
if exist(savePath, 'dir') ~= 7
    mkdir(savePath);
    mkdir(fullfile(savePath, 'images'));
    mkdir(fullfile(savePath, 'labels'));
end

for iImage = 1:nImages
    missingEpiPoints = [];           % Failed intersection check.
    missingEndoPoints = [];
    
    % Check that we aren't cropping outside the image.
    if radius > min([imSet.Center(iImage,1), ...
            size(imSet.IM, 1) - imSet.Center(iImage,1), ...
            imSet.Center(iImage,2), ...
            size(imSet.IM, 1) - imSet.Center(iImage,2)])
        error('Trying to crop the image outside its boundaries.')
    end
    
    iInsert = 1;    % Radial counter.
    % Sample the image in polar coordinates.
    for iTheta = 0:2*pi/nAngPoints : 2*pi - 2*pi/nAngPoints
        rLineX = [imSet.Center(iImage,1), imSet.Center(iImage,1) + radius*sin(iTheta)];
        rLineY = [imSet.Center(iImage,2), imSet.Center(iImage,2) + radius*cos(iTheta)];
        
        % Interpolate in radial direction from the centerpoint to rLimit.
        polarIm(:,iInsert) = improfile(imSet.IM(:,:,iImage), rLineY, rLineX, ...
            nRadPoints, interpolationMethod)';
        
        % Find the radial distances to the endo- and epicardial contours.
        % Endoardial.
        % Find the radial distance.
        [endoX, endoY] = intersections(rLineX, rLineY, imSet.Endo(:,1,iImage), ...
            imSet.Endo(:,2,iImage));
        if isempty(endoX) || isempty(endoY)
            polarContour(1, iInsert) = NaN;
            missingEndoPoints = [missingEndoPoints iInsert];
        else
            % Calculate the distance from the centerpoint.
            polarContour(1, iInsert) = sqrt((endoX - imSet.Center(iImage,1))^2 + ...
                (endoY - imSet.Center(iImage,2))^2)/(radius/nRadPoints);
        end
        % Epicardial.
        [epiX, epiY] = intersections(rLineX, rLineY, imSet.Epi(:,1,iImage), ...
            imSet.Epi(:,2,iImage));
        if isempty(epiX) || isempty(epiY)
            polarContour(2, iInsert) = NaN;
            missingEpiPoints = [missingEpiPoints iInsert];
        else
            polarContour(2, iInsert) = sqrt((epiX - imSet.Center(iImage,1))^2 + ...
                (epiY - imSet.Center(iImage,2))^2)/(radius/nRadPoints);
        end
        iInsert = iInsert + 1;
    end
    
    % Interpolate the missing contour points.
    if size(missingEndoPoints,2) > 0
        if size(missingEndoPoints,2) > 10
            disp('Too few intersecting points, skipping');
            continue;
        end
        angInd = 1:nAngPoints;
        polarContour(1,:) = interp1(angInd(~isnan(polarContour(1,:))), ...
            polarContour(1,~isnan(polarContour(1,:))), angInd);
    end
    if size(missingEpiPoints,2) > 0
        if size(missingEpiPoints,2) > 10
            disp('Too few intersecting points, skipping');
            continue;
        end
        angInd = 1:nAngPoints;
        polarContour(2,:) = interp1(angInd(~isnan(polarContour(2,:))), ...
            polarContour(2,~isnan(polarContour(2,:))), angInd);
    end
    
    % Generate polar LV Mask using the polar contour.
    maskX = [polarContour(1,:) flip(polarContour(2,:))];
    maskY = [linspace(1, nAngPoints, nAngPoints) linspace(nAngPoints, 1, nAngPoints)];
    polarLVMask = poly2mask(maskY, maskX, nRadPoints, nAngPoints);
    
    % Save the images.
    imwrite(polarIm, fullfile(savePath, 'images', ...
        [imSet.DataSetName '_' imSet.FileName '_' num2str(iImage) '.png']), 'png');
    imwrite(polarLVMask, fullfile(savePath, 'labels', ...
        [imSet.DataSetName '_' imSet.FileName '_' num2str(iImage) '.png']), 'png');
    
    if (~silent)
        drawPolarLV(polarIm, ...
            polarContour(1,:), polarContour(2,:), ...
            ['Polar Image for dataset ' imSet.DataSetName ', file ' ...
            imSet.FileName '_' num2str(iImage)]);
    end
end

%-----------------------------------
function imSet = resampleImages(imSet, resolution)
%-----------------------------------
% Upsamples current image stack (in slice only). Takes care of
% segmentation in the upsampling process.

% Stolen and adapted from Segment (functions upsampleimage_Callback,
% upsamplevolume and resamplehelper).

f = imSet.Resolution/resolution; % Resample factor.

imSet.IM = upsamplevolume(f, imSet.IM);

% Resample contours.
imSet.Endo = resamplehelper(f,imSet.Endo);
imSet.Epi = resamplehelper(f,imSet.Epi);

% Resample renter.
imSet.Center = resamplehelper(f,imSet.Center);

% Resample resolution.
imSet.Resolution = imSet.Resolution/f;

%-------------------------------
function x = resamplehelper(f,x)
%-------------------------------
%Helper function to resample image stacks.
%factor 2 => x' = 2*x-0.5
%factor 3 => x' = 3*x-1
%factor 4 => x' = 4*x-1.5
%factor 5 => x' = 5*x-2
%factor 2.5 => x' = 2.5*x-1
%factor 3.5 => x' = 3.5*x-1.5
%factor 0.5 => x' = x'*0.5 (a odd)
%factor 0.5 => x' = x'*0.5+0.5 (a even)

if f>0
    d = (ceil(f)-1)/2;
else
    d = 0;
end;

if isa(x,'double')
    x = x*f-d;
else
    for xloop=1:size(x,1)
        for yloop=1:size(x,2)
            x{xloop,yloop} = x{xloop,yloop}*f-d;
        end;
    end;
end;

%--------------------------------------
function newvol = upsamplevolume(f,vol)
%--------------------------------------
%Helper function to upsample a volume vol.

%Find new size
newsize = size(imresize(vol(:,:,1,1),f,'nearest'));

%Reserve memory
if isa(vol,'single')
    newvol = repmat(single(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
elseif isa(vol,'int16')
    newvol = repmat(int16(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
else
    newvol = zeros(newsize(1),newsize(2),size(vol,3),size(vol,4));
end;

%Loop over image volume
for tloop=1:size(vol,3)
    for zloop=1:size(vol,4)
        if isa(vol,'single')
            newvol(:,:,tloop,zloop) = single(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        elseif isa(vol,'int16')
            newvol(:,:,tloop,zloop) = int16(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        else
            newvol(:,:,tloop,zloop) = imresize(vol(:,:,tloop,zloop),f,'bicubic');
        end;
    end;
end;