% Choose and load data and net.
[imageName, imagePath] = uigetfile('*.mat', ...
    'Select a .mat file of images to segment.');
[networkName, networkPath] = uigetfile('', ...
    'Select network to use for segmentation.');
% load(fullfile(networkPath, networkName));
data = load(fullfile(imagePath, imageName));
% Choose where to save segmentations.
savePath = uigetdir(pwd, 'Select a folder to save the results into.');

% Choose what to segment: systolic, diastolic or both.
dataSet = data.systolic;
% dataSet = data.diastolic;
% dataSet = [data.systolic data.diastolic];

% Constants.
radius = 27;
cropSize = radius*2+1;
padded = 0; % Pad switch.

% h = waitbar(0,'Segmenting images and saving images...');
nSets = size(dataSet,2);
for iSet = 1:nSets
    % Extract patient set.
    pat = dataSet(iSet);
    nImages = size(pat.IM,3);
    for iImage = 1:nImages
        % Extract image.
        im = pat.IM(:,:,iImage);
        
        % Crop and resize image.
        centerX = round(pat.Center(1,iImage));
        centerY = round(pat.Center(2,iImage));
        
        % Zeropad if we try to crop outside the image.
        if radius > min([centerX - 1, size(im, 1) - centerX, ...
                centerY - 1, size(im, 2) - centerY])
            
            im = padarray(im, [radius radius] , 0, 'both');
            centerX = centerX + radius;
            centerY = centerY + radius;
            pat.Endo(:,:,iImage) = pat.Endo(:,:,iImage) + radius;
            pat.Epi(:,:,iImage) = pat.Epi(:,:,iImage) + radius;
            padded = 1;
        end
        
        % Crop and resize roi.
        imCrop = imresize(im((centerX - radius):(centerX + radius + 1), ...
            (centerY - radius):(centerY + radius + 1)),[128 128]);
        
        % Segment the roi image using the neural network.
        C = semanticseg(imCrop, net);
        figure(1);
        B = labeloverlay(imCrop, C, 'IncludedLabels', "Myocardium", ...
            'Transparency',0.9, 'Colormap', [0, 0.5, 0; 1, 1, 1]);
        imshow(B)
        
        C = (C == "Myocardium");
        contours = bwboundaries(C);
        
        if length(contours) > 2
            % Extract the correct contours, number 2 and 3 of the largest
            % contours (largest is around the image).
            lengths = cellfun(@length,contours);
            [~, idx] = sort(lengths, 'descend');
            contour = cell(1,2);
            contour{1} = contours{idx(2)};
            contour{2} = contours{idx(3)};
        else
            contour = contours;
        end
        
        % Resize the contour to the original image.
        for i = 1:2
            contour{i}(:,1) = contour{i}(:,1) * cropSize/128 + ...
                (centerX - radius);
            contour{i}(:,2) = contour{i}(:,2) * cropSize/128 + ...
                (centerY - radius);
            % Remove padding.
            if padded
                contour{i} = contour{i} + radius;
            end
        end
        
        figure(2);
        imagesc(pat.IM(:,:,iImage)); colormap gray; axis image; colorbar;
        hold on
        plot(pat.Endo(:,2,iImage), ...
            pat.Endo(:,1,iImage), 'g-');
        plot(pat.Epi(:,2,iImage), ...
            pat.Epi(:,1,iImage), 'g-');
        plot(contour{1}(:,2), contour{1}(:,1), 'r-')
        plot(contour{2}(:,2), contour{2}(:,1), 'r-')
        hold off
        pause();
        padded = 0;
    end
end