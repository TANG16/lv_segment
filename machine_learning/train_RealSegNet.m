% load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\merged\merged_workspace.mat')
% load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\small_trainset\merged\merged_workspace.mat')
%%
% Choices
saveSetPath = '\\147.220.31.56\guests\MattisNilsson\networks\RealSegNet\small_trainset\';
mkdir(fullfile(saveSetPath, 'checkpoints'));
ifPlot = 0;
verbose = 1;
miniBatchSize = 12;
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
% lgraph = segnetLayers(imSize, numClasses , 5); % SegIshNet

% Real SegNet.
lgraph = segnetLayers([128 128 1], 2 , 5, ...
    'NumConvolutionLayers', [2 2 3 3 3], ...
    'NumOutputChannels', [64 128 256 512 512], ...
    'FilterSize', 3);

% Specify the class weights using a |pixelClassificationLayer|.
% Update the SegNet network with the new pixelClassificationLayer
pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tblSys.Name, ...
    'ClassWeights', classWeights);
lgraph = removeLayers(lgraph, 'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph, 'softmax' ,'labels');

% Training options.
verboseFreq = floor(numTrainingImages/miniBatchSize/10);
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
    'CheckpointPath', fullfile(saveSetPath, 'checkpoints'));

augmenter = imageDataAugmenter(...
    'RandXTranslation', [-5 5], ...
    'RandYTranslation',[-5 5]);

trainSource = pixelLabelImageSource(imdsTrain, pxdsTrain, ...
    'DataAugmentation', augmenter);

save(fullfile(saveSetPath, 'workspace_pretraining.mat'));

fprintf('Training SegNet on the merged dataset.\n');
[net, info] = trainNetwork(trainSource, lgraph, options);
save(fullfile(saveSetPath, 'workspace.mat'));