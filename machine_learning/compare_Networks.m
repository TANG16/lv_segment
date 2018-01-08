
sysBF = table2array(sysMetrics.ImageMetrics(:,5)); 
mergedBF = table2array(mergedSysMetrics.ImageMetrics(:,5));

wins = sum(mergedBF > sysBF);
winRatio = wins/length(sysBF);
fprintf('Merged SegIshNet has a %d winrate over systolic SegIshNet\n', winRatio);

%%
diaBF = table2array(diaMetrics.ImageMetrics(:,5)); 
mergedBF = table2array(mergedDiaMetrics.ImageMetrics(:,5));

wins = sum(mergedBF > diaBF);
winRatio = wins/length(diaBF);
fprintf('Merged SegIshNet has a %d winrate over diastolic SegIshNet\n', winRatio);
%%

SegSysBF = table2array(mergedSysMetrics.ImageMetrics(:,5)); 
SegDiaBF = table2array(mergedDiaMetrics.ImageMetrics(:,5));
SegFullBF = table2array(mergedFullMetrics.ImageMetrics(:,5));

SegIshSysBF = table2array(SegIshSysMetrics.ImageMetrics(:,5));
SegIshDiaBF = table2array(SegIshDiaMetrics.ImageMetrics(:,5));
SegIshFullBF = table2array(SegIshFullMetrics.ImageMetrics(:,5));

wins = sum(SegSysBF >= SegIshSysBF);
winRatio = wins/length(SegSysBF)
fprintf('Systolic: \n Segnet has a %d winrate over SegIshNet \n', winRatio);

wins = sum(SegDiaBF >= SegIshDiaBF);
winRatio = wins/length(SegDiaBF)
fprintf('Diastolic: \n Segnet has a %d winrate over SegIshNet \n', winRatio);

wins = sum(SegFullBF >= SegIshFullBF);
winRatio = wins/length(SegFullBF)
fprintf('Full: \n Segnet has a %d winrate over SegIshNet \n', winRatio);


%%

SegSysBF = table2array(SegSysMetrics.ImageMetrics(:,5)); 
SegDiaBF = table2array(SegDiaMetrics.ImageMetrics(:,5));
SegFullBF = table2array(SegFullMetrics.ImageMetrics(:,5));

SegIshSysBF = table2array(mergedSysMetrics.ImageMetrics(:,5));
SegIshDiaBF = table2array(mergedDiaMetrics.ImageMetrics(:,5));
SegIshFullBF = table2array(mergedFullMetrics.ImageMetrics(:,5));

wins = sum(SegSysBF >= SegIshSysBF);
winRatio = wins/length(SegSysBF)
fprintf('Systolic: \n Segnet has a %d winrate over SegIshNet \n', winRatio);

wins = sum(SegDiaBF >= SegIshDiaBF);
winRatio = wins/length(SegDiaBF)
fprintf('Diastolic: \n Segnet has a %d winrate over SegIshNet \n', winRatio);

wins = sum(SegFullBF >= SegIshFullBF);
winRatio = wins/length(SegFullBF)
fprintf('Full: \n Segnet has a %d winrate over SegIshNet \n', winRatio);



