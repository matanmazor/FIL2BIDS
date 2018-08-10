function [  ] = FIL2BIDS (source_dir, target_dir, sequence_name, sequence_idx)
%FIL2BIDS Gets as input a list of directories and rearranges them in BIDS
%format.

%dependencies:
addpath('D:\Documents\software\xiangruili-dicm2nii-ae1d301');

%% 0. Sanity checks
if sum(strcmp(sequence_name, {'func','fmap','anat'}))==0
    error('Unknown sequence name')
end

%% 1. Create subdirectories
if ~exist(fullfile(target_dir, sequence_name))
    mkdir(fullfile(target_dir, sequence_name))
end

%% 2. Untar directories
mkdir(fullfile(source_dir, sequence_name));
subj_id = source_dir(end-10:end);
for i=1:length(sequence_idx)
    untar(fullfile(source_dir, strcat(subj_id,'.S',num2str(sequence_idx(i)),'.tar')),...
        fullfile(source_dir, sequence_name));
end

%% 3. Save as niftis and jsons
dicm2nii(fullfile(source_dir, sequence_name),fullfile(target_dir, sequence_name))
rmdir(fullfile(source_dir, sequence_name),'s');

%% 4. Validate that everything makes sense, and then change file names
switch sequence_name
    case 'anat'
        %here I assume that the anatomical image should be mprage
        if ~exist(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.json'), 'file')
            error('Couldn''t find MPRAGE_64ch_Head.json')
        elseif ~exist(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.nii.gz'), 'file')
            error('Couldn''t find MPRAGE_64ch_Head.nii.gz')
        end
        
        movefile(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.json'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_T1w.json')));
        
        movefile(fullfile(target_dir, sequence_name, 'MPRAGE_64ch_Head.nii.gz'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_T1w.nii.gz')));
        
    case 'fmap'
        %here I assume that the fieldmap image is of a certain type
        if ~exist(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.json'), 'file')
            error('Couldn''t find gre_field_mapping_1acq_rl.json')
        elseif ~exist(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.nii.gz'), 'file')
            error('Couldn''t find gre_field_mapping_1acq_rl.nii.gz')
        elseif ~exist(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.json'), 'file')
            error('Couldn''t find gre_field_mapping_1acq_rl_phase.json')
        elseif ~exist(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.nii.gz'), 'file')
            error('Couldn''t find gre_field_mapping_1acq_rl_phase.nii.gz')
        end
        
        movefile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.json'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_magnitude1.json')));
        
        movefile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl.nii.gz'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_magnitude1.nii.gz')));
        
        movefile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.json'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_phasediff.json')));
        
        movefile(fullfile(target_dir, sequence_name, 'gre_field_mapping_1acq_rl_phase.nii.gz'),...
            fullfile(target_dir, sequence_name, strcat('sub-',subj_id,'_phasediff.nii.gz')));
    case 'func'
        %here I assume that the _events.tsv files have already been placed in the
        %folder and that they are ordered like the functional scannings
        tsv_files = dir(fullfile(target_dir,'func','*_events.tsv'));
        json_files = dir(fullfile(target_dir,'func','*.json'));
        image_files = dir(fullfile(target_dir,'func','*.nii.gz'));
        if size(tsv_files) ~= size(json_files) 
            error('different number of event files and functional scans')
        end
        
        for i=1:length(tsv_files)
            run_name = tsv_files(i).name(1:regexp(tsv_files(i).name,'_events.tsv')-1);
            % change json file name
            movefile(fullfile(target_dir, sequence_name, json_files(i).name),...
                       fullfile(target_dir, sequence_name, strcat(run_name,'_bold.json'))); 
            movefile(fullfile(target_dir, sequence_name, image_files(i).name),...
                       fullfile(target_dir, sequence_name, strcat(run_name,'_bold.nii.gz'))); 
        end
   
end

end

