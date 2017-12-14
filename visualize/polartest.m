load('C:\Users\Mattis\Documents\MATLAB\lv_segment\data\extracted_data\LV_RV_Trainingset.mat')
imSet = systolic(1);

nAngle = 96;
nRadPoints = 56;

% Cropping radius from centerpoint.
radius = 25;

% Interpolation method.
interpolationMethod = 'nearest';

% Initiate polar representations.
nImages = size(imSet.IM,3);
polarIm = NaN(nRadPoints, nAngle);
polarContour = NaN(2, nAngle);

for iImage = 1:nImages
    % Clean mask.
    polarLVMask = zeros(nRadPoints, nAngle);
    
    for iTheta = 0:2*pi/nAngle : 2*pi - 2*pi/nAngle
        rLineX = [imSet.Center(1), imSet.Center(1) + radius*sin(iTheta)];
        rLineY = [imSet.Center(2), imSet.Center(2) + radius*cos(iTheta)];
        
        [endoX, endoY] = intersections(rLineX, rLineY, imSet.Endo(:,1,iImage), ...
            imSet.Endo(:,2,iImage), false);
        
        endoX
    end
    
end
