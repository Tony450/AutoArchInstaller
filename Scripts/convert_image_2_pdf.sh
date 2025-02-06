#!/bin/bash

find . -name '* *' -exec bash -c 'mv -v "$0" "`echo $0 | tr " " "_"`"' {} \; > /dev/null

for file in $(ls -l | awk '{print $9}'); do
    newfilename=$(echo $file | iconv -f UTF-8 -t ASCII//TRANSLIT)
    mv $file $newfilename -n
done

for archive in $(ls -l | awk '{print $9}' | grep ".png"); do

    mogrify -crop 794x1025+560+42 $archive

    name=$(echo $archive | cut -d '.' -f 1)
    pdfFile="$name"".pdf"
    #magick $imageFile $pdfFile

done

#rm *.png