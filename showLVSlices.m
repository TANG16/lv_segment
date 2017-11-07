function showLVSlices(imSet, phase)
% imSet is either systolic or diastolic phase, define by the string phase.

close 1
figure(1)
for iSlice = 1:size(imSet.IM,3)
    drawLV(imSet.IM(:,:,iSlice), ...
        imSet.Endo(:,:,iSlice), imSet.Epi(:,:,iSlice),  ...
        imSet.Center(1), imSet.Center(2), ...
        [phase ' phase, slice ' num2str(iSlice)]);
    pause;
end