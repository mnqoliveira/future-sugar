#!/bin/bash

# This file was used in another version of the project
# For every file in the result of the simulation,
# save the line with day of simulation 365 in a output
# kept for future reference.

# TODO: remove all paths if this file is published
IN=/run/media/fs/data/

for file in $IN/apsim-out2/*.out
  do
    echo "Processing $file"
    echo "$file $(awk '$3 == 365' $file)" >> /home/fs/res.txt
  done

