impathname = uigetdir(pwd,'Select the folder with images');
maskpathname = uigetdir(pwd,'Select the folder with masks');
writepath = uigetdir(pwd,'Select where to write output');

if isequal(impathname,0) || isequal(maskpathname,0) || isequal(writepath,0)
    myfailed('Aborted.');
    return;
end;

%Find files to process
ims = dir(fullfile(impathname,'*.png'));
nFiles = length(ims);
ind = randperm(numel(ims));
ims = ims(ind);

if nFiles == 0
    myfailed('Found no files.');
    return;
end;

%Fraction of images for training

trainFrac = 0.6;
valFrac = 0.8;

%Make folders
mkdir([writepath filesep 'ImagesTraining']);
mkdir([writepath filesep 'MasksTraining']);
mkdir([writepath filesep 'MasksTest']);
mkdir([writepath filesep 'ImagesTest']);
mkdir([writepath filesep 'ImagesValidate']);
mkdir([writepath filesep 'MasksValidate']);

%Make txt files
fid = fopen('ImagesTraining.txt','w');
fclose(fid);

fid = fopen('ImagesTest.txt','w');
fclose(fid);

fid = fopen('MasksTraining.txt','w');
fclose(fid);

fid = fopen('MasksTest.txt','w');
fclose(fid);

randset = rand(1,nFiles);

%Loop over all files
h = waitbar(0,'Please wait, dividing images and creating txt files...');
for iFile = 1:nFiles
    
    fileName = ims(iFile).name;
    maskPath = fullfile(maskpathname, fileName);
    imPath = fullfile(impathname, fileName);
    %Randomize training or testing
    
    if randset(iFile) > valFrac
        % For Validation
        writeimtemp = strcat(writepath, filesep, 'ImagesValidate');
        writemasktemp = strcat(writepath, filesep,'MasksValidate');
        copyfile(imPath, writeimtemp);
        copyfile(maskPath, writemasktemp);
        
    else if randset(iFile) > trainFrac
            %For Testing
            
            %Copy files to correct folder
            writeimtemp = strcat(writepath, filesep, 'ImagesTest');
            writemasktemp = strcat(writepath, filesep,'MasksTest');
            copyfile(imPath, writeimtemp);
            copyfile(maskPath, writemasktemp);
            
            %Edit txt files
            fid = fopen('ImagesTest.txt','a');
            fprintf(fid,'%s %d \r\n' ,imPath ,1);
            fclose(fid);
            
            fid = fopen('MasksTest.txt','a');
            fprintf(fid,'%s %d \r\n' , maskPath ,1);
            fclose(fid);
            
        else
            %For Training
            
            %Copy files to correct folder
            writeimtemp = strcat(writepath, filesep, 'ImagesTraining');
            writemasktemp = strcat(writepath,filesep, 'MasksTraining');
            copyfile(imPath, writeimtemp);
            copyfile(maskPath,writemasktemp);
            
            %Edit txt files
            fid = fopen('ImagesTraining.txt','a');
            fprintf(fid,'%s %d \r\n' , imPath,1);
            fclose(fid);
            
            fid = fopen('MasksTraining.txt','a');
            fprintf(fid,'%s %d \r\n' , maskPath,1);
            fclose(fid);
        end
    end
    
    h = waitbar(iFile/nFiles);
end
close(h);