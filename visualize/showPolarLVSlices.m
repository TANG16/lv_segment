function showPolarLVSlices(imSet, contour, phase)

close 1
figure(1)
for iSlice = 1:size(imSet.IM,3)
    drawPolarLV(imSet.IM(:,:,iSlice), ...
        imSet.Endo(:,:,iSlice), imSet.Epi(:,:,iSlice),  ...
        imSet.Center(1), imSet.Center(2), ...
        [phase ' phase, slice ' num2str(iSlice)]);
    pause;
end