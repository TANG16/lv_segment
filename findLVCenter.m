function [centerX, centerY] = findLVCenter(Endo)
% Function to calculate the center of the left ventricle given an
% endocardial contour.

centerX = mean(Endo(:,1));
centerY = mean(Endo(:,2));