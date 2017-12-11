

impathname = uigetdir(impathname,'Select the folder with images (created by imlandmarkplugin)');
maskpathname = uigetdir(maskpathname,'Select the folder with Landmark masks (created by imlandmarkplugin)');
writepath = uigetdir(writepath,'Select where to write output');

if isequal(impathname,0) || isequal(maskpathname,0) || isequal(writepath,0)
  myfailed('Aborted.');
  return;
end;

%Find files to process
ims = dir(fullfile(impathname,'*.png'));
numfiles = length(ims);
ind = randperm(numel(ims));
ims = ims(ind);

if numfiles==0
  myfailed('Found no files.');
  return;
end;

 %Fraction of images for training
 
trainFrac = 0.8;

    %Make folders
mkdir([writepath filesep 'ImagesTraining']);
mkdir([writepath filesep 'MasksTraining']);
mkdir([writepath filesep 'MasksTest']);
mkdir([writepath filesep 'ImagesTest']);

  %Make txt files
  fid = fopen('ImagesTraining.txt','w');
  fclose(fid);
  
  fid = fopen('ImagesTest.txt','w');
  fclose(fid);
  
  fid = fopen('MaskTraining.txt','w');
  fclose(fid);
  
  fid = fopen('MaskTest.txt','w');
  fclose(fid);
  
%Loop over all files
h = waitbar(0,'Please wait, dividing images and creating txt files.');
for fileloop=1:numfiles
    
  imagename = ims(fileloop).name;
  maskname = strcat(strtok(imagename,'.'),'Landmarks.png');
  maskpathtemp = fullfile(maskpathname,maskname);
  impathtemp = fullfile(impathname,imagename);
  %Randomize training or testing
  
  trainortest = rand();

  if(trainortest > trainFrac)
     %For Testing
     
     %Copy files to correct folder
     writeimtemp = strcat(writepath, filesep, 'ImagesTest');
     writemasktemp = strcat(writepath,filesep,'LandmarkMasksTest');
     copyfile(impathtemp, writeimtemp);
     copyfile(maskpathtemp,writemasktemp);
     
     %Edit txt files
     fid = fopen('ImagesTest.txt','a');
     fprintf(fid,'%s %d \r\n' ,imagename ,1);
     fclose(fid);
     
     fid = fopen('LandmarkTest.txt','a');
     fprintf(fid,'%s %d \r\n' ,maskname ,1);
     fclose(fid);
     
  else
      %For Training
      
      %Copy files to correct folder
      writeimtemp = strcat(writepath, filesep, 'ImagesTraining');
      writemasktemp = strcat(writepath,filesep,'LandmarkMasksTraining');
      copyfile(impathtemp, writeimtemp);
      copyfile(maskpathtemp,writemasktemp);
      
      %Edit txt files
      fid = fopen('ImagesTraining.txt','a');
      fprintf(fid,'%s %d \r\n' ,imagename ,1);
      fclose(fid);
     
      fid = fopen('LandmarkTraining.txt','a');
      fprintf(fid,'%s %d \r\n' ,maskname ,1);
      fclose(fid);
  end

    h = waitbar(fileloop/numfiles);
    
end; %loop over files

mywaitbarclose(h);


%Make sure starting with something fresh.
segment('filecloseall_Callback',true);

%Stop the silent mode.
DATA.Silent = false;


%---------------------------------
