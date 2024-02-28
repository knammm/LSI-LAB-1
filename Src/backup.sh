#!/bin/bash

# Define variables
dest_folder="backup_folder"
current_date=$(date +"%Y%m%d-%H%M%S")
file_name="backup_files_$current_date"

# Change permission
chmod 777 $dest_folder

# Create copy files
cp bound_flasher.v bound_flasher_copy.v
cp test_bench.v test_bench_copy.v

# Create folder
mkdir $file_name

# Move copy files
mv bound_flasher_copy.v $file_name/
mv test_bench_copy.v $file_name/

# Zip the backup folder
zip -r $file_name.zip $file_name

# Remove the folder after zip
rm -rd $file_name

# Move the zip file to the dest_folder
mv $file_name.zip $dest_folder

# Recover permission
chmod 000 $dest_folder
