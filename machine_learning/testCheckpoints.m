% load('\\147.220.31.56\guests\MattisNilsson\LV_Dataset\datastores.mat');
%%
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];

% imgDir = uigetdir(pwd, 'Provide a folder with checkpoints.');

imgDir = '\\147.220.31.56\guests\MattisNilsson\LV_Dataset\images\finish_training\im\';
labelDir = '\\147.220.31.56\guests\MattisNilsson\LV_Dataset\images\finish_training\label\';

imdsSmall = imageDatastore(imgDir);
pxdsSmall = pixelLabelDatastore(labelDir, classNames, labelIDs);
trainSource = pixelLabelImageSource(imdsSmall, pxdsSmall);
trainSource = pixelLabelImageSource(imds, pxds);

loadPath = uigetdir(pwd, 'Provide a folder with checkpoints.');
filesInDir = dir([loadPath filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');
nFiles = length(fileNames);

options = trainingOptions('sgdm', ...
    'Momentum', 0.1, ...
    'InitialLearnRate', 1e-12, ...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', 1, ...
    'Verbose', 0);

options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-12, ...
    'LearnRateSchedule', 'piecewise',...
    'LearnRateDropFactor', 0.1,...
    'LearnRateDropPeriod', 50,...
    'L2Regularization', 0.0005, ...
    'Momentum', 0.9, ...
    'MaxEpochs', 1, ...
    'MiniBatchSize', 1, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', 0, ...
    'VerboseFrequency', 100);

h = waitbar(0,'Please wait...');

accScores = zeros(1,nFiles);
jaccScores = zeros(1,nFiles);
bfScores = zeros(1,nFiles);

for iFile = 1:nFiles
    load([loadPath filesep fileNames{iFile}],'-mat');
    
    [deployedNet, ~] = trainNetwork(trainSource, net.Layers, options);
    
    pxdsResults = semanticseg(imdsTest, deployedNet, 'WriteLocation', tempdir, ...
        'Verbose',false);
    metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTest, ...
        'Verbose', false);
    
    accScores(iFile) = metrics
    jaccScores(iFile) = metrics
    bfScores(iFile) = metrics
    
    waitbar(iFile/nFiles);
end

save('systolicScores.mat', 'accuracy', 'jaccard', 'bfScore');