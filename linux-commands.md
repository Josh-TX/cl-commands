# Linux Commands

for now I just use ubuntu server. Not sure how distro-specific these commands are atm.

## SSH
### SSH - Secure Shell
```bash
ssh username@192.168.1.1
```

connects to the server

```bash
ssh target_name
```

connects to the server defined in the following config file in your .ssh folder
```
# comment
Host target_name
  HostName 192.168.1.1
  User username
  Port 22
  IdentityFile targetName_key
```

### ssh-keygen

```bash
ssh-keygen
```

generates a public/private RSA key pair, and stores them in the  .ssh folder. The public key will have .pub appended to the filename

```bash
ssh-keygen -t ed25519 -C myMachineName -f ~/.ssh/targetName_key
```

the options do the following:
* uses ed25519 instead of rsa. It's more secure, and the public key is shorter, making the target's authorized_keys cleaner
* overrides the default comment (appended to the public key) with "myMachineName". 
* specifies the output file, so that you don't accidentally create the default ed25519_id

### ssh-copy-id

```bash
ssh-copy-id -i ~/.ssh/targetName_key.pub username@192.168.1.1
```

copies the content of the file (should specify a public key) to the remote server's ~/.ssh.authorized_keys file. You can replace `username@192.168.1.1` with a hostname from your config if you've already got that.

## Bash Init

upon ssh login, it'll auto-run `~/.bash_profile`. The `bash` command itself will run `~/.bashrc`, but this doesn't happen on ssh login.

### Aliases and prompt

Ubuntu server's `~/.bashrc` will execute `~/.bash_aliases` if it exists, so there might be some convention to putting aliases there.

```bash
wget -q https://github.com/Josh-TX/cl-commands/raw/main/bash-aliases.sh -O ~/.bash_aliases; source ~/.bash_aliases
```

this loads all my aliases into `~/.bash_aliases` and runs them. All that's left is to ensure `~/.bash_profile` includes `source ~/.bash_aliases`

```bash
wget -q https://github.com/Josh-TX/cl-commands/raw/main/bash-prompt.sh -O ~/.bash_prompt; source ~/.bash_prompt
```

this creates a different bash prompt. like above, make sure `~/.bash_profile` includes `source ~/.bash_prompt`

```bash
echo $'source ~/.bash_aliases\nsource ~/.bash_prompt' > ~/.bash_profile
```

this overrides the existing `.bash_profile` with 2 lines that run `.bash_prompt` and `.bash_aliases`

## Drives and Storage

## lsblk - List Block

```bash
lsblk
```

shows the storage devices

### fdisk - file disk

```bash
sudo fdisk -l
```

shows details of the storage devices and partitions

```bash
sudo fdisk /dev/sda
```

starts an interactive command line for creating or deleting partitions on the storage device sda
You can then enter the following commands
* `m` - help
* `p` - list partitions
* `g` - create a GPT disk label (often needed before you partition)
* `n` - create new parition. You can use default for further prompts, and tyoe yes to remove signature
* `d` - delete partition (if there's multiple it'll ask for a number)
* `w` - write. This is basically the save changes command 

### mkfs - make filesystem

```bash
sudo mkfs.ext4 /dev/sda1
```

makes a file system a the partition sda1 (not device).

### df - disk file

```bash
df -h
```

shows the space used/available on mounted partitions

### mount

```bash
sudo mount /dev/sda1 /mnt/disk1/
```

mounts the partition sda1 to directory /mnt/disk1. /mnt/dirName is recommended for permanent mounts, whereas /media/dirName is recommended for temporary 

### umount - unmount (but spelled without n)

```bash
sudo umount /dev/sda1
```

unmounts the specified partition, making it safe to eject

### hdparm

```bash
hdparm
```

## Misc

may recategorize later

### symlinks

```bash
ln -s /target/path myFile
```
creates a symlink named myFile that references /target/path


### scp

```bash
scp filename.txt host:path
```

If path is a directory in the host's home directory, then `filename.txt` will be created within the `path` directory. Otherwise, it'll create/replace a file in the home directory called `path`. 

### rsync

```
rsync -a host:/source/path /local/destination/path
```

compares the source path to the destination path, and copies over missing files.
additional options. In this example, "host" is a host defined in the ssh config
* `-a` applies a bunch of common options. Notably makes it recursive
* `-v` verbose, outputs a line for each file being transferred
* `--stats` similar to verbose, but shows aggregate information, not individual files
* `--dry-run` no files are copied, but can be used with -v or --stats to test what would happen

### crontab

```bash
crontab -l
```

lists the crontab for the current user

```bash
crontab -e
```

edits the crontab for the current user. Comment at the bottom shows the syntax

## Users

I have aliases `u` and `g` for listing nonsystem users and groups

```bash
getent passwd
```
lists all users, but most will be system users. Alternative: `cat /etc/passwd`
format is username:password(x):userId:PrimaryGroupId:UserComment:HomeDirectory:DefaultShell

```bash
getent passwd | tr ":" " " | awk "\$3 >= 1000 { print \$1 \"\t\" \$4 }" | sort | uniq
```
lists usernames with an id >= 1000, excluding most system users

```bash
getent group
```

lists groups, and for each group lists users in the group. Alternative: `cat /etc/passwd`

format is groupName:password(x):userId:PrimaryGroupId:UserComment:HomeDirectory:DefaultShell

```bash
getent group | tr ":" " " | awk "\$3 >= 1000 { print \$1 \"\t\" \$4 }"
```
lists non-system groups (id >= 1000)

```bash
sudo useradd -m -s /bin/bash myUser
```
creates a new user named myUser. `-m` adds a home directory, and the -s sets the user's shell to bash. You can use `useradd -M -s /bin/false myUser` to have no home directory and no shell (can't login).

```bash
sudo userdel -rfRZ myUser
```
deletes a user. `-r` deletes the home directory, `-RZ` are for more cleanup. Don't worry about the mail spool

```bash
sudo groupadd myGroup
```
creates new group myGroup

```bash
sudo usermod -a -G myGroup myUser
```
adds myUser to myGroup. `sudo` is a group, so this syntax can add the user to that group too. Also `sudo usermod -g myGroup myUser` to update the primary group

```bash
sudo gpasswd --delete myUser myGroup
```
removes myUser from myGroup. You can also use `usermod -G "" myUser` to remove myUser from all secondary groups


```bash
sudo passwd myUser
```

updates the password for myUser. Just `passwd` updates the password for the current user (careful with sudo)

```bash
groups myUser
```
lists the groups that myUser is in. Just `groups` lists the groups that the current user is in

## Permissions

```bash
sudo chmod -R ug+rwX,o+rX,o-w path
```
recursively modifies permissions for the `path` directory and all its contents. The capital `X` means to only add executable to directories, not files 

```bash
sudo chown -R myUser:myGroup path
```
recursively sets the owner and/or group for the `path` directory and all its contents. Use `myUser` to just set the owner, or `:myGroup` to just set the group. There's also `chgrp -R myGroup path` which might be more appropriate. You can end the path with `/*` and it'll recursively affect all files but not the parent directory

## Samba Server

These commands require `samba installed. samba users (smbpasswd) are different from linux users (passwd), but samba users are always tied to a linux user.

```bash
sudo pdbedit -L
```
lists samba users

```bash
sudo smbpasswd -a myUser
```
creates a samba user named myUser. This will fail if myUser isn't already a linux user (passwd)

```bash
sudo smbpasswd -x myUser
```
deletes a samba user named myUser

```bash
sudo smbstatus
```

lists active samba connections.

```
[global]
server string = my file server
workgroup = my workgroup
server role = standalone server
security = user
map to guest = Bad User
name resolve order = bcast host
unix password sync = yes
passwd program = /usr/bin/passwd %u
passwd chat = "*New Password:*" %n\n "*Reenter New Password:*" %n\n "*Password changed.*"
pam password change = yes

# these settings are often not in global, but they seem like good defaults
browsable = yes
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775

# includes

include = /etc/samba/share.conf
#include = /etc/cockpit/zfs/shares.conf
```
This is the global config located in `/etc/samba/smb.conf`. I commented out cockpit's zfs shares, since I want to handle that myself. The remaining shares are defined in share.conf

Below are example shares that could either be at the end of smb.conf or referenced in an `include`

```
[FolderName]
guest ok = yes
path = /main/Media
force user = myUser
read only = yes
```
This share does not require the client's credentials, and instead all connections use myUser's permissions. Note that myUser does not have to be a samba user, just a linux user.

```
[FolderName]
path = /path/to/files
read only = no
valid users = @group
create mask = 0644
force create mode = 0644
directory mask = 0755
force directory mode = 0755
```
This share doesn't have `force user`, meaning the client must provide credentials. This also overrides the global mask so that created files will not have group write permission

## Samba client

These commands require `cifs-utils` installed.

```bash
sudo mount -t cifs -o username=myUser,password=myPass //192.168.0.0/myShare /mnt/myShare
```
this mounts the samba share

```
//192.168.20.25/Media   /mnt/media      cifs    password=,nofail,x-systemd-timeout=5s   0       0
```
here's my fstab config that finally worked

## Find

```bash
find . -name myFileName
```
searches the current director and subdirectories for myFileName. 