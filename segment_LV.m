% % Choose and load data and net.
[imageName, imagePath] = uigetfile('*.mat', ...
    'Select a .mat file of images to segment.');
% [networkName, networkPath] = uigetfile('', ...
%     'Select network to use for segmentation.');
% % load(fullfile(networkPath, networkName));
data = load(fullfile(imagePath, imageName));
% % Choose where to save segmentations.
% savePath = uigetdir(pwd, 'Select a folder to save the results into.');

% Choose what to segment: systolic, diastolic or both.
% dataSet = data.systolic;
% dataSet = data.diastolic;
dataSet = [data.systolic data.diastolic];



net = SegNet;

% Constants.
radius = 29;
cropSize = radius*2+1;
padded = 0; % Pad switch.

% h = waitbar(0,'Segmenting images and saving images...');
nSets = size(dataSet,2);
for iSet = 1:nSets
    % Extract patient set.
    imSet = dataSet(iSet);
    imSet = resampleImages(imSet, 1.5);
    nImages = size(imSet.IM,3);
    for iImage = 1:nImages
        % Extract image.
        im = imSet.IM(:,:,iImage);
        
        % Crop and resize image.
        centerX = round(imSet.Center(1,iImage));
        centerY = round(imSet.Center(2,iImage));
        
        % Zeropad if we try to crop outside the image.
        if radius > min([centerX - 1, size(im, 1) - centerX, ...
                centerY - 1, size(im, 2) - centerY])
            
            im = padarray(im, [radius radius] , 0, 'both');
            centerX = centerX + radius;
            centerY = centerY + radius;
            imSet.Endo(:,:,iImage) = imSet.Endo(:,:,iImage) + radius;
            imSet.Epi(:,:,iImage) = imSet.Epi(:,:,iImage) + radius;
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
        
        % DOES IT USE THE SAME SPATIAL RESOLUTION AS THE ORIGINAL
        % IMAGE!!?!?
        
        figure(2);
        imagesc(imSet.IM(:,:,iImage)); colormap gray; axis image; colorbar;
        hold on
        plot(imSet.Endo(:,2,iImage), ...
            imSet.Endo(:,1,iImage), 'g-');
        plot(imSet.Epi(:,2,iImage), ...
            imSet.Epi(:,1,iImage), 'g-');
        plot(contour{1}(:,2), contour{1}(:,1), 'r-')
        plot(contour{2}(:,2), contour{2}(:,1), 'r-')
        hold off
        drawnow;
        pause();
        padded = 0;
    end
end

%-----------------------------------
function imSet = resampleImages(imSet, resolution)
%-----------------------------------
% Upsamples current image stack (in slice only). Takes care of
% segmentation in the upsampling process.

% Stolen and adapted from Segment (functions upsampleimage_Callback,
% upsamplevolume and resamplehelper).

f = imSet.ResolutionX/resolution; % Resample factor.

imSet.IM = upsamplevolume(f, imSet.IM);

% Resample contours.
imSet.Endo = resamplehelper(f,imSet.Endo);
imSet.Epi = resamplehelper(f,imSet.Epi);

% Resample renter.
imSet.Center = resamplehelper(f,imSet.Center);

% Resample resolution.
imSet.ResolutionX = imSet.ResolutionX/f;
imSet.ResolutionY = imSet.ResolutionY/f;
end

%-------------------------------
function x = resamplehelper(f,x)
%-------------------------------
%Helper function to resample image stacks.
%factor 2 => x' = 2*x-0.5
%factor 3 => x' = 3*x-1
%factor 4 => x' = 4*x-1.5
%factor 5 => x' = 5*x-2
%factor 2.5 => x' = 2.5*x-1
%factor 3.5 => x' = 3.5*x-1.5
%factor 0.5 => x' = x'*0.5 (a odd)
%factor 0.5 => x' = x'*0.5+0.5 (a even)

if f>0
    d = (ceil(f)-1)/2;
else
    d = 0;
end

if isa(x,'double')
    x = x*f-d;
else
    for xloop=1:size(x,1)
        for yloop=1:size(x,2)
            x{xloop,yloop} = x{xloop,yloop}*f-d;
        end
    end
end
end

%--------------------------------------
function newvol = upsamplevolume(f,vol)
%--------------------------------------
%Helper function to upsample a volume vol.

%Find new size
newsize = size(imresize(vol(:,:,1,1),f,'nearest'));

%Reserve memory
if isa(vol,'single')
    newvol = repmat(single(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
elseif isa(vol,'int16')
    newvol = repmat(int16(0),[...
        newsize(1) ...
        newsize(2) ...
        size(vol,3) ...
        size(vol,4)]);
else
    newvol = zeros(newsize(1),newsize(2),size(vol,3),size(vol,4));
end

%Loop over image volume
for tloop=1:size(vol,3)
    for zloop=1:size(vol,4)
        if isa(vol,'single')
            newvol(:,:,tloop,zloop) = single(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        elseif isa(vol,'int16')
            newvol(:,:,tloop,zloop) = int16(imresize(vol(:,:,tloop,zloop),f,'bicubic'));
        else
            newvol(:,:,tloop,zloop) = imresize(vol(:,:,tloop,zloop),f,'bicubic');
        end
    end
end
end