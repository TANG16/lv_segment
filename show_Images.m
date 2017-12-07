

% dataDir = uigetdir(pwd, 'Select a directory with images');
% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\createmask\systolic\polar';
dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\createmask\diastolic\polar';

imDir = fullfile(dataDir, 'images');
labelDir = fullfile(dataDir,'labels');

imFiles = dir([imDir filesep '*.png']);
labelFiles = dir([labelDir filesep '*.png']);

fileNames = extractfield(imFiles, 'name');
nFiles = length(fileNames);

% Name classes.
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];

imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);
nImages = numel(imds.Files);

h = figure(1);
set(h, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

for iImage = 1:nImages
    
    im = readimage(imds, iImage);
    label = readimage(pxds, iImage);
    B = labeloverlay(im,label);
    
    [~,name,~] = fileparts(imds.Files{iImage});
%     set(h, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    h = imshow(B);

%     pixelLabelColorbar(classNames);
    drawnow;
    title(name)
    pause(0.2);
end