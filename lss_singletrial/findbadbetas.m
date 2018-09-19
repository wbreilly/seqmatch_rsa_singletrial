function findbadbetas(sublist)
% Takes either a string or cell array of strings of subject IDs - e.g. 
% 'shopcon_101' or {'shopcon_101' 'shopcon_102'}.


% sublist = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019' 's020' 's022' 's023' 's024' 's025'}; % 


% select project directory
pdir='/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_native_4_26_18_duplicate';

% select single trial directory
% odir='SVDP_beta_4_rsa/';
% odir = 'beta_4_rsa_singletrial/';
% odir='tmap_4_rsa_singletrial/';
odir = 'SVDP_tmaps_4_rsa/';


% select ***ptile*** threshold
ptile = 7.5;
% it's the top ptile that we don't want
thresh = 100-ptile;

% select showhist
showhist=0;

% parse subject input
if ischar(sublist)
    sublist={sublist};
end

% loop through subjects
for s=1:length(sublist)
    
    % get subject name
    subject=sublist{s};
    sdir=[pdir '/' subject '/'];
    fprintf('Finding bad trials for %s...\n',subject);
    
    % load mask
    maskimg=load_nii([sdir 'reslice_allgray.nii']);
    mask=maskimg.img;
    
    % dir 
    ldir=[sdir odir];
   
    % find the bad betas for each condition
    con_idxs = [1:90];
    betas = load_nii([ldir 'all_singletrial.nii'],con_idxs);
    bad1=betascrub2point0(betas.img,mask, 'threshold',thresh,'showhist',showhist);
    
    con_idxs =  [91:135];
    betas = load_nii([ldir 'all_singletrial.nii'],con_idxs);
    bad2=betascrub2point0(betas.img,mask, 'threshold',thresh,'showhist',showhist);
    
    con_idxs =  [136:225];
    betas = load_nii([ldir 'all_singletrial.nii'],con_idxs);
    bad3=betascrub2point0(betas.img,mask, 'threshold',thresh,'showhist',showhist);
    
    % this makes image numbers refer to appropriate betas
    bad = [bad1; bad2+90; bad3+135];
    
    % if there are no exlcuded trials, put in a zero so that 
    if isempty(bad)
        bad = 0;
    end
    
     % write bad trial numbers to text file 
    dlmwrite([ldir 'SVDP_tmap_7.5ptile_5_18.txt'],bad);
   
end %subject
end % end function