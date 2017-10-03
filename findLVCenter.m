function [centerX, centerY] = findLVCenter(EndoContour)

if EndoContour(1) ~= EndoContour(end)
        warning('Segmentation not closed, centerpoint will be false');
end

centerX = mean(EndoContour(:,1));
centerY = mean(EndoContour(:,2));