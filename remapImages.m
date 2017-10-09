remapAllImages

% load folder
loadPathName = uigetdir(loadPathName,['Select a folder with .mat files'...
    ' containing images and epi/endo-cardial contours']);

if isequal(loadPathName,0)
    failed('No folder chosen. Aborted.');
    return;
end

filesInDir = dir([loadPathName filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');


    
[~, savePath] = uiputfolder('*.mat', ...
    'Select .mat file to save to, or create a new one');

h = waitbarstart
for iFile
    
    