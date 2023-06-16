# zfs commands

install the apt `zfsutils-linux`, sometimes requires zfs-dkms 

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
zpool export main
zpool import -d /dev/disk/by-partuuid main
```
changes how the zpool identifies the disks to use by-partuuid
