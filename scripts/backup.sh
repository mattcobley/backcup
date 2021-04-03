#! /bin/bash


# Take as params to script:
# backup dir, source, dest, delete in destination, include root directory in backup(adds trailing slash), compression?

rsync -aPvb --backup-dir= source/ dest

