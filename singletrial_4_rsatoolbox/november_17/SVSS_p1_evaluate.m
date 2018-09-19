% save a text file of contrast means to pass to R
clear all
clc

%% setup and create text file

% analysis name
analysis = 'SVSS_p1_11_3_17';
% you know who
subjects = {'s001' 's002' 's003' 's004' 's007' 's008' 's009' 's010' 's011' 's015' 's016' 's018' 's019'};
% load the RSA matrices     
load('RDMs/everything_11_3_17_RDMs.mat');
% load mask
load('SVSS_p1.mat')
%path to bad betas
bad_beta_path = '/Users/wbr/walter/fmri/sms_scan_analyses/data_for_spm/getbetas_native_10_20_17_copy';

% setup txt to write results into with subject and analysis names
analysis_dat = sprintf('RSAmeans_%s.txt', analysis);

if fopen(analysis_dat,'rt') ~= -1 
    fclose('all');
    yes_or_no = input('Data file already exists! Are you sure you want to overwrite the file? (yes:1 no:0) ');
    if yes_or_no == 0 || isempty(yes_or_no)
        error('You screwed up, start over!!');
    end
end

% write analysis file
fid_study = fopen(analysis_dat,'wt');
% write header
fprintf(fid_study,'sub roi condition similarity\n');
 
% get the ROI names
ROIs = {};
for iname = 1:size(RDMs,1)
    target = RDMs(iname, 1).name;
    % this grabs the informative part of the name
    idx    = strfind(target, ' '); 
    idx = idx(1);
    roi_name = char(strtrim(target(1:idx-1)));
    % save the roi name 
    ROIs{end+1} = roi_name;
end 

%% loop through each sub
for iRDM = 1:size(RDMs,2)
    
    % load up the bad beta identifiers
    beta_txt = fullfile(bad_beta_path,subjects{iRDM}, 'betas_4_rsa_singletrial', '1.2_bad_fullsample.txt');
    bad_betas = textread(beta_txt);
    
    % loop through each roi
    for iroi = 1:size(RDMs,1) 

        % grab the RDM
        x = RDMs(iroi,iRDM).RDM;
        
        % NaN bad betas to be excluded
        for ibad = 1:length(bad_betas)
            x(bad_betas(ibad),:) = NaN;
            x(:,bad_betas(ibad)) = NaN;
        end % end ibad
        
        % not neccesary but useful so I keep
        % change diagonal of symmetrical matrix
%         x(logical(eye(size(x)))) = 0;
        
        % NaN any correlations that equal zero (ones in dissimilarity)
        x(x == 1) = NaN;
        % convert to similarity, UNLESS USING COSINE
        x = -1*(x-1);
        %% 
        
        % mask
        x_vec = x(SVSS_p1);
        % can use below to check appearance of masked data
%       x_org = x.*SVSS;
  
        % check that length is right
        if length(x_vec) ~= 45
            error('x_vec is not equal to 45!!')
        end

        % pull out values for each condition
        % intact
        x_i = x_vec(1:18);
        % scrambled-random
        x_s_r = x_vec(19:27);
        % scrambled-fixed
        x_s_f = x_vec(28:45);

        % now take the mean of all correlations
        x_i_mean = nanmean(x_i);
        x_s_r_mean = nanmean(x_s_r);
        x_s_f_mean = nanmean(x_s_f);
       
        % save data in txt file
        fprintf(fid_study,'%s %s %s %.5f\n', subjects{iRDM}, ROIs{iroi},'intact', x_i_mean);
        fprintf(fid_study,'%s %s %s %.5f\n', subjects{iRDM}, ROIs{iroi}, 'scrambled', x_s_r_mean);
        fprintf(fid_study,'%s %s %s %.5f\n', subjects{iRDM}, ROIs{iroi}, 'random', x_s_f_mean);
    end % end iroi
end %end iRDM


