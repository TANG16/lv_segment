savePath = uigetdir(pwd, ...
    'Select a folder to save the images into.');

ground = zeros(56,96);
rnd = 27+randi([0 12], 1 , 2000);

for iImage = 1:2000
    im = ground;
    im(rnd(iImage)-4:rnd(iImage)+4,:) = 1;
    imwrite(logical(im), fullfile(savePath, ['im_' num2str(iImage) '.png']), 'png'); 
end