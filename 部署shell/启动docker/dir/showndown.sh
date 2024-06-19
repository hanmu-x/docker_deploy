#!/bin/bash

# Process name to search for
process_name="cccout"

# Find and close the process named $process_name
process_id=$(ps aux | grep -v grep | grep -m1 "$process_name" | awk '{print $2}')

if [ -z "$process_id" ]; then
    echo "No running process named $process_name found."
else
    kill "$process_id"
    echo "$process_name process (PID: $process_id) has been successfully terminated."
fi


