#!/bin/bash

basepath=/mnt/snapshots

if [ $# -lt 3 ]
  then
    echo "invalid arguments. Usage: prefix keepCount dataset1 [dataset2]"
    exit 1
fi
taskName=$1
keep=$2
datasets="${@:3}" #all remaining args, could be multiple
date=$(date '+%Y-%m-%d_%H%M%S')
for dataset in $datasets
do
    name=$(basename $dataset)
    mkdir -p $basepath/$name
    existingFiles=$(ls -1 $basepath/$name | grep "\_$taskName$")
    existingCount=$(echo "$existingFiles" | wc -l)
    removeCount=$(($existingCount - $keep + 1)) # +1 because we're adding one after this
    echo removing $removeCount of $existingCount
    toRemove=$(echo "$existingFiles" | head -n $removeCount)
    for file in $toRemove
    do
        fullpath=$basepath/$name/$file
        echo test $fullpath
        if mountpoint -q $fullpath
        then
            echo unmounting $fullpath
            umount -l $fullpath
        fi
        echo removing "  $fullpath"
        rmdir $fullpath
        echo destroying $dataset@$file
        zfs destroy $dataset@$file
    done
    mkdir $basepath/$name/$date_$taskName
    snapshotName=$dataset@$date_$taskName
    echo creating "  $snapshotName"
    zfs snapshot $snapshotName
    echo mounting "  $snapshotName" to $basepath/$name/$date_$taskName
    sudo mount -t zfs $snapshotName $basepath/$name/$date_$taskName
done