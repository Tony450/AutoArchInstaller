#!/bin/bash

for archive in $(ls -l | awk '{print $9}' | grep ".zip"); do
    directory=$(echo $archive | cut -d '.' -f 1)
    mkdir $directory
    unzip $archive -d $directory
done

rm *.zip
