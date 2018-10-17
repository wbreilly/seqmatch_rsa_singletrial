% reorganize seqmatch tmaps, giving simple position label to SC sequences
% but for SI and R sequences reordering so that RSA will be between objects
% of the same category
% Author: Walter Reilly
% Created: 10_15_18

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
           
% subjects that had some exception re missing run most likely
subjects2   = {'s225' 's227' 's232' 's236' 's237' 's239' 's241' 's242'};  

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

    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);

    % make a new directory in which to place curSubj's organized tmaps
    b.betaDir = fullfile(b.dataDir, 'tmap_4_rsa_singletrial_samecategory');
    mkdir(char(b.betaDir));

    % loop through runs
    for irun = 1:length(b.runs)

        try

        % run directory
        runDir = fullfile(b.dataDir, b.runs(irun), 'stats', '/');
        % load the condition order
        load(sprintf('/Users/wbr/walter/fmri/seqmatch/Data/Beh_output/%s_seq_reexposure_run%02d.mat',b.curSubj,irun), 'item_sequence_type', 'trial_order');
        
        % only care about category info
        obj_cats = regexprep(trial_order, '_\w*', '');
        %also useful
        condition_sans_seqnum = regexprep(item_sequence_type,'\d','');
        
        % need to get the category order of first SC and R sequence of
        % the first run, this will be what every other run and seq is
        % sorted 
        if irun == 1
            % find first match to SI and R
            first_SI_idx = find(~cellfun(@isempty, regexp(item_sequence_type,'SI')), 1, 'first');
            first_R_idx = find(~cellfun(@isempty, regexp(item_sequence_type,'R')), 1, 'first');
            
            % get the object categories for the first SI and R sequences
            % using the idx above
            SI_cats = obj_cats(first_SI_idx:first_SI_idx + 4);
            R_cats = obj_cats(first_R_idx:first_R_idx + 4);
        end % end if irun

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
            
            % if SC sequence, ipos is just the normal sequnce order, but
            % for SI and R ipos is the unified category order for that
            % subject
            if strcmp(condition_sans_seqnum(itrial), 'SC')
                for ipos = 1:5
                    [path,oldname,ext] = fileparts(b.rundir(irun).tmaps(itrial,:));
%                     newname = sprintf('%s_pos%d_rep%d_run%d.nii', item_sequence_type{itrial},ipos,irep,irun);
                    % label with condition at the end instead of the
                    % begining for trial matrix order
                    newname = sprintf('pos%d_%s_rep%d_run%02d.nii', ipos,item_sequence_type{itrial},irep,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(b.betaDir, newname));
                    itrial = itrial + 1;
                end
            else % if SI or R
                % getting the indices to reorder SC and R sequences
                % according to same category instead of same position
                
                % cur sequence presented object order
                cur_seq_cats = obj_cats(itrial:itrial + 4);
                
                % cur sequence condition
                cur_seq_type = condition_sans_seqnum(itrial);

                % get the indices to line up current seq order with unified
                % order
                if strcmp(cur_seq_type, 'SI')
                    [a,bidx] = ismember(cur_seq_cats, SI_cats);
                elseif strcmp(cur_seq_type, 'R')
                    [a,bidx] = ismember(cur_seq_cats, R_cats);
                end

                % lil check that all cats are accounted for
                if sum(a) < 5
                    error('categories shown dont match cur_seq!!')
                end
                
                for ipos = 1:5
                    [path,oldname,ext] = fileparts(b.rundir(irun).tmaps(itrial,:));
%                     newname = sprintf('%s_pos%d_rep%d_run%d.nii', item_sequence_type{itrial},bidx(ipos),irep,irun); % notice that ipos an index now
                    % label with condition at the end instead of the
                    % begining for trial matrix order
                    newname = sprintf('pos%d_%s_rep%d_run%02d.nii', bidx(ipos),item_sequence_type{itrial},irep,irun);
                    movefile(fullfile(path, [oldname, '.nii']), fullfile(b.betaDir, newname));
                    itrial = itrial + 1;
                end
            end
        end % end itrial

        catch exception
        fprintf('There was a problem with subject %s in run %s on trial %d!!\n\n', subjects{i},runs{irun}, itrial)
        disp(exception.message);
        end % end try
    end % end irun       

    b.check = spm_select('ExtFPListRec', b.betaDir, '.*.nii');

    if size(b.check,1) ~= 900
        warning('Dont have 900 tmaps!!')
    end
    
end % i (subjects)

% might want to include something that programmatically verifies this..
fprintf('Tmaps copied and reorganized!!\n\n')




