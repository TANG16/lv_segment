clear all;
clc;

filepath_root = 'C:\Users\Mattis\Documents\Exjobb\Traindata\LV_RV_training\LV och RV Trainingset epi with delineations\N';
ind = [1 9 13 15 17 26 29 45 58 60];

for i = 1:length(ind)
    filepath = strcat(filepath_root, int2str(ind(i)), '.mat');
    load(filepath);
    disp(int2str(ind(i)))
    global SET;
    SET = setstruct;
    
    % Vilken find funktion ska jag använda?
    %cineno = findfunctions('findno');
%     stackInfo = struct;

    no = findfunctions('findcineshortaxisno');
    xsize = SET(no).XSize
    ysize = SET(no).YSize
%         viewplane = SET(no).ImageViewPlane;
%         imgtype = SET(no).ImageType;
%         edt = SET(no).EDT;
%         est = SET(no).EST;
%         z = SET(no).ZSize;
%         t = SET(no).TSize;
%         x = [SET(no).EndoX(:,est,slice); ...
%                 SET(no).EpiX(:,est,slice)], ...
%                 [SET(no).EndoY(:,est,slice); ...
%                 SET(no).EpiY(:,est,slice)], ...
%                 SET(no).XSize, SET(no).YSize);
        
%         %%
%         for slice = 10:19
%            
%            figure(slice)
%            mask = poly2mask( ...
%                 [SET(no).EndoY(:,est,slice); ...
%                 SET(no).EpiY(:,est,slice)], ...
%                 [SET(no).EndoX(:,est,slice); ...
%                 SET(no).EpiX(:,est,slice)], ...
%                 SET(no).YSize, SET(no).XSize);
%            imagesc(mask.*SET(no).IM(:,:,edt,slice));
%            drawnow;
%            pause;
%         end
end