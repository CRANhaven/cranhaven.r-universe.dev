#!/usr/bin/env bash

set -e

# Set input T1 & CT files
mri_path="{{ mri_path }}"
ct_path="{{ ct_path }}"
wdir="{{ work_path }}"
dest_path="{{ dest_path }}"
deriv_path="{{ derivative_path }}"

dof={{ dof }}
cost={{ cost }}
searchcost={{ searchcost }}
searchrange={{ trimws(search) }}
timestamp=$(date -u)

if [[ -z "$mri_path" || -z "$ct_path" ]]; then
  echo "Cannot run FST-FLIRT: Invalid source path" >&2
  exit -1;
fi

# FSL setup
{{
  if(length(fsl_home) == 1 &&
      !is.na(fsl_home) &&
      isTRUE(file.exists(fsl_home))) {
    sprintf('export FSLDIR="%s"', fsl_home)
  } else {
    ''
  }
}}
source ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}

# Prepare log file
log_file="{{ log_file }}"
if [[ ! -z "$log_file" ]]; then
  log_dir="{{ log_path }}"
  log_file="$log_dir/$log_file"
  mkdir -p "$log_dir" && touch "$log_file"
  echo '--------------------------------------------------------'
  echo "Log file: $log_file"
  echo '--------------------------------------------------------'
else
  log_file="/dev/null"
fi

mkdir -p "$dest_path"
mkdir -p "$deriv_path"

# Copy the MRI and CT to the dest_path for localization in case
ct_ext=".nii"
if [[ "$ct_path" == *Z ]] || [[ "$ct_path" == *z ]]; then
  ct_ext=".nii.gz"
fi
cp -f "$ct_path" "$dest_path/CT_RAW$ct_ext"
cp -f "$ct_path" "$deriv_path/CT_RAW$ct_ext"

mr_ext=".nii"
if [[ "$mri_path" == *Z ]] || [[ "$mri_path" == *z ]]; then
  mr_ext=".nii.gz"
fi
cp -f "$mri_path" "$dest_path/MRI_reference$mr_ext"

# Save coreg settings
echo "Heads up: Do NOT edit this file
profile: CT coregister to MRI
work_path: \"$wdir\"
timestamp: \"$timestamp\"
command:
  execute: flirt
  arguments:
  - -interp trilinear
  - -cost $cost
  - -dof $dof
  - -searchcost $searchcost
  - -searchrx -$searchrange $searchrange
  - -searchry -$searchrange $searchrange
  - -searchrz -$searchrange $searchrange
input_image:
  type: nifti
  path: \"$ct_path\"
  backup:
  - ./derivative/CT_RAW$ct_ext
  - ./coregistration/CT_RAW$ct_ext
  comment: original CT image file
reference_image:
  type: nifti
  path: \"$mri_path\"
  backup: ./coregistration/MRI_reference$mr_ext
  comment: Reference MR image file, the CT is aligned to this reference image
outputs:
  ct2t1:
    type: transform
    dimension: 4x4
    transform_from:
      volume: input_image
      coordinate_system: FSL
    transform_to:
      volume: reference_image
      coordinate_system: FSL
    path: ./coregistration/ct2t1.mat
    backup: ./derivative/ct2t1.mat
    comment: From FSL coordinate in input CT to FSL coordinate in reference MRI
  ct_in_t1:
    type: nifti
    path: ./coregistration/ct_in_t1.nii.gz
    backup: ./derivative/ct_in_t1.nii.gz
    comment: |
      Coregistered, re-sampled CT; the resolution is the same as reference MRI.
      RAVE supports electrode localization using original input CT when ct2t1
      transform matrix is present, so this file is not very useful. However,
      please do not delete this file as a back-up.
" > "$deriv_path/conf-coregistration.yaml"


# Run flirt
flirt -in "$ct_path" -ref "$mri_path" \
  -out "$dest_path/ct_in_t1.nii" -omat "$dest_path/ct2t1.mat" \
  -interp trilinear -cost $cost -dof $dof -searchcost $searchcost \
  -searchrx -$searchrange $searchrange \
  -searchry -$searchrange $searchrange \
  -searchrz -$searchrange $searchrange -v | tee -a "$log_file"

cp -f "$dest_path/ct2t1.mat" "$deriv_path/transform-ct2t1.mat"
cp -f "$dest_path/ct_in_t1.nii.gz" "$deriv_path/ct_in_t1.nii.gz"

echo "Done." | tee -a "$log_file"

## END OF RAVE Script: FSL-flirt coregistration ##