% save a text file of contrast means to pass to R
clear all
clc

%% setup and create text file

% analysis name
analysis = '';
% you know who
subjects = {'s201' 's202' 's203' 's204' 's205' 's206' 's209' 's212' 's214' ...
                              's215' 's216' 's217' 's221' 's222' 's223' 's225' 's226' 's227' ...
                              's228' 's231' 's232' 's234' 's235' 's236' 's237' 's238' 's239' 's240' 's241' 's242'};

% load the RSA matrices     
load('/Users/wbr/walter/fmri/seqmatch/wbr_analysisscripts/rsa_singletrial/singletrial_4_rsatoolbox/RDMs/seqmatch_betweenrun_FSrois_samecategory_10_16_18_RDMs.mat');

% load mask
load('seqmatch_between_run_masks.mat')

%path to bad betas
% what bad betas?

% setup txt to write results into with subject and analysis names
analysis_dat = sprintf('RSA_%s.txt', analysis);

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
fprintf(fid_study,'sub roi condition position similarity\n');
 
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

% for ipos = 1:5
    %% loop through each sub
    for iRDM = 1:size(RDMs,2)

        % loop through each roi
        for iroi = 1:size(RDMs,1) 

            % grab the RDM
            x = RDMs(iroi,iRDM).RDM;

            %%
            % NaN bad runs to be excluded
            % This is what they are missing:
            % s225  Run08.feat
            % s227 Run06.feat
            % s232 Run02_bad_motion.feat
            % s236 Run04.feat
            % s237 Run09.feat
            % s239 Run09.feat Run10.feat
            % s241 Run06.feat
            % s242 Run07.feat  Run08.feat  Run10.feat

            %lazy index of subejcts. DO NOT change subject order in RSA!!
            bad_sub_i_idxs = [16 18 21 24 25 27 29 30];
            badrun = [];
            badrun2= [];
            badrun3= [];
            
            if any(bad_sub_i_idxs(:) == iRDM)
                if iRDM == 16
                    badrun = 8;
                elseif iRDM == 18
                    badrun = 6;
                elseif iRDM == 21
                    badrun = 2;
                elseif iRDM == 24
                    badrun = 4;
                elseif iRDM == 25
                    badrun = 9;
                elseif iRDM == 29
                    badrun = 6;
                    
                elseif iRDM == 27
                    badrun = 9;
                    badrun2 = 10;
                elseif iRDM == 30
                    badrun = 7;
                    badrun2 = 8;
                    badrun3 = 10;
                end
                
                
                % NaN badruns
                x(badrun:10:900,:) = NaN;
                x(:,badrun:10:900) = NaN;

                % NaN other badruns if there is a second
                if iRDM == 27 || 30
                    x(badrun2:10:900,:) = NaN;
                    x(:,badrun2:10:900) = NaN;
                end

                % NaN third badrun
                if iRDM == 30
                    x(badrun3:10:900,:) = NaN;
                    x(:,badrun3:10:900) = NaN;
                end
            end
            %%

            % NaN any correlations that equal zero (ones in dissimilarity)
            x(x == 1) = NaN;
            % convert to similarity, UNLESS USING COSINE
            x = 1-x;
            %% 
            for imask = 1:3
                % set masks
                mask1 = all_between_seq_bigmask;
                mask2 = between_learnedonly_seq_bigmask;
                mask3 = between_added_and_learned_seq_bigmask;
                
                % mask
                x_vec1 = x(mask1); %length of x_vec1 is 16200. 1080(within condition and positino)*5(positions)*3(conditions).
                x_vec2 = x(mask2);
                x_vec3 = x(mask3);
                % can use below to check appearance of masked data
                % x_org = x.*SVSS;

                %% pull out values for each condition and position for mask1
                % do this to check elements in vec of single mask chunk (within condition and position but between diff seuqences)
                % check = mask(1:60,1:60);
                % sum(sum(check))
                % it's 1080 for all_between_seq_bigmask
                %1080*3 = 3240 % steps between positions for each condition
                %for all_between_seq_bigmask
                R_data1 = [];
                start_val = 1:3240:16200;
                for ival = 1:length(start_val) 
                    R_data1 = [R_data1 x_vec1(start_val(ival):start_val(ival)+1079)];
                end
                
                SC_data1 = [];
                start_val = 1081:3240:16200;
                for ival = 1:length(start_val) 
                    SC_data1 = [SC_data1 x_vec1(start_val(ival):start_val(ival)+1079)];
                end
                
                SI_data1 = [];
                start_val = 2161:3240:16200;
                for ival = 1:length(start_val) 
                    SI_data1 = [SI_data1 x_vec1(start_val(ival):start_val(ival)+1079)];
                end
                
                %% mask2
                %check = mask2(1:60,1:60);
                % sum(sum(check)) = 360 because only comparing 2 learned
                % sequences. 1/3 of above where there are 3 intersequnece
                % comparisons instead of one.
                
                R_data2 = [];
                start_val = 1:1080:5400;
                for ival = 1:length(start_val) 
                    R_data2 = [R_data2 x_vec2(start_val(ival):start_val(ival)+359)];
                end
                
                SC_data2 = [];
                start_val = 361:1080:5400;
                for ival = 1:length(start_val) 
                    SC_data2 = [SC_data2 x_vec2(start_val(ival):start_val(ival)+359)];
                end
                
                SI_data2 = [];
                start_val = 721:1080:5400;
                for ival = 1:length(start_val) 
                    SI_data2 = [SI_data2 x_vec2(start_val(ival):start_val(ival)+359)];
                end
                
                %% mask3
                % 720 because there are 2/3 between seq comparisons here
                
                R_data3 = [];
                start_val = 1:2160:10800;
                for ival = 1:length(start_val) 
                    R_data3 = [R_data3 x_vec3(start_val(ival):start_val(ival)+719)];
                end
                
                SC_data3 = [];
                start_val = 721:2160:10800;
                for ival = 1:length(start_val) 
                    SC_data3 = [SC_data3 x_vec3(start_val(ival):start_val(ival)+719)];
                end
                
                SI_data3 = [];
                start_val = 1441:2160:10800;
                for ival = 1:length(start_val) 
                    SI_data3 = [SI_data3 x_vec3(start_val(ival):start_val(ival)+719)];
                end
                %% mean them
                
                R_data1_mean = nanmean(R_data1);
                SC_data1_mean = nanmean(SC_data1);
                SI_data1_mean = nanmean(SI_data1);
                
                R_data2_mean = nanmean(R_data2);
                SC_data2_mean = nanmean(SC_data2);
                SI_data2_mean = nanmean(SI_data2);
                
                R_data3_mean = nanmean(R_data3);
                SC_data3_mean = nanmean(SC_data3);
                SI_data3_mean = nanmean(SI_data3);
                
                
                %%
                for ipos = 1:5
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi},'R_all', ipos, R_data1_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SC_all', ipos, SC_data1_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SI_all', ipos, SI_data1_mean(ipos));
                    
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi},'R_learned', ipos, R_data2_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SC_learned', ipos, SC_data2_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SI_learned', ipos, SI_data2_mean(ipos));
                    
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi},'R_added', ipos, R_data3_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SC_added', ipos, SC_data3_mean(ipos));
                    fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi}, 'SI_added', ipos, SI_data3_mean(ipos));
                end
            end %imask
        end % end iroi
    end %end iRDM
% end % end ipos


% not neccesary but useful so I keep
            % change diagonal of symmetrical matrix
            % x(logical(eye(size(x)))) = 0;

