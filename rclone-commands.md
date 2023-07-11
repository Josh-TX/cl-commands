```bash
rclone config
```
interactive menu for setting up remotes (remotes are connections to a backup provider like BackBlaze).

to set up encryption, first set up a normal remote, and then set up another remote of type "crypt", and reference the normal remote


```bash
rclone listremotes
```
lists all the remotes you've set up


```bash
rclone ls myRemote:myBucket
```
lists the files in myBucket (myBucket must be set up within BackBlaze). 


```bash
rclone copy /local/directory/ myRemote:myBucket
```
copies the files from the local directory to the cloud.

```bash
rclone copy myRemote:myBucket local/directory
```
copies the files from the cloud to the local directory

rclone copy /main/Cloud backblaze_encrypted:AllenBackup
