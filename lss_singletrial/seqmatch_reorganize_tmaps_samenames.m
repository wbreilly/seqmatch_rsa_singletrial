% reorganize seqmatch tmaps, rather give each tmap a descriptive name, thus
% organizing tmaps across subjects
% Author: Walter Reilly
% Created: 9_19_18

% Takes seqmatch 4d tmap series and returns 90 3d tmaps per run with
% descriptive names

clear all
clc

%%
dataDir     = '/Users/wbr/walter/fmri/seqmatch/Data_FSL/rsa_sc_same_item_reps/stick_function_one_reg';
behDir      = '/Users/wbr/walter/fmri/seqmatch/Data/Beh_output';

subjects    = {'s201' 's202' 's203' 's204' 's205' 's206' 's209' 's212' 's214' ...
               's215' 's216' 's217' 's221' 's222' 's223' 's225' 's226' 's227' ...
               's228' 's231' 's232' 's234' 's235' 's236' 's237' 's238' 's239' 's240' 's241' 's242'};
runs        = {'Run01.feat' 'Run02.feat' 'Run03.feat' 'Run04.feat' ...
               'Run05.feat' 'Run06.feat' 'Run07.feat' 'Run08.feat' 'Run09.feat' 'Run10.feat'};  

%-- Check for required functions

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

fprintf('You beta reorganize!!\n\n')

%--Loop over subjects

for i = 2:length(subjects)
    try
        % Define variables for individual subjects - General
        b.curSubj   = subjects{i};
        b.runs      = runs;
        b.dataDir   = fullfile(dataDir, b.curSubj);

        % make a new directory in which to place curSubj's organized tmaps
        b.betaDir = fullfile(b.dataDir, 'tmap_4_rsa_singletrial');
        mkdir(char(b.betaDir));

        % loop through runs
        for irun = 1:length(b.runs)

            % run directory
            runDir = fullfile(b.dataDir, b.runs(irun), 'stats', '/');
            % load the condition order
            load(sprintf('/Users/wbr/walter/fmri/seqmatch/Data/Beh_output/%s_seq_reexposure_run%02d.mat',b.curSubj,irun), 'item_sequence_type');

            % split 4d nii into 90 3d nii's cuz SPM. Looks like this will just
            % overwrite if it has run already
            spm_file_split(sprintf('%scond1ls_s_tval.nii',runDir{1}));

            % get tmaps
            b.rundir(irun).tmaps = spm_select('ExtFPListRec', runDir, 'cond1ls_s_tval_0.*.nii');

            %% going to effectively loop through all the trials but need some
            % counters to get position and rep right
            % initiate trial counter
            itrial = 1;
            while itrial < 91
                % repetition var
                if itrial < 46
                    irep = 1;
                else
                    irep = 2;
                end
                % position var
                for ipos = 1:5
                    [path,oldname,ext] = fileparts(b.rundir(irun).tmaps(itrial,:));
                    newname = sprintf('%s_pos%d_rep%d_run%d.nii', item_sequence_type{itrial},ipos,irep,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(b.betaDir, newname));
                    itrial = itrial + 1;
                end
            end % end itrial


        end % end irun       

        b.check = spm_select('ExtFPListRec', b.betaDir, '.*.nii');

        if size(b.check,1) ~= 900
            error('Dont have 90 tmaps!!')
        end
    catch
        fprintf('There was a problem with subject %s in run %d on trial %d', subjects{i},runs{irun}, itrial)
    end
    
end % i (subjects)

% might want to include something that programmatically verifies this..
fprintf('Tmaps copied and reorganized!!\n\n')




