fprintf('-------Jaccard scores full')

mean(SegNetMetrics.Full.Jaccard)
median(SegNetMetrics.Full.Jaccard)
std(SegNetMetrics.Full.Jaccard)

mean(MergedSegIshNetMetrics.Full.Jaccard)
median(MergedSegIshNetMetrics.Full.Jaccard)
std(MergedSegIshNetMetrics.Full.Jaccard)

%%
fprintf('--------Jaccard scores Sys \n')

fprintf('SegNet \n')
mean(SegNetMetrics.Sys.Jaccard)
median(SegNetMetrics.Sys.Jaccard)

fprintf('Merged SegIshNet \n')
mean(MergedSegIshNetMetrics.Sys.Jaccard)
median(MergedSegIshNetMetrics.Sys.Jaccard)

fprintf('Systolic SegIshNet \n')
mean(SysSegIshNetMetrics.Jaccard)
median(SysSegIshNetMetrics.Jaccard)

%%
fprintf('--------Jaccard scores dia \n')
fprintf('SegNet \n')
mean(SegNetMetrics.Dia.Jaccard)
median(SegNetMetrics.Dia.Jaccard)

fprintf('Merged SegIshNet \n')
mean(MergedSegIshNetMetrics.Dia.Jaccard)
median(MergedSegIshNetMetrics.Dia.Jaccard)

fprintf('Diastolic SegIshNet \n')
mean(DiaSegIshNetMetrics.Jaccard)
median(DiaSegIshNetMetrics.Jaccard)


%% ---------- BF Scores ---------------

fprintf('-------BF scores full')

mean(SegNetMetrics.Full.BFScore)
median(SegNetMetrics.Full.BFScore)

mean(MergedSegIshNetMetrics.Full.BFScore)
median(MergedSegIshNetMetrics.Full.BFScore)

%%
fprintf('--------BF scores Sys \n')

fprintf('SegNet \n')
mean(SegNetMetrics.Sys.BFScore)
median(SegNetMetrics.Sys.BFScore)

fprintf('Merged SegIshNet \n')
mean(MergedSegIshNetMetrics.Sys.BFScore)
median(MergedSegIshNetMetrics.Sys.BFScore)

fprintf('Systolic SegIshNet \n')
mean(SysSegIshNetMetrics.BFScore)
median(SysSegIshNetMetrics.BFScore)

%%
fprintf('--------BF scores dia \n')
fprintf('SegNet \n')
mean(SegNetMetrics.Dia.BFScore)
median(SegNetMetrics.Dia.BFScore)

fprintf('Merged SegIshNet \n')
mean(MergedSegIshNetMetrics.Dia.BFScore)
median(MergedSegIshNetMetrics.Dia.BFScore)

fprintf('Diastolic SegIshNet \n')
mean(DiaSegIshNetMetrics.BFScore)
median(DiaSegIshNetMetrics.BFScore)


%% -------------- SMALL ----------------
fprintf('-------Jaccard scores full')
fprintf('SegNet')
mean(SmallSegNetMetrics.Full.Jaccard)
median(SmallSegNetMetrics.Full.Jaccard)

fprintf('SegIshNet')
mean(MergedSegIshNetMetrics.Full.Jaccard)
median(MergedSegIshNetMetrics.Full.Jaccard)



fprintf('-------BF scores full')

mean(SegNetMetrics.Full.BFScore)
median(SegNetMetrics.Full.BFScore)

mean(MergedSegIshNetMetrics.Full.BFScore)
median(MergedSegIshNetMetrics.Full.BFScore)





