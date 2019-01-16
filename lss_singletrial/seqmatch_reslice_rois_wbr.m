% reslice seqmatch ROIs to tmap space. All runs have been coregistered, so
% just using example func from the first run as the ref

clear all
clc

%%
dataDir     = '/Users/wbr/walter/fmri/seqmatch/Data_FSL/rsa_sc_same_item_reps/stick_function_one_reg';
surfDir     = '/Users/wbr/walter/fmri/seqmatch/ROIs/freesurfer_wbr';

subjects    = {'s201' 's202' 's203' 's204' 's205' 's206' 's209' 's212' 's214' ...
               's215' 's216' 's217' 's221' 's222' 's223' 's225' 's226' 's227' ...
               's228' 's231' 's232' 's234' 's235' 's236' 's237' 's238' 's239' 's240' 's241' 's242'};
           
% subjects that had some exception re missing run most likely
subjects2   = {'s225' 's227' 's232' 's236' 's237' 's239' 's241' 's242'};  

% SPM
if exist('spm','file') == 0
    error('SPM must be on the path.')
end

auto_accept = 0;
runflag = 1;

% Loop over subjects
for isub = 1:length(subjects)
    
    clear b

    % Define variables for individual subjects - General
    b.curSubj   = subjects{isub};
    b.dataDir   = fullfile(dataDir, b.curSubj);
    b.surfDir   = fullfile(surfDir, b.curSubj, 'corticalroi');
    b.masks     = cellstr(spm_select('ExtFPListRec', b.surfDir, '.*.nii$'));
    
    % first run example_func image as the reference 
    b.funcDir = fullfile(b.dataDir, 'Run01.feat','reg');
    b.examplefunc = spm_select('FPListRec', b.funcDir, 'example_func.nii$');
    
    
    %loop through masks
    for imask = 1 %:size(b.masks,1)
        matlabbatch{imask}.spm.spatial.coreg.write.ref = cellstr(b.examplefunc);
        matlabbatch{imask}.spm.spatial.coreg.write.source = cellstr(b.masks);
        matlabbatch{imask}.spm.spatial.coreg.write.roptions.interp = 0;
        matlabbatch{imask}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{imask}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{imask}.spm.spatial.coreg.write.roptions.prefix = 'reslice_';
    end % end imask
    
   
    %run
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
    
    newnames = {'lh_occ.nii', 'rh_occ.nii'};
    
    % grab all the resliced masks
    b.sliced = (spm_select('FPListRec', b.surfDir, '^reslice.*.nii'));
    
    
    
    for imask = 1:size(b.sliced,1) 
        [x,y,z] = fileparts(b.sliced(imask,:));
        input_img = b.sliced(imask,:);
        output_img = fullfile(b.surfDir, newnames(imask));
        spm_imcalc(char(input_img),char(output_img), 'i1 ~= 0'); 
    end % imask
end % end isub

% y = {};
% for iroi = 1:size(b.masks,1)
%     [x,y{iroi},z] = fileparts(b.masks{iroi,:});
% end
