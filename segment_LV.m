loadPath = uigetdir(pwd, 'Select a folder of images to segment.');

filesInDir = dir([loadPath filesep '*.png']);
fileNames = extractfield(filesInDir, 'name');
nImages = length(fileNames);

h = waitbar(0,'');

for iImage = 1:nImages
    data = load([loadPath filesep fileNames{iFile}],'-png');
    
    
end