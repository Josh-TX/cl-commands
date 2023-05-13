# Linux Commands

for now I just use ubuntu server. Not sure how distro-specific these commands are atm.

## SSH
### ssh - Secure Shell
`ssh username@192.168.1.1`
connects to the server

`ssh target_name`
connects to the server defined in the following config file in your .ssh folder
```
# comment
Host target_name
  HostName 192.168.1.1
  User username
  Port 22
  IdentityFile target_name_key
```

### ssh-keygen
`ssh-keygen`
generates a public/private RSA key pair, and stores them in the  .ssh folder. The public key will have .pub appended to the filename

`ssh-keygen -t ed25519 -C myMachineName -f ~/.ssh/targetName_key`
the options do the following:
* uses ed25519 instead of rsa. It's more secure, and the public key is shorter, making the target's authorized_keys cleaner
* overrides the default comment (appended to the public key) with "my_machineName". 
* specifies the output file, so that you don't accidentally create the default ed25519_id

### ssh-copy-id
`ssh-copy-id -i ~/.ssh/targetName_key.pub username@192.168.1.1`
copies the content of the file (should specify a public key) to the remote server's ~/.ssh.authorized_keys file

## Bash Init

upon ssh login, it'll auto-run `~/.bash_profile`. The `bash` command itself will run `~/.bashrc`, but this doesn't happen on ssh login.

### Aliases

Ubuntu server's `~/.bashrc` will execute `~/.bash_aliases` if it exists, so there might be some convention to putting aliases there.

`wget -q https://github.com/Josh-TX/cl-commands/raw/main/bash-aliases.sh -O ~/.bash_aliases; source ~/.bash_aliases`

this loads all my aliases into `~/.bash_aliases` and runs them. All that's left is to ensure `~/.bash_profile` includes `source ~/.bash_aliases`

### Prompt

`wget -q https://github.com/Josh-TX/cl-commands/raw/main/bash-prompt.sh -O ~/.bash_prompt; source ~/.bash_prompt`

this creates a different bash prompt. like above, make sure `~/.bash_profile` includes `source ~/.bash_aliases`

## Drives and Storage

## lsblk - List Block
`lsblk`
shows the storage devices

### fdisk - file disk
`sudo fdisk -l`
shows details of the storage devices and partitions

`sudo fdisk /dev/sda`
starts an interactive command line for creating partitions on the storage device sda
You can then enter the following commands
* `m` - help
* `g` - create a GPT disk label (often needed before you parition)
* `n` - create new parition. You can use default for further prompts, and tyoe yes to remove signature
* `w` - write. This is basically the save changes command 

### mkfs - make filesystem
`sudo mkfs.ext4 /dev/sda1`
makes a file system a the partition sda1 (not device).

### df - disk file
`df -h`
shows the space used/available on storage devices

### mount
`sudo mount /dev/sda1 /mnt/disk1/`
mounts the partition sda1 to directory /mnt/disk1. /mnt/dirName is recommended for permanent mounts, whereas /media/dirName is recommended for temporary 

### umount - unmount (but spelled without n)
`sudo umount /dev/sda1`
unmounts the specified partition, making it safe to eject

### hdparm
`hdparm`

## rsync
`rsync -a host:/source/path /local/destination/path`
compares the source path to the destination path, and copies over missing files.
additional options. In this example, "host" is a host defined in the ssh config
* `-a` applies a bunch of common options. Notably makes it recursive
* `-v` verbose, outputs a line for each file being transferred
* `--stats` similar to verbose, but shows aggregate information, not individual files
* `--dry-run` no files are copied, but can be used with -v or --stats to test what would happen


# PS