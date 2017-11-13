function varargout = plugin_exportlvcontours(fcn,varargin)
%-------------------------------------------------
% Segment plugin to export cine short axis images and the corresponding
% delineated myocardial contour from a set of .mat files.
%
% The user either chooses a folder or a set of .mat files, from which images
% with delineated epi- and endocardial contour are extracted along with the
% contours to a struct which is saved in a .mat file at a chosen destination.
%
% The structs are "systolic" and "diastolic" with the following fields 
% for each patient.
%     IM:         Cine short axis images.
%     Endo:       x- and y-coordinates of the endocardial contour.
%     Endo:       x- and y-coordinates of the epicardial contour.
%     Center:     x- and y-coordinates of the LV center point.
%     Resolution: The image resolution [mm/pixel].
%   
% Image matrixes are in [X,Y,N] format, and contours are in [P,2,N] format,
% where X are the rows and Y are the columns of the images, N is the number
% of slices in Z-direction and P is the number of sample points along the
% contour.
%
% The script also produces and saves an error .mat file for files
% displaying some kind of fault, which can be used to manually check the
% files in order to see if the problem is serious and if the file should
% be omitted. Some errors result in an automatic omittion of the file
% during export.
%
% written by Mattis Nilsson, 2017

if nargin==0
    myfailed('Expects at least one input argument.');
    return;
end;

switch fcn
    case 'getname'
        varargout = cell(1,1);
        % Segment with versions >1.636 calls with two input arguments where
        % the second input argument is the handle to the menu item.
        
        % Menu name
        varargout{1} = 'Export LV Contours';
        % Submenus
        uimenu(varargin{1},'Label','Export folder', ...
            'Callback','plugin_exportlvcontours(''exportfolder'')');
        uimenu(varargin{1},'Label','Export files', ...
            'Callback','plugin_exportlvcontours(''exportfiles'')');
        
        % Set the main menu to not perform a callback
        set(varargin{1},'Callback','');
    case 'getdependencies'
        % Here: List all depending files. This is required if your plugin
        % should be possible to compile to the stand-alone version of Segment.
        varargout = cell(1,4);
        
        % M-files, list as {'hello.m' ...};
        varargout{1} = {'findfunctions.m'};
        
        % Fig-files, list as {'hello.fig' ... };
        varargout{2} = {};
        
        % Mat-files, list as {'hello.mat' ... };
        varargout{3} = {};
        
        % Mex-files, list as {'hello' ...}; %Note i.e no extension!!!
        varargout{4} = {};
    otherwise
        macro_helper(fcn,varargin{:}); %Future use to record macros
        [varargout{1:nargout}] = feval(fcn,varargin{:}); % FEVAL switchyard
end;

%---------------------
function exportfiles %#ok<DEFNU>
%---------------------
% Export selected files.

% Select .mat files to load.
[loadFileNames, loadPathName]= myuigetfile('*.mat', ...
    'Select .mat files to export', 'MultiSelect', 'on');

% Check that correct paths were chosen.
if isequal(loadPathName,0)
    myfailed('No files chosen. Export aborted.');
    return;
end

% Export
export(loadPathName, loadFileNames);

%---------------------
function exportfolder %#ok<DEFNU>
%---------------------
% Export entire folder.

% Select a folder to load from.
global DATA;
loadPathName = myuigetdir(DATA.Pref.datapath,'Select a directory with .mat files.');

% Check that correct paths were chosen.
if isequal(loadPathName,0)
    myfailed('No folder chosen. Export aborted.');
    return;
end

% Find files in the folder.
filesInDir = dir([loadPathName filesep '*.mat']);
fileNames = extractfield(filesInDir, 'name');

% Export files.
export(loadPathName, fileNames);

%---------------------
function export(pathName, fileNames)
%---------------------
% Loops through the files in fileNames and saves the data in a struct.

global SET DATA; % Global variables used by Segment.

% Choose .mat save file destination.
[savePathName, savePath] = myuiputfile('*.mat', ...
    'Select or create a file to save to');

% Check that a save path was chosen.
if isequal(savePath,0)
    myfailed('No save path chosen. Export aborted.');
    return;
end;

savePath = fullfile(savePath, savePathName);

% Initialize output and error structs.
nFiles = length(fileNames);
diastolic = struct('IM',{}, 'Endo',{}, 'Epi',{}, 'Center',{}, ...
    'ResolutionX',{}, 'ResolutionY',{}, 'DataSetName',{}, 'FileName',{});
systolic = struct('IM',{}, 'Endo',{}, 'Epi',{}, 'Center',{}, ...
    'ResolutionX',{}, 'ResolutionY',{}, 'DataSetName',{}, 'FileName',{});
errors = struct('Filename',{}, 'Errortype',{}, 'Info',{}, 'Consequence',{});
abortInd = zeros(1,nFiles);

% Loop through the files in the folder.
h = mywaitbarstart(nFiles,'Please wait, exporting...',1);
for iFile = 1:nFiles
    load([pathName filesep fileNames{iFile}],'-mat');
    SET = setstruct;
    clear setstruct; % Why do we do this?
    
    % Call to intialize all variables correcly after loaded data.
    openfile('setupstacksfrommat',1);
    DATA.Silent = true; % Turn on "silent" mode.
    
    if not(DATA.DataLoaded)
        myfailed('No data loaded.');
        return;
    end % Check if image exists.
    
    fprintf('Loading %s. \n',fileNames{iFile}); % Print filename.
    
    % Find short axis stack.
    no = unique(findfunctions('findcineshortaxisno', true));
    if length(no) ~= 1
        errors = exportError(errors, fileNames{iFile}, ...
            struct('no', no), ...
            'More than one cine short axis stack found.', ...
            'Aborted');
        abortInd(iFile) = 1;
        h = mywaitbarupdate(h);
        continue;
    end % Write error and about if there is more than one cine short axis stack.
    
    % Find time frames contatining segmentation.
    edt = SET(no).EDT;
    est = SET(no).EST;
    
    % Check that edt and est contains both endo and epi segmentation.
    tfs = intersect(find(findfunctions('findframeswithsegmentation', 'endo', no)),...
        find(findfunctions('findframeswithsegmentation', 'epi', no)));
    if length(tfs) ~= 2
        errors = exportError(errors,fileNames{iFile}, ...
            struct('edt',edt,'est',est,'timeframes',tfs), ...
            'More than 2 segmented timeframes found, edt/est matches.', ...
            'Continued');
        if length(tfs) > 2
            if length(intersect(tfs,[edt est])) == 2
                errors = exportError(errors,fileNames{iFile}, ...
                    struct('edt',edt,'est',est,'timeframes',tfs), ...
                    'More than 2 segmented timeframes found, edt/est matches.', ...
                    'Continued');
            else
                errors = exportError(errors,fileNames{iFile}, ...
                    struct('edt',edt,'est',est,'timeframes',tfs), ...
                    'More than 2 segmented timeframes found, edt/est does NOT match.', ...
                    'Aborted');
                abortInd(iFile) = 1;
                h = mywaitbarupdate(h);
                continue;
            end
        else if length(tfs) < 2
                errors = exportError(errors,fileNames{iFile}, ...
                    struct('edt',edt,'est',est,'timeframes',tfs), ...
                    'Less than 2 segmented timeframes found.', ...
                    'Aborted');
                abortInd(iFile) = 1;
                h = mywaitbarupdate(h);
                continue;
            end
        end
    else if length(intersect(tfs,[edt est])) ~= 2
            errors = exportError(errors, fileNames{iFile}, ...
                struct('edt',edt,'est',est,'timeframes',tfs), ...
                'edt/est does not contain segmentation.', ...
                'Aborted');
            abortInd(iFile) = 1;
            h = mywaitbarupdate(h);
            continue;
        end
    end
    
    % Make sure that LVM for edt and est is equal within a tolerance.
    tol = 0.05;   % Tolerance (set to 5%).
    if abs(SET(no).LVM(1,edt) - SET(no).LVM(1,est)) > ...
            min(SET(no).LVM(1,edt)*tol,SET(no).LVM(1,est)*tol);
        errors = exportError(errors, fileNames{iFile}, ...
            struct('Filenumber',iFile, 'edtLVM',SET(no).LVM(1,edt), ...
            'estLVM',SET(no).LVM(1,est)), ...
            'LVM for edt and est are not equal within tolerance.', ...
            'Aborted');
        abortInd(iFile) = 1;
        h = mywaitbarupdate(h);
        continue;
    end
    
    % Find slice indices containing segmentation.
    indDia = intersect(find(findfunctions('findslicewithendo', no, edt)), ...
        find(findfunctions('findslicewithepi', no, edt)));
    indSys = intersect(find(findfunctions('findslicewithendo', no, est)), ...
        find(findfunctions('findslicewithepi', no, est)));
    
    % Amount of segmented slices error check.
    if length(indDia) < 7 || length(indSys) < 7
        errors = exportError(errors, fileNames{iFile}, ...
            struct('indDia', indDia,'indSyS',indSys), ...
            'Less than 7 segmented slices found.', ...
            'Continued');
    end
    
    % Extract patient data.
    if (SET(no).ResolutionX ~= SET(no).ResolutionY)
        errors = exportError(errors, fileNames{iFile}, ...
            struct('ResolutionX', SET(no).ResolutionX, ...
            'ResolutionY',SET(no).ResolutionY), ...
            'Resolution in X and Y are not the same.', ...
            'Aborted');
        abortInd(iFile) = 1;
        h = mywaitbarupdate(h);
        continue;
    end
    
    % End-systolic time frame.
    % Extract images.
    systolic(iFile).IM = squeeze(SET(no).IM(:,:,est,indSys));
    % Extract epicardial contour.
    systolic(iFile).Epi(:,1,:) = SET(no).EpiX(:,est,indSys);
    systolic(iFile).Epi(:,2,:) = SET(no).EpiY(:,est,indSys);
    % Extract endocardial contour.
    systolic(iFile).Endo(:,1,:) = SET(no).EndoX(:,est,indSys);
    systolic(iFile).Endo(:,2,:) = SET(no).EndoY(:,est,indSys);
    % Extract Centerpoints.
    systolic(iFile).Center = [squeeze(mean(systolic(iFile).Endo(:,1,:))), ...
        squeeze(mean(systolic(iFile).Endo(:,2,:)))]';
    % Extract image resolution.
    systolic(iFile).ResolutionX = SET(no).ResolutionX;
    systolic(iFile).ResolutionY = SET(no).ResolutionY;
    % Extract name of data set and files.
    systolic(iFile).DataSetName = savePathName;
    [~,fileName] = fileparts(fileNames{iFile});
    systolic(iFile).FileName = fileName;
    
    % End-diastolic time frame.
    diastolic(iFile).IM = squeeze(SET(no).IM(:,:,edt,indDia));
    diastolic(iFile).Epi(:,1,:) = SET(no).EpiX(:,edt,indDia);
    diastolic(iFile).Epi(:,2,:) = SET(no).EpiY(:,edt,indDia);
    diastolic(iFile).Endo(:,1,:) = SET(no).EndoX(:,edt,indDia);
    diastolic(iFile).Endo(:,2,:) = SET(no).EndoY(:,edt,indDia);
    diastolic(iFile).Center = [squeeze(mean(diastolic(iFile).Endo(:,1,:))), ...
        squeeze(mean(diastolic(iFile).Endo(:,2,:)))]';
    diastolic(iFile).ResolutionX = SET(no).ResolutionX;
    diastolic(iFile).ResolutionY = SET(no).ResolutionY;
    diastolic(iFile).DataSetName = savePathName;
    diastolic(iFile).FileName = fileName;
    
    h = mywaitbarupdate(h); % Update waitbar for each file.
end

% Remove empty struct indices.
abortInd(end) = []; % The last is not created and does not become empty.
abortInd = find(abortInd);
if ~isempty(abortInd)
    diastolic(abortInd) = [];
    systolic(abortInd) = [];
end

DATA.Silent = false; % Stop silent mode.

% Save the data and error report.
if length(errors) > 1
    save(savePath,'diastolic', 'systolic', 'errors');
else
    save(savePath, 'diastolic', 'systolic');
end
mywaitbarclose(h);   % Close waitbar.
mymsgbox(['Data was saved to: ' savePath], 'Succesful export!');

%---------------------
function errors = exportError(errors, filename, info, type, consequence)
%---------------------
% Helpfunction to generate error report.

newError.Filename = filename;
newError.Info = info;
newError.Errortype = type;
newError.Consequence = consequence;
errors = [errors, newError];