cafferoot = '/home/ubuntu/src/caffe/Unet/';
cd '/home/ubuntu/src/caffe/Unet';
addpath('/home/ubuntu/src/caffe/matlab');

model = '/home/ubuntu/src/caffe/Unet/deploy.prototxt';
weights = '/home/ubuntu/src/caffe/Unet/Snapshots/Systolic/Systolic_iter_20650.caffemodel';

caffe.set_mode_gpu();
caffe.set_device(0);
net = caffe.Net(model, weights, 'test');

imNames = dir('/home/ubuntu/src/caffe/Unet/lv_data/ImagesValidate/*png');
nImages = length(imNames);

figure(1)
for iImage = 1:nImages
    
    im = imread(['/lv_data/ImagesValidate/' imNames(iImage).name]);
    mask = imread(['/lv_data/MasksValidate/' imNames(iImage).name]);
    
    res = net.forward({im});
    
    foreground = res{1};
    background = abs(res{2});
    seg = (foreground > background);
    
    imshow(im, 'InitialMag', 'fit');
    green = cat(3, zeros(size(im)), ones(size(im)), zeros(size(im))); 
    red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im))); 
    hold on
    hg = imshow(green);
    set(hg, 'AlphaData', mask*0.25);
    hr = imshow(red);
    set(hr, 'AlphaData', seg*0.25);
    hold off
    drawnow;
    pause;
end

