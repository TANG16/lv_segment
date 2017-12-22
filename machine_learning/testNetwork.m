for iImage = 1:numTestingImages
    I = readimage(imdsTest, iImage);
    figure(1)
    imshow(I)
    hold on
    
    expected = readimage(pxdsTest, iImage);
    expected = (expected == "Myocardium");
    contours = bwboundaries(expected);
    if length(contours) > 2
        % Extract the correct contours, number 2 and 3 of the largest
        % contours (largest is around the image).
        lengths = cellfun(@length,contours);
        [~, idx] = sort(lengths, 'descend');
        contour = cell(1,2);
        contour{1} = contours{idx(2)};
        contour{2} = contours{idx(3)};
    else
        contour = contours;
    end
    plot(contour{1}(:,2), contour{1}(:,1), 'g-')
    plot(contour{2}(:,2), contour{2}(:,1), 'g-')
    
    C = semanticseg(I, net);
    C = (C == "Myocardium");
    contours = bwboundaries(C);
    if length(contours) > 2
        % Extract the correct contours, number 2 and 3 of the largest
        % contours (largest is around the image).
        lengths = cellfun(@length,contours);
        [~, idx] = sort(lengths, 'descend');
        contour = cell(1,2);
        contour{1} = contours{idx(2)};
        contour{2} = contours{idx(3)};
    else
        contour = contours;
    end
    
%     B = labeloverlay(I, C, 'IncludedLabels', "Myocardium", ...
%         'Transparency',0.9, 'Colormap', [0, 0.5, 0; 1, 1, 1]);
    
    plot(contour{1}(:,2), contour{1}(:,1), 'r-')
    plot(contour{2}(:,2), contour{2}(:,1), 'r-')
    hold off
    pause()
end

%%

for iImage = 1:numTestingImages
    % I = read(
    figure;
    expected = read(pxdsTest);
    jacc = jaccard(C, expected);
    dic = dice(C, expected);
    table(classNames, jacc, dice)
end
%%
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
%%
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.NormalizedConfusionMatrix