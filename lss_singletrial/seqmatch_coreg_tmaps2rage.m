% coregister tmaps to mprage. Since data were preprocessed in FSL, this is
% a lil different than normal. Run coreg estimate for each run using the mprage as the
% reference (so it doesn't move) and the example_func as the source(since
% the tmaps are in register with each run's example_func already)
% Author: Walter Reilly
% Created: 9_22_18

clear all
clc

%%
dataDir     = '/Users/wbr/walter/fmri/seqmatch/Data_FSL/rsa_sc_same_item_reps/stick_function_one_reg';

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

auto_accept = 0;
runflag = 1;

%--Loop over subjects

for i = 19:length(subjects)
    
    clear b

    % Define variables for individual subjects - General
    b.curSubj   = subjects{i};
    b.runs      = runs;
    b.dataDir   = fullfile(dataDir, b.curSubj);
    b.ragedir   = '/Users/wbr/walter/fmri/seqmatch/ROIs/freesurfer2';
    b.mprage      = spm_select('FPListRec', b.ragedir, sprintf('%s_structural_brain.nii$',subjects{i}));
    
    
    runcount = 1;
    % loop through runs
    for irun = 1:length(b.runs)
        % run directory
        b.runDir = fullfile(b.dataDir, b.runs(irun), 'stats', '/');

        % check if coreg already run
        if exist(char(fullfile(b.runDir,sprintf('coregistration_check_%s_%s.txt',b.curSubj, runs{irun}))), 'file') == 2 % check in the sub directory
            if auto_accept
                response = 'n';
            else
                response = input('Coregistration was already run. Do you want to run it again? y/n \n','s');
            end
            if strcmp(response,'y')==1
                disp('Continuing running coregistration')
            else
                disp('Skipping coregistration')
                runflag = 0;
            end % end if autoaccept
        end % end if exist


        % if it hasn't been run, run coregistration
        if runflag
            % First re-organize all realigned files into cell array
            b.files = spm_select('ExtFPListRec', b.runDir, 'cond1ls_s_tval.nii', Inf);
            % Check if files are found
            if size(b.files, 1) > 0 
                fprintf('%0.0f nii files found for run %s.\n', size(b.files, 1), runs{irun});
            else
                continue
            end

            % get the source image which is example_func in the reg folder
            % of each run
            b.funcDir = fullfile(b.dataDir, runs{irun},'reg');
            b.examplefunc = spm_select('FPListRec', b.funcDir, 'example_func.nii$');

            % run coregister estimate 
            clear matlabbatch

            % initiate coreg params copied from a gui .m output
            % mprage location determined in find_nii
            % b.meanfunc made in realign script after meanfunc is made
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(b.mprage);
            matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(b.examplefunc);
            matlabbatch{1}.spm.spatial.coreg.estimate.other = cellstr(b.files);
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

            %try to run it
            try
                % run it
                spm('defaults','fmri');
                spm_jobman('initcfg');
                spm_jobman('run',matlabbatch);

                % make a text file to prove it ran without error
                fid = fopen(char(fullfile(b.runDir,sprintf('coregistration_check_%s_%s.txt',b.curSubj, runs{irun}))), 'wt' );
                fclose(fid);
            catch
                % if shit hits the floor
               error('whoops!! Coregistration did not complete without errors!')
            end % end trycatch
        end % end if
        fprintf('Run %d/10 complete for subject %s!! \n\n',runcount,subjects{i})
        % this should counter should be skipped if there is no data for
        % this run from the continue statment on line 78
        runcount = runcount+1;
    end % end irun          
end % i (subjects)
