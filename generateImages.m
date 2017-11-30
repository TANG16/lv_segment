%-----------------------------------
function generateImages
%-----------------------------------
% Generate image data set by polar remapping, resampling and generating
% ground truth masks, then saving them to a database file compatible with
% the caffe framework.

silent = 1;
resolution = 1.5;

loadPath = uigetdir(pwd, ...
    'Select a folder of .mat-files containing data exported by plugin_exportlvcontours.');

savePath = uigetdir(pwd, ...
    'Select a folder to save the images into.');

if isequal(loadPath,0) || isequal(savePath,0)
    failed('No load and/or save path chosen. Aborted.');
    return;
end

filesInDir = dir([loadPath filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

h = waitbar(0,'Processing images, please wait...');
for iFile = 1:nFiles
    % Load data set.
    load([loadPath filesep fileNames{iFile}],'-mat');
    
    % Save normal images.
    %arrayfun(@(x) saveImages(x, resolution, ...
    %    fullfile(savePath, '/systolic'), silent), systolic);
    %arrayfun(@(x) saveImages(x, resolution, ...
    %    fullfile(savePath, '/diastolic'), silent), diastolic);
    
    % Generate and save polar images.
    arrayfun(@(x) savePolarImages(x, resolution, ...
        fullfile(savePath, '/systolic', 'polar'), silent), systolic);
    arrayfun(@(x) savePolarImages(x, resolution, ...
        fullfile(savePath, '/diastolic', 'polar'), silent), diastolic);
    
    waitbar(iFile/nFiles);
end
close(h);
end

%-----------------------------------
function saveImages(imSet, resolution, savePath, silent)
%-----------------------------------
mkdir(fullfile(savePath, 'normal', 'images'));
mkdir(fullfile(savePath, 'normal', 'labels'));

% imSet = resampleImages(imSet, resolution);
imSet = cropImages(imSet);

% Mean variance equalization

for iImage = 1:nImages
    % Crop image.
    
    im = cropImage(imSet.IM(:,:,iImage),imSet.Center(:,iImage));
    % Generate mask.
    mask = poly2mask([imSet.Endo(:,1,iImage) imSet.Epi(:,1,iImage)], ...
        [imSet.Endo(:,2,iImage) imSet.Epi(:,2,iImage)], ...
        size(imSet.IM,1),size(imSet.IM,2));
    
    % Save image and mask
    saveImage(im, fullfile(savePath, 'images', ...
        [imSet.DataSetName '_' imSet.FileName '_' num2str(iImage)]));
    saveImage(mask, fullfile(savePath, 'labels', ...
        [imSet.DataSetName '_' imSet.FileName '_' num2str(iImage)]));
end
end

%-----------------------------------
function im = cropImage(im, center)
%-----------------------------------
% Wanted size: 96x96
cropSize = 96;  % Desired size;
height = size(im,1);
width = size(im,2);
padHeight = 0;
padWidth = 0;

% Zero pad image if needed.
if height < cropSize
    padHeight = cropSize - height;
end
if width < cropSize
    padWidth = cropSize - width;
end
im = padarray(im, [padHeight padWidth]);

% If the pad was not done, crop instead.
if padHeight == 0
    cropStart = 0;
    cropEnd = 0;
    im = im(cropStart:cropEnd,:);
end

if padWidth == 0
    
    
    im = im(:,cropStart:cropEnd);
end

end

%-----------------------------------
function savePolarImages(imSet, resolution, savePath, silent)
%-----------------------------------

if nargin < 1
    error('Not enough input arguments')
end

% Radial and angular sampling.
% Taken from the article "Convolutional neural network for short-axis left
% ventricle segmentation in cardiac cine MR sequences" Tan et al, 2017.
nAngPoints = 96;
nRadPoints = 56;
radius = 28; % Cropping radius from centerpoint.
interpolationMethod = 'bilinear';
nSkipped = 0;

% Resample image set.
% imSet = resampleImages(imSet, resolution);
nImages = size(imSet.IM,3);

% Create the save folder if it does not already exist.
if exist(savePath, 'dir') ~= 7
    mkdir(fullfile(savePath, 'images'));
    mkdir(fullfile(savePath, 'labels'));
end

fprintf('Generating images from %s \n', imSet.DataSetName);
for iImage = 1:nImages
    try
        polarIm = NaN(nRadPoints, nAngPoints);
        polarContour = NaN(2, nAngPoints);
        
        % Check that we aren't cropping outside the image.
        if radius > min([imSet.Center(1,iImage), ...
                size(imSet.IM, 1) - imSet.Center(1,iImage), ...
                imSet.Center(2,iImage), ...
                size(imSet.IM, 2) - imSet.Center(2,iImage)])
            fprintf('Trying to crop the image outside its boundaries, skipping.\n');
            nSkipped = nSkipped + 1;
            continue;
        end
        
        iInsert = 1;    % Radial counter.
        
        % Sample the image in polar coordinates.
        for iTheta = 0:2*pi/nAngPoints : 2*pi - 2*pi/nAngPoints
            rLineX = [imSet.Center(1,iImage), imSet.Center(1,iImage) + radius*sin(iTheta)];
            rLineY = [imSet.Center(2,iImage), imSet.Center(2,iImage) + radius*cos(iTheta)];
            
            % Interpolate in radial direction from the centerpoint to rLimit.
            polarIm(:,iInsert) = improfile(imSet.IM(:,:,iImage), rLineY, rLineX, ...
                nRadPoints, interpolationMethod)';
            
            % ------ Endocardial ------
            % Find the position where a line from the center intersectswith the
            % endocardium.
            [endoX, endoY] = intersections(rLineX, rLineY, ...
                imSet.Endo(:,1,iImage), imSet.Endo(:,2,iImage));
            
            % Check if the instersection was found.
            if length(endoX) == 1 || length(endoY) == 1
                % Calculate the radial distance.
                polarContour(1, iInsert) = sqrt((endoX - imSet.Center(1,iImage))^2 + ...
                    (endoY - imSet.Center(2,iImage))^2)/(radius/nRadPoints);
            end
            
            % ------ Epicardial ------
            [epiX, epiY] = intersections(rLineX, rLineY, ...
                imSet.Epi(:,1,iImage), imSet.Epi(:,2,iImage));
            if length(epiX) == 1 || length(epiY) == 1
                polarContour(2, iInsert) = sqrt((epiX - imSet.Center(1,iImage))^2 + ...
                    (epiY - imSet.Center(2,iImage))^2)/(radius/nRadPoints);
            end
            iInsert = iInsert + 1;
        end
        
        % Check missing contour points.
        if any(any(isnan(polarContour)))
            angInd = 1:nAngPoints;
            % Skip image if more than 10% of the total contour points are missing.
            if sum(isnan(polarContour(1,:))) > 30 || sum(isnan(polarContour(2,:))) > 30
                fprintf('Too few intersecting points found, skipping.\n');
                nSkipped = nSkipped + 1;
%                 figure;
%                 imshow(imSet.IM(:,:,iImage))
%                 hold on
%                 plot(imSet.Endo(:,2,iImage), ...
%                     imSet.Endo(:,1,iImage), 'r-');
%                 plot(imSet.Epi(:,2,iImage), ...
%                     imSet.Epi(:,1,iImage), 'g-');
%                 plot(imSet.Center(2,iImage), imSet.Center(1,iImage), ...
%                     'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
%                 polarContour
%                 drawnow;
%                 pause;
                continue;
            else % Interpolate missing contour points
                polarContour(1,:) = interp1(angInd(~isnan(polarContour(1,:))), ...
                    polarContour(1,~isnan(polarContour(1,:))), ...
                    angInd, 'linear', 'extrap');
                polarContour(2,:) = interp1(angInd(~isnan(polarContour(2,:))), ...
                    polarContour(2,~isnan(polarContour(2,:))), ...
                    angInd, 'linear', 'extrap');
            end
        end
        
        if any(any(isnan(polarContour))) || any(any(isinf(polarContour)))
            fprintf('Can not create a contour, skipping. \n')
            nSkipped = nSkipped + 1;
            continue;
        else
            % Generate polar LV Mask using the polar contour.
            % Add extra points to create a mask to the edges.
            maskX = [polarContour(1,:) flip(polarContour(2,:)) polarContour(1,1)];
            maskY = [linspace(1, nAngPoints, nAngPoints) linspace(nAngPoints, 1, nAngPoints) 1];
            polarLVMask = im2uint8(createmask([nRadPoints nAngPoints], maskY, maskX));
        end
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
    catch e
        fprintf(2,'The identifier was:\n%s',e.identifier);
        fprintf(2,'There was an error! The message was:\n%s',e.message);
        fprintf(['Error found, skipped image in dataset ' imSet.DataSetName ...
            ', file ' imSet.FileName '_' num2str(iImage)]);
    end
end

if nSkipped > 0
    fprintf('\n Skipped %i images in imageset %s %s. \n', nSkipped, ...
        imSet.DataSetName, imSet.FileName);
end

end

%-----------------------------------
function saveImage(im, path)
%-----------------------------------

imwrite(im, fullfile(path, [path '.png']), 'png');
end

%---------------------------------------
function mask = createmask(outsize,y,x)
%---------------------------------------
%Function to generate a mask from a polygon represented with the vectors x
%and y.

%Check if NaN then return empty
if any(isnan(x)) || any(isnan(y))
    mask = false(outsize);
    return;
end

mask = false(outsize);
mx = round(mean([x(2) x(end-2)]));
my = round(mean([x(95) x(98)]));
x = interp1(x,linspace(1,length(x),1000));
y = interp1(y,linspace(1,length(y),1000));
mask(sub2ind(outsize,round(x),round(y))) = true;
mask = imfill(mask,[mx 2],4);
mask = imfill(mask,[my 95],4);
mask = imfill(mask, 4, 'holes');
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
end

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
end

if isa(x,'double')
    x = x*f-d;
else
    for xloop=1:size(x,1)
        for yloop=1:size(x,2)
            x{xloop,yloop} = x{xloop,yloop}*f-d;
        end
    end
end
end

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
end

%Loop over image volume
for tloop=1:size(vol,3)
    for zloop=1:size(vol,4)
        if isa(vol,'single')
            newvol(:,:,tloop,zloop) = single(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        elseif isa(vol,'int16')
            newvol(:,:,tloop,zloop) = int16(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        else
            newvol(:,:,tloop,zloop) = imresize(vol(:,:,tloop,zloop),f,'bicubic');
        end
    end
end
end