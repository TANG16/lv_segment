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
%%
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
metrics.DataSetMetrics
metrics.ClassMetrics
