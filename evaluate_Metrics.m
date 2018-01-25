% Load Networks
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\trained_networks.mat')

% ----------------- LARGE DATA SET -----------------
% Load large data sets.
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\data_sets_large.mat')

% Test on full test set.
SegNetMetrics.Full = evaluateSegmentation(imdsTest, pxdsTest, SegNet);
MergedSegIshNetMetrics.Full = evaluateSegmentation(imdsTest, pxdsTest, MergedSegIshNet);

% Test on Systolic test set.
SegNetMetrics.Sys = evaluateSegmentation(sysImdsTest, sysPxdsTest, SegNet);
MergedSegIshNetMetrics.Sys = evaluateSegmentation(sysImdsTest, sysPxdsTest, MergedSegIshNet);
SysSegIshNetMetrics = evaluateSegmentation(sysImdsTest, sysPxdsTest, SysSegIshNet);

% Test on Diastolic test set.
SegNetMetrics.Dia = evaluateSegmentation(diaImdsTest, diaPxdsTest, SegNet);
MergedSegIshNetMetrics.Dia = evaluateSegmentation(diaImdsTest, diaPxdsTest, MergedSegIshNet);
DiaSegIshNetMetrics = evaluateSegmentation(diaImdsTest, diaPxdsTest, DiaSegIshNet);

% --------------- SMALL DATA SET -----------------
% Load small data sets.
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\data_sets_small.mat')

% Test on full test set.
SmallSegNetMetrics.Full = evaluateSegmentation(imdsTest, pxdsTest, SmallSegNet);
SmallMergedSegIshNetMetrics.Full = evaluateSegmentation(imdsTest, pxdsTest, SmallMergedSegIshNet);

% Test on Systolic test set.
SmallSegNetMetrics.Sys = evaluateSegmentation(sysImdsTest, sysPxdsTest, SmallSegNet);
SmallMergedSegIshNetMetrics.Sys = evaluateSegmentation(sysImdsTest, sysPxdsTest, SmallMergedSegIshNet);
SmallSysSegIshNetMetrics = evaluateSegmentation(sysImdsTest, sysPxdsTest, SmallSysSegIshNet);

% Test on Diastolic test set.
SmallSegNetMetrics.Dia = evaluateSegmentation(diaImdsTest, diaPxdsTest, SmallSegNet);
SmallMergedSegIshNetMetrics.Dia = evaluateSegmentation(diaImdsTest, diaPxdsTest, SmallMergedSegIshNet);
SmallDiaSegIshNetMetrics = evaluateSegmentation(diaImdsTest, diaPxdsTest, SmallDiaSegIshNet);

% mean(MergedIshMetrics.Jaccard)
% mean(SegNetMetrics.Jaccard)

% mean(MergedIshMetrics.BFScore)
% mean(SegNetMetrics.BFScore)

%%

function metrics = evaluateSegmentation(imdsTestSet, pxdsTestSet, net)
nImages = numel(imdsTestSet.Files);

% Generate adjusted metrics.
bfScore = zeros(nImages, 1);
jacc = zeros(nImages, 1);

h = waitbar(0,'Evaluating network...');
for iImage = 1:nImages
    im = readimage(imdsTestSet, iImage);
    truth = readimage(pxdsTestSet, iImage);
    truth = (truth == "Myocardium");
    seg = semanticseg(im, net);
    seg = (seg == "Myocardium");

    jacc(iImage) = jaccard(seg, truth);
    bfScore(iImage) = bfscore(seg, truth, 2);
    h = waitbar(iImage/nImages,h);
end
close(h)
metrics.Jaccard = jacc;
metrics.BFScore = bfScore;
end