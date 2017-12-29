% Network directories.
dirs = cell(3,2);
dirs{1,1} = 'systolic';
dirs{1,2} = '\\147.220.31.56\guests\MattisNilsson\LV_Dataset\images\cartesian\sys\';
dirs{2,1} = 'diastolic';
dirs{2,2} = '\\147.220.31.56\guests\MattisNilsson\LV_Dataset\images\cartesian\dia\';
dirs{3,1} = 'merged';
dirs{3,2} = '\\147.220.31.56\guests\MattisNilsson\LV_Dataset\images\cartesian\merged\';

% Choices
savePath = uigetdir('*.mat', 'Choose a path to save the networks into.');
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

for i = 1:3
    dirName = dirs{i,1};
    dataDir = dirs{i,2};
    imDir = fullfile(dataDir, 'images');
    labelDir = fullfile(dataDir,'labels');
    saveSetPath = fullfile(savePath, dirName);
    mkdir(saveSetPath);
    
    % Create data stores.
    imds = imageDatastore(imDir);
    pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);
    
    % Partition data.
    [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds,pxds);
    % [imdsTrain, imdsTest, ...
    %     pxdsTrain, pxdsTest, ...
    %     imdsValid, pxdsValid] = partitionData3(imds,pxds);
    
    numTrainingImages = numel(imdsTrain.Files);
    numTestingImages = numel(imdsTest.Files);
    
    if exist('imdsValid', 'var') == 1
        numValidationImages = numel(imdsValid.Files);
        validIm = readall(imdsValid);
        validLabel = readall(pxdsValid);
        validationData = cell(1,2);
        validationData{1} = cat(4, validIm{:});
        validationData{2} = cat(4, validLabel{:});
    end
    
    % Create the SegNet network.
    lgraph = segnetLayers(imSize, numClasses , 5);
    
    % Calculate class weights.
    tbl = countEachLabel(pxds);
    imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
    classWeights = median(imageFreq) ./ imageFreq;
    
    % Specify the class weights using a |pixelClassificationLayer|.
    % Update the SegNet network with the new pixelClassificationLayer
    pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tbl.Name, ...
        'ClassWeights', classWeights);
    lgraph = removeLayers(lgraph, 'pixelLabels');
    lgraph = addLayers(lgraph, pxLayer);
    lgraph = connectLayers(lgraph, 'softmax' ,'labels');
    
    
    % Training options.
    verboseFreq = round(numTrainingImages/miniBatchSize);
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
    
    % Augmentation options.
    augmenter = imageDataAugmenter(...
        'RandXTranslation', [-5 5], ...
        'RandYTranslation',[-5 5]);
    %         'RandXScale', [0.05 0.1], ...
    %         'RandYScale', [0.05 0.1]);
    
    % Generate augmented training set.
    trainSource = pixelLabelImageSource(imdsTrain, pxdsTrain, ...
        'DataAugmentation', augmenter);
    
    save(fullfile(saveSetPath, 'workspace_pretraining.mat'));
        
    fprintf('Training SegNet on the %s dataset.\n', dirName);
    [net, info] = trainNetwork(trainSource, lgraph, options);
    save(fullfile(saveSetPath, 'workspace.mat'));
end







function visualiseClasses(tbl)
% Show classes.
frequency = tbl.PixelCount/sum(tbl.PixelCount);

figure
bar(1:numClasses,frequency)
xticks(1:numClasses)
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')
end

function [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds, pxds)
% Partition CamVid data by randomly selecting 80% of the data for training. The
% rest is used for testing.

% Set initial random state for example reproducibility.
rng(0);
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 80% of the images for training.
nTest = round(0.20 * numFiles);
trainingIdx = shuffledIndices(1:nTest);

% Use the rest for testing.
testIdx = shuffledIndices(nTest+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = [255 0];

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
testLabels = pxds.Files(testIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
end

function [imdsTrain, imdsTest, pxdsTrain, pxdsTest, imdsValid, pxdsValid] ...
    = partitionData3(imds, pxds)
% Randomly partition datastore into training, testing and validation sets.

% Set initial random state for example reproducibility.
rng(0);
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 80% of the images for training.
nTest = round(0.70 * numFiles);
nVal = round(0.85 * numFiles);

trainingIdx = shuffledIndices(1:nTest);
testIdx = shuffledIndices(nTest+1:nVal);
valIdx = shuffledIndices(nVal+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
validImages = imds.Files(valIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);
imdsValid = imageDatastore(validImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = [255 0];

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
testLabels = pxds.Files(testIdx);
validLabels = pxds.Files(valIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
pxdsValid = pixelLabelDatastore(validLabels, classes, labelIDs);
end