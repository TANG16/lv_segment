%% Large SegIshNet
clear all
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\SegIshNet_metrics.mat')
%% Draw mean lines for all.
epochs = 200;
figure;

loss = mergedInfo.TrainingLoss;
nMer = length(loss);
nMerEp = nMer/epochs;
meanMerLoss = arrayfun(@(i) mean(loss(i:i+nMerEp-1)),1:nMerEp:length(loss)-nMerEp+1);
plot(1:nMer,loss, 'Color', [0 0.6 1])
hold on
grid on

loss = diaInfo.TrainingLoss;
nDia = length(loss);
nDiaEp = nDia/epochs;
meanDiaLoss = arrayfun(@(i) mean(loss(i:i+nDiaEp-1)),1:nDiaEp:length(loss)-nDiaEp+1);
plot(1:nDia,loss, 'Color', [0 1 1])

loss = sysInfo.TrainingLoss;
nSys = length(loss);
nSysEp = nSys/epochs;
meanSysLoss = arrayfun(@(i) mean(loss(i:i+nSysEp-1)),1:nSysEp:length(loss)-nSysEp+1);
plot(1:nSys,loss, 'Color', [0.8 1 1])

% Plot mean lines.
plot(nMerEp:nMerEp:nMer,meanMerLoss, 'Color', [1 0.4 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
plot(nDiaEp:nDiaEp:nDia,meanDiaLoss, 'Color', [1 0.3 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
plot(nSysEp:nSysEp:nSys,meanSysLoss, 'Color', [1 0.2 0], 'LineStyle', '-')%, 'LineWidth', 1.5)

legend('Merged', 'Systolic', 'Diastolic', 'Mean Epoch Loss')
xlabel('Iterations')
ylabel('Loss')
hold off

%% Small SegIshNet
clear all
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\SegIshNet_small_metrics.mat')
%%
epochs = 200;
figure;

loss = mergedInfo.TrainingLoss;
nMer = length(loss);
nMerEp = nMer/epochs;
meanMerLoss = arrayfun(@(i) mean(loss(i:i+nMerEp-1)),1:nMerEp:length(loss)-nMerEp+1);
plot(1:nMer,loss, 'Color', [0 0.6 1])
hold on
grid on

loss = diaInfo.TrainingLoss;
nDia = length(loss);
nDiaEp = nDia/epochs;
meanDiaLoss = arrayfun(@(i) mean(loss(i:i+nDiaEp-1)),1:nDiaEp:length(loss)-nDiaEp+1);
plot(1:nDia,loss, 'Color', [0 1 1])

loss = sysInfo.TrainingLoss;
nSys = length(loss);
nSysEp = nSys/epochs;
meanSysLoss = arrayfun(@(i) mean(loss(i:i+nSysEp-1)),1:nSysEp:length(loss)-nSysEp+1);
plot(1:nSys,loss, 'Color', [0.8 1 1])

% Plot mean lines.
plot(nMerEp:nMerEp:nMer,meanMerLoss, 'Color', [1 0.4 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
plot(nDiaEp:nDiaEp:nDia,meanDiaLoss, 'Color', [1 0.3 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
plot(nSysEp:nSysEp:nSys,meanSysLoss, 'Color', [1 0.2 0], 'LineStyle', '-')%, 'LineWidth', 1.5)

% legend('Merged', 'Systolic', 'Diastolic')
legend('Merged', 'Systolic', 'Diastolic', 'Mean Epoch Loss')
xlabel('Iterations')
ylabel('Loss')
hold off

%% SegNet
clear all
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\SegNet_metrics.mat')
%%
epochs = 60;
figure;

loss = trainingInfo.TrainingLoss;
nMer = length(loss);
nMerEp = nMer/epochs;
meanMerLoss = arrayfun(@(i) mean(loss(i:i+nMerEp-1)),1:nMerEp:length(loss)-nMerEp+1);
plot(1:nMer,loss, 'Color', [0 0.6 1])
hold on
plot(nMerEp:nMerEp:nMer,meanMerLoss, 'Color', [1 0.7 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
legend('Iteration Loss', 'Mean Epoch Loss')
xlabel('Iterations')
ylabel('Loss')
hold off

%% Small SegNet
clear all
load('\\147.220.31.56\guests\MattisNilsson\trained_models_FINAL\SegNet_small_metrics.mat')
%%
epochs = 200;
figure;

loss = trainingInfo.TrainingLoss;
nMer = length(loss);
nMerEp = nMer/epochs;
meanMerLoss = arrayfun(@(i) mean(loss(i:i+nMerEp-1)),1:nMerEp:length(loss)-nMerEp+1);
plot(1:nMer,loss, 'Color', [0 0.6 1])
hold on
plot(nMerEp:nMerEp:nMer,meanMerLoss, 'Color', [1 0.7 0], 'LineStyle', '-')%, 'LineWidth', 1.5)
legend('Iteration Loss', 'Mean Epoch Loss')
xlabel('Iterations')
ylabel('Loss')
hold off

% Draw line at last loss
% ydata = mean(mergedY(end-(nx/200):end));
% line(get(gca,'Xlim'),[min(ydata) min(ydata)], 'Color', [1 0.75 0], 'LineWidth', 1.5)
