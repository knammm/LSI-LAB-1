#!/bin/bash -f

cd /home/share_file/cadence/
source add_path
source add_license
cd -

xrun -access rw -licqueue -64BIT -l run.log bound_flasher.v test_bench.v
