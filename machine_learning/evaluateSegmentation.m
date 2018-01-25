%% Systolic

load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\systolic\systolic_workspace.mat')

pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
sysMetrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

%% Diastolic
load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\diastolic\diastolic_workspace.mat')

pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
diaMetrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

%% Merged
load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\200_epoch\merged\workspace.mat')
% load('\\147.220.31.56\guests\MattisNilsson\networks\SegNet\small_trainset\merged\workspace.mat')
%%
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
mergedFullMetrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

pxdsResults = semanticseg(sysImdsTest,net,'WriteLocation',tempdir,'Verbose',false);
mergedSysMetrics = evaluateSemanticSegmentation(pxdsResults,sysPxdsTest,'Verbose',false);

pxdsResults = semanticseg(diaImdsTest,net,'WriteLocation',tempdir,'Verbose',false);
mergedDiaMetrics = evaluateSemanticSegmentation(pxdsResults,diaPxdsTest,'Verbose',false);

%%
pxdsResults = semanticseg(imdsTest,net,'WriteLocation',tempdir,'Verbose',false);
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
%%
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.NormalizedConfusionMatrix