#! /bin/bash

# TODO: delete in destination, compression, exclude and include files. Pass through extra args to rsync?

SUFFIX=$(date '+%Y_%m_%d-%H_%M_%S')
BACKUP_LOG_FILE_NAME="./backup-log-${SUFFIX}.log"
touch "${BACKUP_LOG_FILE_NAME}"

function output_to_console_and_log {
    echo "$1" 2>&1 | tee -a "${BACKUP_LOG_FILE_NAME}"
}

function get_json_array {
    readarray -t file_array <<<"$1"

    if [ ${#file_array[@]} -eq 0 ]; then
        echo "[]"
    else
        joined_files=$(printf ",{\"Path\":\"%s\"}" "${file_array[@]}")
        echo "[${joined_files:1}]"
    fi
}

while getopts b:s:d:a: flag
do
    case "${flag}" in
        b) output_to_console_and_log "Setting backup directory to ${OPTARG}"; BACKUP_DIR=${OPTARG};;
        s) output_to_console_and_log "Setting source directory to ${OPTARG}"; SOURCE=${OPTARG};;
        d) output_to_console_and_log "Setting destination directory to ${OPTARG}"; DEST=${OPTARG};;
        a) output_to_console_and_log "Setting API URL to ${OPTARG}"; API_URL=${OPTARG};;
        *) output_to_console_and_log "Flag ${flag} is invalid";; # TODO: Echo help from here
    esac
done

FULL_BACKUP_DIR="${BACKUP_DIR}-${SUFFIX}"

FILES=$(rsync -avb --backup-dir="${FULL_BACKUP_DIR}" "${SOURCE}" "${DEST}" \
    2>&1 | tee -a "${BACKUP_LOG_FILE_NAME}" \
    | sed -n '/sending incremental file list/,$p' \
    | sed '1d' \
    | head -n -3)

echo "FILES: $FILES"

FILES_JSON=$(get_json_array "$FILES")

echo "Files copied: $FILES_JSON"

# TODO: Get username and pwd from arguments? Prompt for password?
USERNAME=test-user
DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_NAME="${FULL_BACKUP_DIR}"

# TODO: Remove --insecure
RESULT=$(curl --header "Content-Type: application/json" \
  --insecure \
  --request POST \
  --data "{ \
      \"User\":\"${USERNAME}\", \
      \"Name\":\"${BACKUP_NAME}\", \
      \"DateTime\":\"${DATETIME}\", \
      \"Files\":${FILES_JSON} \
    }" \
  "${API_URL}")

echo "$RESULT"
# Main copy of files is latest copy, and the dated backup is the OLDER version of changed files. How do we ensure that we reference the correct date when looking at available backups?

