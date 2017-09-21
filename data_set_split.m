% code
%make a new directory for each file
mkdir(num2str(pName),fName(1:length(fName)-4));

% get the new path
FolderDestination=strcat(num2str(pName),fName(1:length(fName)-4));
% make a mfile in new path
matfile = fullfile(FolderDestination, 'output.mat');
% add variables into that m file 
save(matfile);
