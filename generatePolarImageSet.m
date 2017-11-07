function generatePolarImageSet
% Generate image data set by polar remapping, resampling and generating
% ground truth masks, then saving them to a database file compatible with
% the caffe framework.

silent = 1;
resolution = 1.5;

loadPath = uigetdir(pwd, ...
    'Select a .mat file containing images and contours.');

savePath = uigetdir(pwd, ...
    'Select a folder to save processed images to.');

if isequal(loadPath,0) || isequal(savePath,0)
    failed('No load and/or save path chosen. Aborted.');
    return;
end

filesInDir = dir([loadPath filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

h = waitbar(0,'Processing images, please wait...');
for iFile = 1:nFiles
    load([loadPath filesep fileNames{iFile}],'-mat');
    
    arrayfun(@(x) savePolarImages(x, resolution, ...
        fullfile(savePath, '/systolic'), silent), systolic);
    arrayfun(@(x) savePolarImages(x, resolution, ...
        fullfile(savePath, '/diastolic'), silent), diastolic);
    waitbar(iFile/nFiles);
end
close(h);