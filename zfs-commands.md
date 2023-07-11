# zfs commands

requires the apt `zfsutils-linux`, which sometimes requires zfs-dkms 

```bash
ls -l /dev/disk/by-id
ls -l /dev/disk/by-partuuid
```
lists the ids of each device


```bash
zpool status
```
lists the pools


```bash
zpool create myPoolName deviceId1 deviceId2 deviceIdn
```
creates a stripped pool for n devices AKA raid0 AKA zero redundancy


```bash
zpool create myPoolName mirror deviceId1 deviceId2 deviceIdn
```

creates a mirrored pool for n devices AKA raid1


## Create filesystem AKA dataset

```bash
zfs list
```

shows all the filesystem. Seems to incorrectly display a manual unmount

```bash
zfs create myPoolName/datasetName
```

creates a dataset. You can also include the arg `-o mountpoint=/mnt/mountpoint`, but these seems pointless


```bash
zfs destroy  myPoolName/datasetName
```

destroyes the dataset. Sometimes it doesn't work and I reboot

```bash
zpool import
```

lists the pools that could be imported

```bash
zpool import myPoolName
```
will import that pool if it was in the `zpool import`. May ask for force option `-f`


```bash
zpool replace myPoolName deviceId1 deviceId2
```
When deviceId1 is missing from a pool, will replace it with deviceId2


```bash
zpool export myPool
zpool import -d /dev/disk/by-partuuid myPool
```
changes how the zpool identifies the disks to use by-partuuid

## Snapshots

```bash
zfs list -t snapshot
```
lists the snapshots


```bash
zfs snapshot myPoolName/datasetName@snapshotName
```
creates a snapshot


```bash
mount -t zfs myPoolName/datasetName@snapshotName /mnt/myPath
```

```bash
for mountpath in `cat /proc/mounts | grep /mnt/snapshots | cut -d ' ' -f 2`; do umount $mountpath; done
```
unmounts everything the `grep` doesn't filter out, in this case just /mnt/snapshots


```bash
for snapshot in `zfs list -H -t snapshot| cut -f 1`; do  sudo zfs destroy $snapshot; done
```
destroys all snapshots


## zfs-snapshot-rotate.sh

my [zfs-snapshot-rotate.sh](scripts/zfs-snapshot-rotate.sh) script auto-creates snapshots. 

Snapshots will be named in the format `YYYY-MM-DD_HHmm_taskName`, and they will be mounted to a folder with that same name. Snapshots are destroyed not on a time-basis, but on a count basis, which is where `keepCount` is used. With proper crontab setup, you can effectively have a snapshot auto-expire after some time. 

I use the following crontab:

```
*/20 1-23/2 * * * /usr/local/bin/snapshot-rotate.sh freq 5 main/Media main/Cloud main/NotCloud
20,40 */2 * * * /usr/local/bin/snapshot-rotate.sh freq 5 main/Media main/Cloud main/NotCloud
0 2-22/2 * * * /usr/local/bin/snapshot-rotate.sh hour 11 main/Media main/Cloud main/NotCloud
0 0 * * * /usr/local/bin/snapshot-rotate.sh daily 7 main/Media main/Cloud main/NotCloud
```
my crontab config to use my `zfs-snapshot-rotate.sh`` script. 
* runs the freq at 00:20,00:40,01:00,01:20,01:40,2:20, etc. 
* runs the hour at 02:00,04:00,06:00,08:00,10:00,12:00,14:00, etc.
* runs the daily at 00:00 each day.

