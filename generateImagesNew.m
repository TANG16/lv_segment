%-----------------------------------
function generateImagesNew
%-----------------------------------
% Generate image data set by polar remapping, resampling and generating
% ground truth masks, then saving them to a database file compatible with
% the caffe framework.

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
parfor iFile = 1:nFiles
    % Load data set.
    data = load([loadPath filesep fileNames{iFile}],'-mat');
    
    % Save normal images.
    arrayfun(@(x) saveImages(x, resolution, ...
        fullfile(savePath), 'sys'), data.systolic);
    arrayfun(@(x) saveImages(x, resolution, ...
        fullfile(savePath), 'dia'), data.diastolic);

    waitbar(iFile/nFiles);
end
close(h);
diary OFF;
end

%-----------------------------------
function saveImages(imSet, resolution, savePath, phase)
%-----------------------------------
% Resample image set.
imSet = resampleImages(imSet, resolution);

% Create save folders.
phasePath = fullfile(savePath, phase);
mergedPath = fullfile(savePath, 'merged');
if exist(phasePath ,'dir') == 0
    mkdir(fullfile(phasePath, 'images'));
    mkdir(fullfile(phasePath, 'labels'));
end
if exist(mergedPath, 'dir') == 0
    mkdir(fullfile(mergedPath, 'labels'));
    mkdir(fullfile(mergedPath, 'images'));
end

nImages = size(imSet.IM, 3);
radius = 27; % Corresponding to 82,5x82,5mm crops
cropSize = radius*2 + 1;
% endoColor = 'r-';
% epiColor = 'g-';

fprintf('Generating images from %s \n', imSet.DataSetName);
for iImage = 1:nImages
    %     try
    % Decide what folder to save into.
    if iImage < 3
        continue;
    elseif iImage == nImages
        continue;
    end
    
    im = imSet.IM(:,:,iImage);
    centerX = round(imSet.Center(1,iImage));
    centerY = round(imSet.Center(2,iImage));
    
    % If we will crop outside the image, zero pad.
    if radius >= min([centerX, size(im, 1) - centerX, ...
            centerY, size(im, 2) - centerY])
        
        im = padarray(im, [radius radius] , 0, 'both');
        centerX = centerX + radius;
        centerY = centerY + radius;
        imSet.Endo(:,:,iImage) = imSet.Endo(:,:,iImage) + radius;
        imSet.Epi(:,:,iImage) = imSet.Epi(:,:,iImage) + radius;
    end
    
%     % Plot normal image.
%     figure(1);
%     imagesc(im); colormap gray; axis image; colorbar;
%     hold on
%     plot(imSet.Endo(:,2,iImage), imSet.Endo(:,1,iImage), endoColor);
%     plot(imSet.Epi(:,2,iImage), imSet.Epi(:,1,iImage), epiColor);
%     plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
%     drawnow;
    
    % Crop and resize image and mask to 128x128 pixels.
    im = imresize(im((centerX - radius):(centerX + radius + 1), ...
        (centerY - radius):(centerY + radius + 1)),[128 128]);
    
    % Generate mask.
    endoX = (imSet.Endo(:,1,iImage) - (centerX - radius - 1))*128/(cropSize);
    endoY = (imSet.Endo(:,2,iImage) - (centerY - radius - 1))*128/(cropSize);
    epiX = (imSet.Epi(:,1,iImage) - (centerX - radius - 1))*128/(cropSize);
    epiY = (imSet.Epi(:,2,iImage) - (centerY - radius - 1))*128/(cropSize);
    mask = im2uint8(poly2mask([endoY; epiY], [endoX; epiX], 128, 128));
    
%     % Plot resized image.
%     figure(2);
%     imagesc(im); colormap gray; axis image; colorbar;
%     hold on
%     plot(endoY, endoX, endoColor);
%     plot(epiY, epiX, epiColor);
%     plot(centerY, centerX, 'Marker', '*', 'Color', [0 0 1], 'MarkerSize', 10);
%     drawnow;
    
%     % Plot overlay  
%     B = labeloverlay(im,mask,'Transparency', 0.9);
%     figure;
%     imshow(B);
%     hold on
%     plot(endoY, endoX, endoColor);
%     plot(epiY, epiX, epiColor);
%     pause;
    
    % Save the images.
    [~,datasetName,~] = fileparts(imSet.DataSetName);
    imwrite(im, fullfile(phasePath, 'images', ...
        [datasetName '_' imSet.FileName '_' num2str(iImage) '.png']), 'png');
    imwrite(mask, fullfile(phasePath, 'labels', ...
        [datasetName '_' imSet.FileName '_' num2str(iImage) '.png']), 'png');
    
    % Save images into a merged folder
    imwrite(im, fullfile(mergedPath, 'images', ...
        [datasetName '_' imSet.FileName '_' num2str(iImage) '_' phase '.png']), 'png');
    imwrite(mask, fullfile(mergedPath, 'labels', ...
        [datasetName '_' imSet.FileName '_' num2str(iImage) '_' phase '.png']), 'png');
    %     catch e
    %         getReport(e)
    %     end
end
end

%-----------------------------------
function imSet = resampleImages(imSet, resolution)
%-----------------------------------
% Upsamples current image stack (in slice only). Takes care of
% segmentation in the upsampling process.

% Stolen and adapted from Segment (functions upsampleimage_Callback,
% upsamplevolume and resamplehelper).

f = imSet.ResolutionX/resolution; % Resample factor.

imSet.IM = upsamplevolume(f, imSet.IM);

% Resample contours.
imSet.Endo = resamplehelper(f,imSet.Endo);
imSet.Epi = resamplehelper(f,imSet.Epi);

% Resample renter.
imSet.Center = resamplehelper(f,imSet.Center);

% Resample resolution.
imSet.ResolutionX = imSet.ResolutionX/f;
imSet.ResolutionY = imSet.ResolutionY/f;
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