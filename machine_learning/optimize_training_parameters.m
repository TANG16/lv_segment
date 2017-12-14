% Bayesian optimization of SegNet training parameters based on the Trainset
% dataset.

% Choices
savePath = uigetdir('*.mat', 'Choose a path to save the networks into.');
hrs = 12;

% Network directories.
mergedDir = '\\147.220.31.56\guests\MattisNilsson\LV_Trainset\images\cartesian\merged\';
sysDir = '\\147.220.31.56\guests\MattisNilsson\LV_Trainset\images\cartesian\sys\';
diaDir = '\\147.220.31.56\guests\MattisNilsson\LV_Trainset\images\cartesian\dia\';

dirs = [sysDir diaDir mergedDir];
dirNames = ['systolic' 'diastolic' 'merged'];


imSize = [128 128 1];
classNames = [
    "Myocardium"
    "Background"
    ];
labelIDs = [255 0];
numClasses = numel(classNames);
for i = 1
    dataDir = dirs(i);
    dirName = dirs(i);
    imDir = fullfile(dataDir, 'images');
    labelDir = fullfile(dataDir,'labels');
    
    % Create data stores.
    imds = imageDatastore(imDir);
    pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);
    
    % Partition data.
    [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionData(imds,pxds);
    numTrainingImages = numel(imdsTrain.Files);
    numTestingImages = numel(imdsTest.Files);
    
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
    
    optimVars = [
        optimizableVariable('InitialLearnRate',[1e-3 5e-2],'Transform','log')
        optimizableVariable('Momentum',[0.8 0.95])
        optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
    
    ObjFcn = makeObjFcn(imdsTrain, pxdsTrain, imdsValid, pxdsValid);
    
    BayesObject = bayesopt(ObjFcn, optimVars,...
        'MaxObj',30,...
        'MaxTime',hrs*60*60,...
        'IsObjectiveDeterministic',false,...
        'UseParallel',false);
end


function ObjFcn = makeObjFcn(imdsTrain, pxdsTrain, imdsValid, pxdsValid)
ObjFcn = @valErrorFun;

    function [valError,cons,fileName] = valErrorFun(optVars)
        imSize = [128 128 1];
        numClasses = numel(unique(trainLabels));
        layers = segnetLayers(imSize, numClasses, 5);
        
        miniBatchSize = 24;
        numValidationsPerEpoch = 1;
        validationFrequency = floor(size(trainImages,4)/miniBatchSize/numValidationsPerEpoch);
        options = trainingOptions('sgdm',...
            'InitialLearnRate',optVars.InitialLearnRate,...
            'Momentum',optVars.Momentum,...
            'MaxEpochs',100, ...
            'MiniBatchSize',miniBatchSize,...
            'L2Regularization',optVars.L2Regularization,...
            'Shuffle','every-epoch',...
            'Verbose',false,...
            'OutputFcn',@plotTrainingProgress,...
            'ValidationData',{valImages,valLabels},...
            'ValidationPatience',4,...
            'ValidationFrequency',validationFrequency);
        
        pixelRange = [-4 4];
        imageAugmenter = imageDataAugmenter(...
            'RandXTranslation',pixelRange,...
            'RandYTranslation',pixelRange);
        
        datasource = pixelLabelImageSource(imdsTrain,pxdsTrain,...
            'DataAugmentation',imageAugmenter);
        
        [trainedNet, netInfo] = trainNetwork(datasource,layers,options);
        close
        options = trainingOptions('sgdm',...
            'InitialLearnRate',optVars.InitialLearnRate/10,...
            'Momentum',optVars.Momentum,...
            'MaxEpochs',100, ...
            'MiniBatchSize',miniBatchSize,...
            'L2Regularization',optVars.L2Regularization,...
            'Shuffle','every-epoch',...
            'Verbose',false,...
            'OutputFcn',@plotTrainingProgress,...
            'ValidationData',{valImages,valLabels},...
            'ValidationPatience',4,...
            'ValidationFrequency',validationFrequency);
        trainedNet = trainNetwork(datasource, trainedNet.Layers,options);
        close
        
        predictedLabels = classify(trainedNet,valImages);
        valAccuracy = mean(predictedLabels == valLabels);
        valError = 1 - valAccuracy;
        
        fileName = num2str(valError,10) + ".mat";
        save(fileName,'trainedNet', 'netInfo', 'valError','options')
        cons = [];
        
    end
end
