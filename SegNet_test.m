% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\systolic\polar';
% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\diastolic\polar';
% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\merged\polar';

% Network directories.
% dataDir = '\\147.220.31.56\guests\MattisNilsson\data\data_sets_images\export\systolic\polar\midventricular\';
dataDir = '\\147.220.31.56\guests\MattisNilsson\data\images\diastolic\polar\midventricular\';

[saveFile savePath] = uigetfile('*.mat', 'Choose a file to save the network info to');

% diary('systolic_midvent_training.txt');
imDir = fullfile(dataDir, 'images');
labelDir = fullfile(dataDir,'labels');

imSize = [56 96 1];
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];
numClasses = numel(classNames);

% Create data stores.
imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);

% Count pixels.
tbl = countEachLabel(pxds)

% Show classes.
frequency = tbl.PixelCount/sum(tbl.PixelCount);
figure
bar(1:numClasses,frequency)
xticks(1:numClasses) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')

% Partition data.
% [imdsTrain, imdsTest, pxdsTrain, pxdsTest, imdsValid, pxdsValid] = partitionData(imds,pxds);

[imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds,pxds);
numTrainingImages = numel(imdsTrain.Files)
numTestingImages = numel(imdsTest.Files)

% Create the network.
lgraph = segnetLayers(imSize, numClasses , 5);
% importCaffeNetwork
figure
plot(lgraph)

% Calculate class weights.
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq

% Specify the class weights using a |pixelClassificationLayer|.
pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tbl.Name, 'ClassWeights', classWeights)

% Update the SegNet network with the new |pixelClassificationLayer| by
% removing the current |pixelClassificationLayer| and adding the new layer.
% The current |pixelClassificationLayer| is named 'pixelLabels'. Remove it 
% using |removeLayers|, add the new one using|addLayers|, and connect the 
% new layer to the rest of the network using |connectLayers|.
lgraph = removeLayers(lgraph, 'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph, 'softmax' ,'labels');

% Training options
% options = trainingOptions('sgdm', ...
%     'Momentum', 0.9, ...
%     'InitialLearnRate', 1e-3, ...
%     'L2Regularization', 0.0005, ...
%     'MaxEpochs', 40, ...
%     'MiniBatchSize', 4, ...
%     'Shuffle', 'every-epoch', ...
%     'VerboseFrequency', 10);

testSource = pixelLabelImageSource(imdsTest,pxdsTest);

options = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 1e-3, ...
    'L2Regularization', 0.0005, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.2,...
    'LearnRateDropPeriod',5,...
    'MaxEpochs', 200, ...
    'MiniBatchSize', 128, ...
    'Shuffle', 'every-epoch', ...
    'VerboseFrequency', 1, ...
    'Plots', 'training-progress');

%         'ValidationData', testSource, ...
%     'ValidationFrequency', 100, ...
% Data augmentation
augmenter = imageDataAugmenter('RandXTranslation', [-10 10], ...
    'RandYTranslation',[-10 10]);
datasource = pixelLabelImageSource(imdsTrain,pxdsTrain, ...
   'DataAugmentation',augmenter);

[net, info] = trainNetwork(datasource, lgraph, options);
save(fullfile(savePath, saveFile), 'net' ,'imdsTest', 'imdsTrain', 'pxdsTrain', 'pxdsTest');



% function [imdsTrain, imdsTest, pxdsTrain, pxdsTest, imdsValid, pxdsValid] ... 
function [imdsTrain, imdsTest, pxdsTrain, pxdsTest] ... 
    = partitionData(imds, pxds)
% Partition CamVid data by randomly selecting 60% of the data for training. The
% rest is used for testing.
    
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 80% of the images for training.
nTest = round(0.80 * numFiles);
% nVal = round(0.80 * numFiles);

trainingIdx = shuffledIndices(1:nTest);

% Use the rest for testing.
testIdx = shuffledIndices(nTest+1:end);
% valIdx = shuffledIndices(nVal:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
% validImages = imds.Files(valIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);
% imdsValid = imageDatastore(validImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = [255 0];

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
testLabels = pxds.Files(testIdx);
% validLabels = pxds.Files(valIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
% pxdsValid = pixelLabelDatastore(validLabels, classes, labelIDs);
end