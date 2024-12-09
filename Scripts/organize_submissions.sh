#!/bin/bash

unzip $1
rm *.zip

for f in *\ *; do mv "$f" "${f// /_}"; done

for directory in $(ls -l | awk '{print $9}'); do 
    cd $directory
    mv * ../
    cd ..
done

rm -r *assignsubmission_file

find . -name '* *' -exec bash -c 'mv -v "$0" "`echo $0 | tr " " "_"`"' {} \; > /dev/null

for file in $(ls -l | awk '{print $9}'); do
    newfilename=$(echo $file | iconv -f UTF-8 -t ASCII//TRANSLIT)
    mv $file $newfilename -n
done
