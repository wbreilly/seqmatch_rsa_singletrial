% save a text file of contrast means to pass to R
clear all
clc

%% setup and create text file

% analysis name
analysis = '11_28_18_bwtween_condition_sameposition_occ';
% you know who
subjects = {'s201' 's202' 's203' 's204' 's205' 's206' 's209' 's212' 's214' ...
                              's215' 's216' 's217' 's221' 's222' 's223' 's225' 's226' 's227' ...
                              's228' 's231' 's232' 's234' 's235' 's236' 's237' 's238' 's239' 's240' 's241' 's242'};

% load the RSA matrices     
load('/Users/wbr/walter/fmri/seqmatch/wbr_analysisscripts/rsa_singletrial/singletrial_4_rsatoolbox/RDMs/seqmatch_betweenrun_FSrois_sameposition_11_28_18_RDMs.mat');

% load mask
load('between_condition_big_mask.mat')

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
            % set masks
           

            % mask
            x_vec1= x(between_seq_bigmask); %length of x_vec1 is 16200. 1080(within condition and positino)*5(positions)*3(conditions).


            %% pull out values for each condition and position for mask1
            % do this to check elements in vec of single mask chunk (within condition and position but between diff seuqences)
            % check = mask(1:60,1:60);
            % sum(sum(check))
            % it's 1080 for all_between_seq_bigmask
            %1080*3 = 3240 % steps between positions for each condition
            %for all_between_seq_bigmask
            data1 = [];
            start_val = 1:3240:16200;
            for ival = 1:length(start_val) 
                data1 = [data1 x_vec1(start_val(ival):start_val(ival)+1079)];
            end


            data1_mean = nanmean(data1);



            %%
            for ipos = 1:5
                fprintf(fid_study,'%s %s %s %d %.5f\n', subjects{iRDM}, ROIs{iroi},'DF_SP', ipos, data1_mean(ipos));
            end
            
        end % end iroi
    end %end iRDM
% end % end ipos


% not neccesary but useful so I keep
            % change diagonal of symmetrical matrix
            % x(logical(eye(size(x)))) = 0;

