#!/bin/bash

# Store the current date in a variable
current_date=$(date +%s)

# Loop through all files in the specified directory
for file in $1/*; do
  # Check if the file is a regular file (not a directory or special file)
  if [ -f "$file" ]; then
    # Get the last accessed date of the file
    last_accessed=$(stat -c %X "$file")

    # Calculate the difference in seconds between the current date and the last accessed date of the file
    diff=$((current_date - last_accessed))

    # Convert the difference in seconds to the equivalent in months
    diff_months=$((diff / 60 / 60 / 24 / 30))

    # If the file hasn't been accessed in the past 3 months (or more), delete it
    if [ "$diff_months" -gt 3 ]; then
      rm "$file"
    fi
  fi
done