function userOptions = defineUserOptions()
%
%  projectOptions is a nullary function which initialises a struct
%  containing the preferences and details for a particular project.
%  It should be edited to taste before a project is run, and a new
%  one created for each substantially different project (though the
%  options struct will be saved each time the project is run under
%  a new name, so all will not be lost if you don't do this).
%
%  For a guide to how to fill out the fields in this file, consult
%  the documentation folder (particularly the userOptions_guide.m)
%
%  Cai Wingfield 11-2009
%__________________________________________________________________________
% Copyright (C) 2009 Medical Research Council


%% Project details

% This name identifies a collection of files which all belong to the same run of a project.
userOptions.analysisName = 'seqmatch_betweenrun_FSrois_samecategory_10_15_18';

% This is the root directory of the project.
userOptions.rootPath = '/Users/wbr/walter/fmri/seqmatch/wbr_analysisscripts/rsa_singletrial/singletrial_4_rsatoolbox';

% The path leading to where the scans are stored (not including subject-specific identifiers).
% "[[subjectName]]" should be used as a placeholder to denote an entry in userOptions.subjectNames
% "[[betaIdentifier]]" should be used as a placeholder to denote an output of betaCorrespondence.m if SPM is not being used; or an arbitrary filename if SPM is being used.
userOptions.betaPath = '/Users/wbr/walter/fmri/seqmatch/Data_FSL/rsa_sc_same_item_reps/stick_function_one_reg/[[subjectName]]/tmap_4_rsa_singletrial_samecategory/[[betaIdentifier]]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FEATURES OF INTEREST SELECTION OPTIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%% %% %% %% %%
	%% fMRI  %% Use these next three options if you're working in fMRI native space:
	%% %% %% %% %%
	
	% The path to a stereotypical mask data file is stored (not including subject-specific identifiers).
	% "[[subjectName]]" should be used as a placeholder to denote an entry in userOptions.subjectNames
	% "[[maskName]]" should be used as a placeholder to denote an entry in userOptions.maskNames
	userOptions.maskPath = '/Users/wbr/walter/fmri/seqmatch/ROIs/freesurfer2/[[subjectName]]/corticalroi/[[maskName]]';
		% beta_resampled_word_form_thresholded.nii
        
    % The list of mask filenames (minus .hdr extension) to be used.
    

%%
%            % FS and ANTS ROIs
           userOptions.maskNames = {'lh_ACC'; 'lh_ANG';'lh_FG';'lh_MPFC';'lh_OFC';'lh_PCC';...
        'lh_Prec';'lh_RSC';'lh_TPole';'lh_VMPFC';'lh_VTC';...
        'rh_ACC'; 'rh_ANG';'rh_FG';'rh_MPFC';'rh_OFC';'rh_PCC';...
        'rh_Prec';'rh_RSC';'rh_TPole';'rh_VMPFC';'rh_VTC'};


%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEARCHLIGHT OPTIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%

	%% %% %% %% %%
	%% fMRI  %% Use these next three options if you're working in fMRI native space:
	%% %% %% %% %%

		% What is the path to the anatomical (structural) fMRI scans for each subject?
		% "[[subjectName]]" should be used to denote an entry in userOptions.subjectNames
% 		userOptions.structuralsPath = 'Analyzed_MRI/[[subjectName]]/mprage_sag_NS_g3_0002';
	
		% What are the dimensions (in mm) of the voxels in the scans?
		userOptions.voxelSize = [3 3 3];
	
		% What radius of searchlight should be used (mm)?
 		userOptions.searchlightRadius = 6;
	
%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENTAL SETUP %%
%%%%%%%%%%%%%%%%%%%%%%%%

% The list of subjects to be included in the study.
userOptions.subjectNames = {'s201' 's202' 's203' 's204' 's205' 's206' 's209' 's212' 's214' ...
                              's215' 's216' 's217' 's221' 's222' 's223' 's225' 's226' 's227' ...
                              's228' 's231' 's232' 's234' 's235' 's236' 's237' 's238' 's239' 's240' 's241' 's242'};

% The default colour label for RDMs corresponding to RoI masks (as opposed to models).
userOptions.RoIColor = [0 0 1];
userOptions.ModelColor = [0 1 0];

% Should information about the experimental design be automatically acquired from SPM metadata?
% If this option is set to true, the entries in userOptions.conditionLabels MUST correspond to the names of the conditions as specified in SPM.
userOptions.getSPMData = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYSIS PREFERENCES %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First-order analysis

% Text lables which may be attached to the conditions for MDS plots.
[userOptions.conditionLabels{1:900}] = deal(1:900);
% userOptions.conditionLabels = {'Intact'}; % 'S-F' 'S-R'};
% userOptions.useAlternativeConditionLabels = false;

% What colours should be given to the conditions?
userOptions.conditionColours = [repmat([1 0 0], 48,1); repmat([0 0 1], 44,1)];

% Which distance measure to use when calculating first-order RDMs.
userOptions.distance = 'correlation';


% %% Second-order analysis
% 
% % Which similarity-measure is used for the second-order comparison.
 userOptions.distanceMeasure = 'spearman';
% 
% % How many permutations should be used to test the significance of the fits?  (10,000 highly recommended.)
% userOptions.significanceTestPermutations = 10000;
% 
% % Bootstrap options
% userOptions.nResamplings = 1000;
% userOptions.resampleSubjects = true;
% userOptions.resampleConditions = false;
% 
% % Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.rankTransform = false;
% 
% % Should rubber bands be shown on the MDS plot?
userOptions.rubberbands = true;
% 
% % What criterion shoud be minimised in MDS display?
userOptions.criterion = 'metricstress';
% 
% % What is the colourscheme for the RDMs?
userOptions.colourScheme = bone(128);
% 
% % How should figures be outputted?
% userOptions.displayFigures = true;
% userOptions.saveFiguresPDF = true;
% userOptions.saveFiguresFig = true;
% userOptions.saveFiguresPS = true;
% % Which dots per inch resolution do we output?
% userOptions.dpi = 300;
% % Remove whitespace from PDF/PS files?
% % Bad if you just want to print the figures since they'll
% % no longer be A4 size, good if you want to put the figure
% % in a manuscript or presentation.
% userOptions.tightInset = true;
% 
% userOptions.forcePromptReply = 'r';