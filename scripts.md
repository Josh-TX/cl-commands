# scripts

Here's where I'll explain what my scripts do, since I wanted to keep the files themselves clean

## bash-aliases.sh

contains my aliases, designed to run on ubuntu server 22.04

## bash-prompt.sh

my bash prompt... sometimes it messes up, but I still like it

## re-encode-process.sh

uses ffmpeg to re-encode all video files (mp4, avi, webm) in a directory. The intent is to have crontab run this every minute, allowing you to re-encode files merely by placing them in the input directory. The only complicated part is making sure all the different directories are set up. It should work even with a nested folder structure placed in the to-process directory. 

## zfs-snapshot-rotate.sh

Creates and mounts zfs snapshots. Also unmounts & destroys old snapshots. usage: `zfs-snapshot-rotate.sh taskName keepCount myFilesystem1 [myFilesystem2] [etc]`
Snapshots will be named in the format `YYYY-MM-DD_HHmm_taskName`, and they will be mounted to a folder with that same name. Snapshots are destroyed not on a time-basis, but on a count basis, which is where `keepCount` is used. With proper crontab setup, you can effectively have a snapshot auto-expire after some time. 

 I explain my own crontab utilizing this in [zfs-commands.md]
