#!/bin/bash

if [ $# -ne 2 ]
then
    echo "must have 2 arguments. Usage: re-encode-process.sh basepath processName"
    exit 1
fi
basePath=$1
processName=$2

inputPath=$basePath/input
input720Path=$basePath/input-720
outputPath=$basePath/output
originalsPath=$basePath/originals
processingPath=$basePath/processing/$processName
failuresPath=$basePath/failures
logPath=$basePath/logs
tempFile="$basePath/processing_$processName.lock"
ffmpegOptions='-c:v libx264 -crf 26 -movflags faststart -preset veryfast'

if [ ! -d "$inputPath" ]
then
    echo input director not found: "$inputPath"
    exit 1
fi

if [ -f "$tempFile" ]
then 
    echo session already active: "$tempFile"
    exit 0
fi

# if multiple nodes attempt the same file at once, there might be a race condition, so wait randomly to mitigate this
sleep $(($RANDOM % 5)).$(($RANDOM % 100))
# to further mitigate race conditions, we sort the files randomly and grab one
fullPath=$(find $inputPath -type f \( -iname \*.mp4 -o -iname \*.webm -o -iname \*.avi -o -iname \*.mkv \) | sort -R | head -n 1)

if [ ! -f "$fullPath" ]
then 
    echo no video files found in $inputPath

    #now try the 720 folder
    inputPath=$input720Path
    if [ -d "$inputPath" ]
    then
        ffmpegOptions='-c:v libx264 -crf 26 -vf scale=-2:720 -movflags faststart -preset veryfast'
        fullPath=$(find $inputPath -type f \( -iname \*.mp4 -o -iname \*.webm -o -iname \*.avi -o -iname \*.mkv \) | sort -R | head -n 1)
        if [ ! -f "$fullPath" ]
        then
            echo no video files found in $inputPath
            exit 0
        fi
    else
        exit 0
    fi
fi
echo $fullPath > $tempFile


logFile="$logPath/$processName.log"
mkdir -p "$(dirname "$logPath")"
if [ ! -f "$logFile" ]
then 
    touch $logFile
fi



fileName=${fullPath/"$inputPath/"} # filename could have a path portion if it's in a subdirectory of $inputPath)

mkdir -p "$(dirname "$processingPath/$fileName")"
mv "$fullPath" "$processingPath/$fileName"

outputFile="$outputPath/$fileName"
outputFile=${outputFile/.webm/.mp4}
outputFile=${outputFile/.avi/.mp4}
outputFile=${outputFile/.mkv/.mp4}
startTime=$(date +%s)
mkdir -p "$(dirname "$outputFile")"
echo '['$(date '+%Y-%m-%d %I%M.%S%p')']' "started processing "\'"$fileName"\' | tee -a "$logFile"
ffmpeg -nostdin -i "$processingPath/$fileName" -y $ffmpegOptions "$outputFile"
if [ $? -eq 0 ]
then
    endTime=$(date +%s)
    echo '['$(date '+%Y-%m-%d %I%M.%S%p')']' succesfully created \'"$fileName"\' | tee -a "$logFile"
    mkdir -p "$(dirname "$originalsPath/$fileName")"
    mv "$processingPath/$fileName" "$originalsPath/$fileName"
    secondCount=$(($endTime-$startTime))
    if [ $secondCount -gt 300 ]
    then
        timeDesc="$(($secondCount / 60)) minutes"
    else
        timeDesc="$(($secondCount)) seconds"
    fi
    echo took $timeDesc, original size: $(du -h "$originalsPath/$fileName" | cut -f1), encoded size: $(du -h "$outputFile" | cut -f1) | tee -a "$logFile"
else 
    endTime=$(date +%s)
    echo '['$(date '+%Y-%m-%d %I%M.%S%p')']' FAILURE processing \'"$fileName"\' after $(($endTime-$startTime)) seconds | tee -a "$logFile"
    mkdir -p "$(dirname "$failuresPath/$fileName")"
    mv "$processingPath/$fileName" "$failuresPath/$fileName"
fi
rm $tempFile
cd $inputPath
find . -type d -empty -delete