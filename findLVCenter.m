function [centerX, centerY] = findLVCenter(EndoContour)
% Function to calculate the center of the left ventricle given an
% endocardial contour.

centerX = mean(EndoContour(:,1));
centerY = mean(EndoContour(:,2));