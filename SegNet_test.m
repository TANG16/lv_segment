dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\systolic\polar';
% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\diastolic\polar';
% dataDir = 'C:\Users\Mattis\Documents\MATLAB\exjobb\data\Trainset\merged\polar';

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
[imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds,pxds);
numTrainingImages = numel(imdsTrain.Files)
numTestingImages = numel(imdsTest.Files)

% Create the network.
lgraph = segnetLayers(imSize, numClasses , 5);
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
options = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 1e-3, ...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', 100, ...  
    'MiniBatchSize', 4, ...
    'Shuffle', 'every-epoch', ...
    'VerboseFrequency', 2);

% Data augmentation
augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation', [-10 10], 'RandYTranslation',[-10 10]);
datasource = pixelLabelImageSource(imdsTrain,pxdsTrain, ...
   'DataAugmentation',augmenter);

[net, info] = trainNetwork(datasource, lgraph, options);

%%
I = read(imdsTest);
C = semanticseg(I, net);

for iImage = 1:numTestingImages
    I = readimage(imdsTest, iImage);
    C = semanticseg(I, net);
    B = labeloverlay(I, C,'Transparency',0.4);
    figure(1)
    imshow(B)
    pause(0.5)
end
% pixelLabelColorbar(cmap, classes);
%%
figure;
expectedResult = read(pxdsTest);
actual = uint8(C);
expected = uint8(expectedResult);
imshowpair(actual, expected)

iou = jaccard(C, expectedResult);
table(classNames,iou)

pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
metrics.DataSetMetrics
metrics.ClassMetrics

%%
function [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds,pxds)
% Partition CamVid data by randomly selecting 60% of the data for training. The
% rest is used for testing.
    
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 60% of the images for training.
N = round(0.60 * numFiles);
trainingIdx = shuffledIndices(1:N);

% Use the rest for testing.
testIdx = shuffledIndices(N+1:end);

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