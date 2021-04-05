#! /bin/bash

# TODO: delete in destination, compression, exclude and include files. Pass through to rsync?

SUFFIX=$(date '+%Y_%m_%d-%H_%M_%S')

while getopts b:s:d: flag
do
    case "${flag}" in
        b) echo "Setting backup directory to ${OPTARG}"; BACKUP_DIR=${OPTARG};;
        s) echo "Setting source directory to ${OPTARG}"; SOURCE=${OPTARG};;
        d) echo "Setting destination directory to ${OPTARG}"; DEST=${OPTARG};;
        *) echo "Flag ${flag} is invalid";; # TODO: Echo help from here
    esac
done

rsync -avb --backup-dir="${BACKUP_DIR}-${SUFFIX}" "${SOURCE}" "${DEST}"

# TODO: Take output and derive file list ready for storage (can then curl from here to the API)
# Output looks like:

# sending incremental file list
# file1.txt
# folder1/file2.txt

# sent 421 bytes  received 65 bytes  972.00 bytes/sec
# total size is 87  speedup is 0.18
