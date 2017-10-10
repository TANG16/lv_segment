% % process images.

loadPathName = uigetdir(pwd,['Select a folder containing exported images' ...
    ' and contours in .mat files']);

[~, savePath] = uiputfile('*.mat', ...
    'Select .mat file to save processed images to.');

if isequal(loadPathName,0) || isequal(savePath,0)
    failed('No load or save path chosen. Aborted.');
    return;
end

filesInDir = dir([loadPathName filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

h = waitbar(0,'Processing images, please wait...');
for iFile = 1:nFiles
    load([loadPathName filesep fileNames{iFile}],'-mat');
    nPat = size(outdata,1); % Image set (from one patient).
    
    % Remove NaN rows.
    
    for iPat = 1:nPat
        % Resize Images and contours to a set mm/pixel.
        nImages = size(outdata(iPat).DiaIm, 3);
        
        % Extract Centerpoints.
        % If ejection tract, use centerpoint above/below.
        for iImage = 1:nImages
            outdata(iPat).DiaCenterX
        end
        
        for iImage = 1:nImages
            
            % Remap images and contours to polar space.
            [polarDiaIm, polarDiaContour] = remapToPolarCoordinates( ...
                outdata(iPat).DiaIm(:,:,iImage), ...
                outdata(iPat).DiaEndo(:,:,iImage), ...
                outdata(iPat).DiaEpi(:,:,iImage), ...
                outdata(iPat).DiaCenterX(:,iImage), ...
                outdata(iPat).DiaCenterY(:,:,iImage));
        end
        
        nImages = size(outdata(iPat).SysIm, 3);
        
        for iImage = 1:nImages
            
            [polarSysIm, polarSysContour] = remapToPolarCoordinates( ...
                outdata(iPat).SysIm(:,:,iImage), ...
                outdata(iPat).SysEndo(:,:,iImage), ...
                outdata(iPat).SysEpi(:,:,iImage), ...
                outdata(iPat).SysCenterX(:,:,iImage), ...
                outdata(iPat).SysCenterY(:,:,iImage));
            % Augment images
            
            % Split into train/test/validation set.
            
            % End output:
            % Images in polar space, nRadius x nAngle x nImages
            % Contour positions in polar space, 2 x nAngle x nImages
            % Set resolution mm/pixel.
        end
    end
    waitbar(iFile/nFiles);
end
close(h);
