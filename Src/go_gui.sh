#!/bin/bash

cd /home/share_file/cadence/
source add_path
source add_license
cd -

simvision -64 &
