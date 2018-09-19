% reorganize betas
% Author: Walter Reilly
% Created: 9_19_17

% Takes output from LSS and reorganizes and renames betas to be compatible
% with RSA toolbox in the sms_scan paradigm

clear all

dataDir     = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_9_29_17';
scriptdir   = '/Users/wbr/walter/fmri/sms_scan_analyses/rsa_singletrial/lss_singletrial'; 

subjects    = {'s001' 's002' 's003' 's004' 's007' 's008'};
runs        = {'Rifa_1' 'Rifa_2' 'Rifa_3' 'Rifa_4' 'Rifa_5' 'Rifa_6' 'Rifa_7' 'Rifa_8' 'Rifa_9'};  

%
auto_accept = 0;

%-- Clean up

clc
fprintf('Initializing and checking paths.\n')


%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('You beta reorganize!!\n\n')

%--Loop over subjects
for i = 1:length(subjects)
    
    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
        
    % Define variables for individual subjects - QA General
    b.scriptdir   = scriptdir;
    b.auto_accept = auto_accept;
    b.messages    = sprintf('Messages for subject %s:\n', subjects{i});
    
    % Check whether first level has already been run for a subject
    
    % Initialize diary for saving output
    diaryname = fullfile(b.dataDir, 'reorganizebetasdiary.txt');
    diary(diaryname);
    
    %%
    % do the stuff
    
    % make a new directory in which to place curSubj's organized betas
    b.betaDir = fullfile(b.dataDir, 'beta_4_rsa_singletrial');
    mkdir(char(b.betaDir));
    
    % loop through runs
    for irun = 1:length(b.runs)
        
        % run directory
        runDir = fullfile(b.dataDir, b.runs(irun), '/');
       
        % get folder names and paths to betas
        [b.rundir(irun).seqs(1).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, '.*0001.*.nii');
        [b.rundir(irun).seqs(2).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, '.*0002.*.nii');
        [b.rundir(irun).seqs(3).reps, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, '.*0003.*.nii');
        
        %% added to get create mean image of each repetition (same item and sequence)
        for ibeta = 1:25
            % images to mean
            tmp_image = {b.rundir(irun).seqs(1).reps(ibeta,:); b.rundir(irun).seqs(2).reps(ibeta,:); b.rundir(irun).seqs(3).reps(ibeta,:) };
            tmp_image = strrep(tmp_image, ' ', '');
            % folder to write mean image into
            dest = fullfile(b.rundir(irun).name(ibeta,:), 'meanbeta.nii');
            dest = strrep(dest, ' ', '');
            spm_imcalc(tmp_image, dest, '(i1 + i2 + i3)/3');
        end
        
        % get folder names and paths to betas
        [b.rundir(irun).means, b.rundir(irun).name] = spm_select('ExtFPListRec', runDir, '^mean.*.nii');
        
            
        %%
        for icopy = 1:size(b.rundir(irun).means,1)
            % get file name for source
            [path,name,ext] = fileparts(b.rundir(irun).means(icopy,:));
            % get folder(sequence) name info for the source
            [path2,name2,ext2] = fileparts(b.rundir(irun).name(icopy,:));
            % renove weird spaces at end of name2
            name2 = strrep(name2, ' ', '');
            % move the file and add the folder name into the file name
            copyfile(fullfile(path, [name, '.nii']), fullfile(b.betaDir, [name2,'_run',num2str(irun),'.nii']));
        end % end icopy
    end % end irun
end % i (subjects)

% might want to include something that programmatically verifies this..
fprintf('Betas copied and reorganized!!\n\n')




