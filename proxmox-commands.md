# proxmox commands

## hdd passthrough
```bash
find /dev/disk/by-id/ -type l|xargs -I{} ls -l {}|grep -v -E '[0-9]$' |sort -k11|cut -d' ' -f9,10,11,12
```
find the devices, similar to `ls -l /dev/disk/by-id/`, but only shows relevant devices (not sure of specifics)

```bash
qm set 100 -scsi1 /dev/disk/by-id/usb-TOSHIBA_MQ01ABD100_235678C218CA-0:0
```
using output of prior command, sets a device to be passthrough for VM with ID 100. Replace `scsi1` with `scsi2` if 1 is already used, and so on.


### LXC
you can't get direct access to the device, but you can mount it on the host, and pass through using:

```
mp0: /mnt/myDrive,mp=/mnt/myDrive
```
inside the `/etc/pve/lxc/1xx.conf` file. Not sure of the other



## TPU passthrough in LXC

this took a while to figure out, but here's what's needed

```
//"xc.apparmor.profile: unconfined" is needed to prevent docker service from failing
//"lxc.cap.drop:" is needed to get the frigate container to not immediately exit
//and the first 2 items are needed to get the 
lxc.cgroup2.devices.allow: a
lxc.mount.entry: /dev/apex_0 dev/apex_0 none bind,optional,create=file 0, 0
lxc.apparmor.profile: unconfined
lxc.cap.drop:
```
...inside the `/etc/pve/lxc/1xx.conf`

explanation:

"xc.apparmor.profile: unconfined" is needed to prevent docker service from failing
"lxc.cap.drop:" is needed to get the frigate container to not immediately exit
and the first 2 items are needed to get the 

