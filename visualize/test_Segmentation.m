%% Load Datasets
% load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\data_sets_large.mat')
% load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\data_sets_small.mat')

%% Load Networks
% load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\trained_networks.mat')


%% Visualize

% ---------- Choose dataset ----------
% imdsTestSet = sysImdsTest;
% pxdsTestSet = sysPxdsTest;

% imdsTestSet = diaImdsTest;
% pxdsTestSet = diaPxdsTest;

imdsTestSet = imdsTest;
pxdsTestSet = pxdsTest;

% Enable the extraction of only the endo- and epicardial contours.
doExtractContour = 1;
% Enable data shuffle.
doShuffleTestData = 0;
% Enable specific data.
doImportantData = 1;

importantSysIdx = [5 7 8 10 14 15 16 17 18 21 28 44 53 57 67 72 94 98 107 ...
    153 121 162 165 21 ]';
importantDiaIdx = [10 54 19 61 25 63 26 30 39 82 106 95]';
importantFullIdx = [673 743 390 367 289 698 686 367 451 59 382 736 520 261 753 116 358]';
importantIdx = [importantFullIdx; importantDiaIdx; importantSysIdx + 765];

realImportantIdx = [736 818 753 390 686 10 59 261 837 116 82 781];
if doImportantData
    %     nImages = length(importantIdx);
    nImages = length(realImportantIdx);
else
    nImages = numel(imdsTestSet.Files);
end

randImages = randperm(nImages); % Shuffled indices.

% Initialize figures.
f1 = figure('Name', 'SysSegIshNet');
f2 = figure('Name', 'DiaSegIshNet');
f3 = figure('Name', 'MerSegIshNet');
f4 = figure('Name', 'SegNet');

for iiImage = 1:nImages
    if doShuffleTestData
        iImage = randImages(iiImage);
    else
        iImage = iiImage;
    end
    if doImportantData
        %         iImage = importantIdx(iImage);
        iImage = realImportantIdx(iImage)
    end
    im = readimage(imdsTestSet, iImage);
    truth = readimage(pxdsTestSet, iImage);
    
    %     figure('Name', ['SysSegIshNet on ' num2str(iImage)]);
    %     figure('Name', 'SysSegIshNet');
    figure(f1);
    segment_LV(SysSegIshNet, im, truth, ...
        ['SysSegIshNet on nr ' num2str(iImage)], ...
        doExtractContour);
    
    %     figure('Name', ['DiaSegIshNet on ' num2str(iImage)]);
    %     figure('Name', 'DiaSegIshNet');
    figure(f2);
    segment_LV(DiaSegIshNet, im, truth, ...
        ['DiaSegIshNet on nr ' num2str(iImage)], ...
        doExtractContour);
    
    %     figure('Name', ['MerSegIshNet on ' num2str(iImage)]);
    %     figure('Name', 'MerSegIshNet');
    figure(f3);
    segment_LV(MergedSegIshNet, im, truth, ...
        ['MerSegIshNet on nr ' num2str(iImage)], ...
        doExtractContour);
    
    %     figure('Name', ['SegNet on ' num2str(iImage)]);
    %     figure('Name', 'SegNet');
    figure(f4);
    segment_LV(SegNet, im, truth, ...
        ['SegNet on nr ' num2str(iImage)], ...
        doExtractContour);
    %     figure(4);
    %     segment_LV(SmallSegNet, im, truth, ...
    %         ['SegNet segmentation on imNbr ' num2str(iImage)], ...
    %         doExtractContour);
    
    %     figure(5);
    %     segment_LV(SmallMergedSegIshNet, im, truth, ...
    %         ['Merged SegIshNet segmentation on imNbr ' num2str(iImage)], ...
    %         doExtractContour);
    %
    %     figure(6);
    %     segment_LV(SmallDiaSegIshNet, im, truth, ...
    %         ['SysSegIshNet segmentation on imNbr ' num2str(iImage)], ...
    %         doExtractContour);
    pause()
end

%-----------------------------------
function segment_LV(net, im, truth, titleStr, doExtractContour)
%-----------------------------------
% Performs segmentation on the input image im using the network net, then
% draws the segmentation contours (red) and the ground truth contours
% (green) on the image.

% Use perimeter for the segmentation
doPerim = 0;

% Perform segmentation
seg = semanticseg(im, net);
%B = labeloverlay(im, seg, 'IncludedLabels', "Myocardium", ...
%    'Transparency',0.8, 'Colormap', [0, 0, 1; 1, 1, 1]);
imshow(im, 'InitialMag', 'fit')
hold on

% Extract segmentation contours.
truth = (truth == "Myocardium");
truthContours = bwboundaries(truth);
seg = (seg == "Myocardium");
segContours = bwboundaries(seg);

% Extract desired contours.
if doExtractContour
    % -------- Truth Contours --------
    % Remove small contours.
    contourLengths = cellfun(@length, truthContours);
    truthContours = truthContours(contourLengths > 20);
    
    % Remove contours.
    if length(truthContours) > 2
        contourLengths = cellfun(@length, truthContours);
        % Sort the contours by size.
        [~, idx] = sort(contourLengths, 'descend');
        % Expect the largest one to be around the whole image.
        truthContours = truthContours(idx(2:3));
    end
    
    % -------- Segmentation Contours --------
    % Remove small contours.
    contourLengths = cellfun(@length,segContours);
    segContours = segContours(contourLengths > 20);
    
    % Remove rest of the contours.
    if length(segContours) > 2
        contourLengths = cellfun(@length, segContours);
        % Sort the contours by size.
        [~, idx] = sort(contourLengths, 'descend');
        % Expect the largest one to be around the whole image.
        segContours = segContours(idx(2:3));
    end
end

if doPerim
    % Extract mask perimeters
    segPerim = bwperim(seg);
    truthPerim = bwperim(truth);
    
    % Transparency value;    alpha = 0.6;
    
    % Make truecolor images.
    green = cat(3, zeros(size(truthPerim)), alpha*ones(size(truthPerim)), ...
        zeros(size(truthPerim)));
    red = cat(3, alpha*ones(size(segPerim)), zeros(size(segPerim)), ...
        zeros(size(segPerim)));
    
    % Draw the coloured masks on the image.
    h = imshow(green);
    set(h, 'AlphaData', truthPerim)
    h = imshow(red);
    set(h, 'AlphaData', segPerim)
else
    % Plot contours.
    for iContour = 1:length(truthContours)
        p = plot(truthContours{iContour}(:,2), truthContours{iContour}(:,1), 'g-');
        p.Color(4) = 0.3;
        p.LineWidth = 2;
    end
    
    for iContour = 1:length(segContours)
        p = plot(segContours{iContour}(:,2), segContours{iContour}(:,1), 'r-');
        p.Color(4) = 0.3;
        p.LineWidth = 1.5;
    end
end
hold off

% Calculate evaluation scores.
bf = bfscore(seg, truth, 2);
jacc = jaccard(seg,truth);

% title([titleStr ', BF ' num2str(bf) ', jaccard ' num2str(jacc)])
fprintf([titleStr ' yielded BF of ' num2str(bf) '\n']);
fprintf([titleStr ' yielded jaccard of ' num2str(jacc) '\n \n']);
drawnow;
end