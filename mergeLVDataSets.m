function mergeLVDataSets
%% Merge data sets.

% Select a folder to load mat files from.
loadPath = uigetdir('*.mat', ...
    'Select a folder containing exported images and contours in .mat files');

% Choose .mat save file destination.
[saveFileName, savePath] = uiputfile('*.mat', ...
    'Select a folder to save processed images to.');

% Check that paths were chosen.
if isequal(loadPath,0) || isequal(savePath,0)
    warning('No load or save path chosen. Aborted.');
    return;
end
savePath = [savePath saveFileName];

% Find files in the folder.
filesInDir = dir([loadPath filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

% Initialize merge.
mergedSys = [];
mergedDia = [];

for iFile = 1:nFiles
    load([loadPath filesep fileNames{iFile}],'-mat');
    sysInd = any(
    diaInd = 
    systolic = systolic(isempty(systolic(:).IM));
    mergedSys = [mergedSys; systolic];
    mergedDia = [mergedDia; diastolic];
end


save(savePath, 'mergedSys', 'mergedDia')