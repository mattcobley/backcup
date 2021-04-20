#! /bin/bash

# TODO: delete in destination, compression, exclude and include files. Pass through to rsync?

SUFFIX=$(date '+%Y_%m_%d-%H_%M_%S')
BACKUP_LOG_FILE_NAME="./backup-log-${SUFFIX}.log"
touch "${BACKUP_LOG_FILE_NAME}"

function output_to_console_and_log {
    echo "$1" 2>&1 | tee -a "${BACKUP_LOG_FILE_NAME}"
}

function get_json_array {
    readarray -t file_array <<<"$1"
    joined_files=$(printf ",\"%s\"" "${file_array[@]}")
    echo "[${joined_files:1}]"
}

while getopts b:s:d: flag
do
    case "${flag}" in
        b) output_to_console_and_log "Setting backup directory to ${OPTARG}"; BACKUP_DIR=${OPTARG};;
        s) output_to_console_and_log "Setting source directory to ${OPTARG}"; SOURCE=${OPTARG};;
        d) output_to_console_and_log "Setting destination directory to ${OPTARG}"; DEST=${OPTARG};;
        *) output_to_console_and_log "Flag ${flag} is invalid";; # TODO: Echo help from here
    esac
done

files=$(rsync -avb --backup-dir="${BACKUP_DIR}-${SUFFIX}" "${SOURCE}" "${DEST}" \
    2>&1 | tee -a "${BACKUP_LOG_FILE_NAME}" \
    | sed -n '/sending incremental file list/,$p' \
    | sed '1d' \
    | head -n -3)

get_json_array "$files"

# TODO: curl from here to the API

#./backup.sh -b /mnt/c/Users/mattc/source/test-backup/backup-1 -s /mnt/c/Users/mattc/source/test-backup/my-folder/ -d /mnt/c/Users/mattc/source/test-backup/my-dest

# Main copy of files is latest copy, and the dated backup is the OLDER version of changed files. How do we ensure that we reference the correct date when looking at available backups?

