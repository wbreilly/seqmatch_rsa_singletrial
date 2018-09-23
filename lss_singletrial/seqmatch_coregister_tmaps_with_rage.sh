#!/bin/sh

# there are two some subs for whom not all runs are present! 
for isub in s201 s202 s203 s204 s205 s206 s209 s212 s214 s215 s216 s217 s221 s222 s223 s225 s226 s227 s228 s231 s232 s234 s235 s236 s237 s238 s239 s240 s241 s242
	do 
		echo $isub
		subj_dir=/Users/wbr/walter/fmri/seqmatch/Data_FSL/rsa_sc_same_item_reps/stick_function_one_reg/$isub

		for irun in Run01.feat Run02.feat Run03.feat Run04.feat Run05.feat Run06.feat Run07.feat Run08.feat Run09.feat Run10.feat
			do
				run_dir=${subj_dir}/$irun
				echo $run_dir


		done
		
done
