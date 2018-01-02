classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];

imgDir = uigetdir(pwd, 'Provide a folder with checkpoints.');
labelDir = uigetdir(pwd, 'Provide a folder with checkpoints.');

imds = imageDatastore(imgDir);
pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);

loadPath = uigetdir(pwd, 'Provide a folder with checkpoints.');
filesInDir = dir([loadPath filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

% Load imdsTest and pxdsTest

options = trainingOptions('sgdm', ...
    'Momentum', 0, ...
    'InitialLearnRate', 1e-100, ...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', 1, ...
    'Verbose', 0);

h = waitbar(0,'Please wait...');

accScores = zeros(1,nFiles);
jaccScores = zeros(1,nFiles);
bfScores = zeros(1,nFiles);

scores = struct(1,nFiles);

for iFile = 1:nFiles
    load([loadPath filesep fileNames{iFile}],'-mat');
    
    trainSource = pixelLabelImageSource(imds, pxds);
    
    [net, ~] = trainNetwork(trainSource, net, options);
    
    pxdsResults = semanticseg(imdsTest, net, 'WriteLocation', tempdir, ...
        'Verbose',false);
    metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTest, ...
        'Verbose', false);
    
    %       accScores(iFile) = metrics.
    %       jaccScores(iFile) = metrics.
    %       bfScores(iFile) = metrics.
    scores(iFile) = metrics;
    
    waitbar(iFile/nFiles);
end

save('systolicScores.mat', 'accuracy', 'jaccard', 'bfScore');