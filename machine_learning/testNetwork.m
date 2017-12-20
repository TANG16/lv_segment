%%
I = read(imdsTest);
C = semanticseg(I, net);

for iImage = 1:numTestingImages
    I = readimage(imdsTrain, iImage);
    C = semanticseg(I, net);
    B = labeloverlay(I, C, 'IncludedLabels', "Myocardium", ...
        'Transparency',0.9, 'Colormap', [0, 0.5, 0; 1, 1, 1]);
    figure(1)
    imshow(B)
    
    expectedResult = read(pxdsTrain);
    expected = uint8(expectedResult);
    actual = uint8(C);
    figure(2)
    imshowpair(actual, expected)
    
    
    pause()
end
% pixelLabelColorbar(cmap, classes);
%%

for iImage = 1:numTestingImages
% I = read(
figure;
expectedResult = read(pxdsTest);
jacc = jaccard(C, expectedResult);
dic = dice(C, expectedResult);
table(classNames, jacc, dice)
end
%%
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
%%
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.NormalizedConfusionMatrix