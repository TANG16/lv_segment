uiopen('load');
nPat = size(systolic,2);
figure(1)

for iPat = 1:nPat
    
    sys = systolic(iPat);
    for iSlice = 1:size(sys.IM,3)
        drawLV(sys.IM(:,:,iSlice), ...
            sys.Endo(:,:,iSlice), sys.Epi(:,:,iSlice),  ...
            sys.Center(1,iSlice), sys.Center(2,iSlice), ...
            ['Systolic phase, slice ' num2str(iSlice)]);
        pause(0.1);
    end
end

nPat = size(diastolic,2);
for iPat = 1:nPat
    
    dia = diastolic(iPat);
    for iSlice = 1:size(dia.IM,3)
        drawLV(dia.IM(:,:,iSlice), ...
            dia.Endo(:,:,iSlice), dia.Epi(:,:,iSlice),  ...
            dia.Center(1,iSlice), dia.Center(2,iSlice), ...
            ['Diastolic phase, slice ' num2str(iSlice)]);
        pause(0.1);
    end
end