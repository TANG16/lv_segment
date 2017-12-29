load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\systolic\systolic_workspace.mat')
sysImdsTrain = imdsTrain;
sysImdsTest = imdsTest;
sysPxdsTrain = pxdsTrain;
sysPxdsTest = pxdsTest;

tblSys = countEachLabel(pxds);

load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\diastolic\diastolic_workspace.mat')

diaImdsTrain = imdsTrain;
diaImdsTest = imdsTest;
diaPxdsTrain = pxdsTrain;
diaPxdsTest = pxdsTest;

tblDia = countEachLabel(pxds);

% Create combined datastores.
imdsTrain = imageDatastore([diaImdsTrain.Files; sysImdsTrain.Files]);
pxdsTrain = pixelLabelDatastore([diaPxdsTrain.Files; sysPxdsTrain.Files], ...
    classNames, labelIDs);

imdsTest.Files = [diaImdsTest.Files; sysImdsTest.Files];
pxdsTest.Files = [diaPxdsTest.Files; sysPxdsTest.Files];

% Count image frequency.
imageFreq = (tblSys.PixelCount + tblDia.Pixelcount)./ ...
    (tblSys.ImagePixelCount + tblDia.ImagePixelCount);

classWeights = median(imageFreq) ./ imageFreq;

numTrainingImages = numel(imdsTrain.Files);
numTestingImages = numel(imdsTest.Files);

% Choices
saveSetPath = '\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\merged_sameTestdata';
mkdir(saveSetPath);

ifPlot = 0;
verbose = 1;
miniBatchSize = 24;
maxEpochs = 200;
initLearnRate = 1e-2;
learnRateDropFactor = 0.1;
learnRateDropPeriod = 50;
L2reg = 0.0005;
momentum = 0.9;

if ifPlot == 1
    plotChoice = 'training-progress';
else
    plotChoice = 'none';
end

imSize = [128 128 1];
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];
numClasses = numel(classNames);

% Create the SegNet network.
lgraph = segnetLayers(imSize, numClasses , 5);

% Specify the class weights using a |pixelClassificationLayer|.
% Update the SegNet network with the new pixelClassificationLayer
pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tblSys.Name, ...
    'ClassWeights', classWeights);
lgraph = removeLayers(lgraph, 'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph, 'softmax' ,'labels');

% Training options.
verboseFreq = floor(numTrainingImages/miniBatchSize);
options = trainingOptions('sgdm', ...
    'InitialLearnRate', initLearnRate, ...
    'LearnRateSchedule', 'piecewise',...
    'LearnRateDropFactor', learnRateDropFactor,...
    'LearnRateDropPeriod', learnRateDropPeriod,...
    'L2Regularization', L2reg, ...
    'Momentum', momentum, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', verbose, ...
    'VerboseFrequency', verboseFreq, ...
    'Plots', plotChoice, ...
    'CheckpointPath', fullfile(savePath, dirName));

augmenter = imageDataAugmenter(...
    'RandXTranslation', [-5 5], ...
    'RandYTranslation',[-5 5]);

trainSource = pixelLabelImageSource(imdsTrain, pxdsTrain, ...
    'DataAugmentation', augmenter);

save(fullfile(saveSetPath, 'workspace_pretraining.mat'));

fprintf('Training SegNet on the %s dataset.\n', dirName);
[net, info] = trainNetwork(trainSource, lgraph, options);
save(fullfile(saveSetPath, 'workspace.mat'));

%%
clear all;
load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\small_trainset\systolic\workspace.mat')
sysImdsTrain = imdsTrain;
sysImdsTest = imdsTest;
sysPxdsTrain = pxdsTrain;
sysPxdsTest = pxdsTest;

tblSys = countEachLabel(pxds);

load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\small_trainset\diastolic\workspace.mat')

diaImdsTrain = imdsTrain;
diaImdsTest = imdsTest;
diaPxdsTrain = pxdsTrain;
diaPxdsTest = pxdsTest;

tblDia = countEachLabel(pxds);

% Create combined datastores.
imdsTrain = imageDatastore([diaImdsTrain.Files; sysImdsTrain.Files]);
pxdsTrain = pixelLabelDatastore([diaPxdsTrain.Files; sysPxdsTrain.Files], ...
    classNames, labelIDs);

imdsTest.Files = [diaImdsTest.Files; sysImdsTest.Files];
pxdsTest.Files = [diaPxdsTest.Files; sysPxdsTest.Files];

% Count image frequency.
imageFreq = (tblSys.PixelCount + tblDia.Pixelcount)./ ...
    (tblSys.ImagePixelCount + tblDia.ImagePixelCount);

classWeights = median(imageFreq) ./ imageFreq;

numTrainingImages = numel(imdsTrain.Files);
numTestingImages = numel(imdsTest.Files);

% Choices
saveSetPath = '\\147.220.31.56\guests\MattisNilsson\networks\SegNet\small_trainset\merged_sameTestdata';
mkdir(saveSetPath);

ifPlot = 0;
verbose = 1;
miniBatchSize = 24;
maxEpochs = 200;
initLearnRate = 1e-2;
learnRateDropFactor = 0.1;
learnRateDropPeriod = 50;
L2reg = 0.0005;
momentum = 0.9;

if ifPlot == 1
    plotChoice = 'training-progress';
else
    plotChoice = 'none';
end

imSize = [128 128 1];
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];
numClasses = numel(classNames);

% Create the SegNet network.
lgraph = segnetLayers(imSize, numClasses , 5);

% Specify the class weights using a |pixelClassificationLayer|.
% Update the SegNet network with the new pixelClassificationLayer
pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tblSys.Name, ...
    'ClassWeights', classWeights);
lgraph = removeLayers(lgraph, 'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph, 'softmax' ,'labels');

% Training options.
verboseFreq = floor(numTrainingImages/miniBatchSize);
options = trainingOptions('sgdm', ...
    'InitialLearnRate', initLearnRate, ...
    'LearnRateSchedule', 'piecewise',...
    'LearnRateDropFactor', learnRateDropFactor,...
    'LearnRateDropPeriod', learnRateDropPeriod,...
    'L2Regularization', L2reg, ...
    'Momentum', momentum, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', verbose, ...
    'VerboseFrequency', verboseFreq, ...
    'Plots', plotChoice, ...
    'CheckpointPath', fullfile(savePath, dirName));

augmenter = imageDataAugmenter(...
    'RandXTranslation', [-5 5], ...
    'RandYTranslation',[-5 5]);

trainSource = pixelLabelImageSource(imdsTrain, pxdsTrain, ...
    'DataAugmentation', augmenter);

save(fullfile(saveSetPath, 'workspace_pretraining.mat'));

fprintf('Training SegNet on the %s dataset.\n', dirName);
[net, info] = trainNetwork(trainSource, lgraph, options);
save(fullfile(saveSetPath, 'workspace.mat'));