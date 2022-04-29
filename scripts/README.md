# Scripts

Scripts for running the backup, restore, and testing these scripts locally for development.

## Tips for running the backup script

`example-backup.sh` gives example usage.
Set the `s` argument to the source directory, i.e. the root of what you want to backup.
Set the `d` argument to the destination directory - this will be where the LATEST copy of each file will be stored.
Set the `b` argument to the backup directory. This is where changes that occur from one backup to the next are stored, and so should NOT be inside the destination directory.
