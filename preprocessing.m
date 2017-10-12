% % process images.

loadPathName = uigetfile(pwd,'*.mat', ...
    'Select a .mat file containing images and contours.');

savePath = uigetdir(pwd, ...
    'Select a folder to save processed images to.');

if isequal(loadPathName,0) || isequal(savePath,0)
    failed('No load and/or save path chosen. Aborted.');
    return;
end

filesInDir = dir([loadPathName filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

resolution = 1;

h = waitbar(0,'Processing images, please wait...');
for iFile = 1:nFiles
    load([loadPathName filesep fileNames{iFile}],'-mat');
    nPat = size(outdata,1); % Image set (from one patient).
    
    % Remove NaN rows.
    
    for iPat = 1:nPat
        % Resize Images and contours to the same resolution
        % (up/downsample).
        resampleImages(systolicDataSet(iPat), resolution);
        
        % Resize Images and contours to a set mm/pixel.
        nImages = size(outdata(iPat).DiaIm, 3);
        
        % Extract Centerpoints.
        % If ejection tract, use centerpoint above/below.
        for iImage = 1:nImages
            outdata(iPat).Center
        end
        
        for iImage = 1:nImages
            % Remap images and contours to polar space.
            [polarDiaIm, polarDiaContour] = remapToPolarCoordinates( ...
                outdata(iPat).Im(:,:,iImage), ...
                outdata(iPat).Endo(:,:,iImage), ...
                outdata(iPat).Epi(:,:,iImage), ...
                outdata(iPat).Center(:,iImage));
        end
        
            
            % Split into train/test/validation set.
            
            % End output:
            % Images in polar space, nRadius x nAngle x nImages
            % Contour positions in polar space, 2 x nAngle x nImages
            % Set resolution mm/pixel.
    end
    waitbar(iFile/nFiles);
end
close(h);
