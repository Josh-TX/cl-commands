#!/bin/bash

#base path of all the other folders
basePath=/mnt/basePath

#you can configure these if you want
inputPath=$basePath/to-process
outputPath=$basePath/output
originalsPath=$basePath/originals
processingPath=$basePath/processing
failuresPath=$basePath/failures
logPath=$basePath/logs




logFile="$logPath/$(date '+%Y-%m-%d__%I%M%p').txt"
tempFile="$basePath/processing-filenames.txt"


processFile() {
	fullPath="$1"
    if [ ! -f $fullPath ]
    then 
        echo NOT FOUND: "$fullPath" | tee -a "$logFile"
        return
    fi

    # filename could have a path portion (if in subdirectory of $inputPath)
    fileName=${fullPath/"$inputPath/"}
    
    mkdir -p "$(dirname "$processingPath/$fileName")"
    mv "$fullPath" "$processingPath/$fileName"

    outputFile="$outputPath/$fileName"
    outputFile=${outputFile/.webm/.mp4}
    outputFile=${outputFile/.avi/.mp4}
    startTime=$(date +%s)
    mkdir -p "$(dirname "$outputFile")"
    ffmpeg -nostdin -i "$processingPath/$fileName" -y -c:v libx264 -crf 23 -preset ultrafast "$outputFile"
    if [ $? -eq 0 ]
    then
        endTime=$(date +%s)
        echo SUCCESSFULLY created "$outputFile" | tee -a "$logFile"
        echo \telapsed time: $(($endTime-$startTime)) seconds | tee -a "$logFile"
        mkdir -p "$(dirname "$originalsPath/$fileName")"
        mv "$processingPath/$fileName" "$originalsPath/$fileName"
    else 
        endTime=$(date +%s)
        echo FAILURE processing "$outputFile" | tee -a "$logFile"
        echo \telapsed time: $(($endTime-$startTime)) seconds | tee -a "$logFile"
        mkdir -p "$(dirname "$failuresPath/$fileName")"
        mv "$processingPath/$fileName" "$failuresPath/$fileName"
    fi
}

if [ -f $tempFile ]
then 
    echo SESSION ALREADY ACTIVE: "$tempFile"
    exit 1
fi

find $inputPath -type f \( -iname \*.mp4 -o -iname \*.webm -o -iname \*.avi \) > $tempFile
cat $tempFile | while read file
do
    processFile "$file"
done
rm $tempFile
cd $inputPath
find . -type d -empty -delete