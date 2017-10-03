function [centerX, centerY] = findLVCenter(EndoContour)

% if 
        % We should check if we ejection tract, then the center will be set
        % at a false position.
% end

centerX = mean(EndoContour(:,1));
centerY = mean(EndoContour(:,2));