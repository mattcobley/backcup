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

FILES=$(rsync -avb --no-perms --no-owner --no-group --backup-dir="${FULL_BACKUP_DIR}" "${SOURCE}" "${DEST}" \
    2>&1 | tee -a "${BACKUP_LOG_FILE_NAME}" \
    | sed -n '/sending incremental file list/,$p' \
    | sed '1d' \
    | head -n -3)

if [ $? -eq 0 ]; then
  echo "Rsync success"
else
  echo "Rsync fail"
  exit
fi

# Remove entries where the output for a specific file is an rsync message such as "permission denied"
FILTERED=$(echo "$FILES" | grep -v "rsync")
echo "FILES WITH FILTER: $FILTERED"

FILES_JSON=$(get_json_array "$FILTERED")

echo "Files copied: $FILES_JSON"

# TODO: Get username and pwd from arguments? Prompt for password?
USERNAME="$USER"
DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_NAME="${FULL_BACKUP_DIR}"

printf '{
  "User":"%s",
  "Name":"%s",
  "DateTime":"%s",
  "Files":%s
}' "${USERNAME}" "${BACKUP_NAME}" "${DATETIME}" "${FILES_JSON}" > "backup-temp.json"

# TODO: Remove --insecure
RESULT=$(curl --header "Content-Type: application/json" \
  --insecure \
  --request POST \
  --data @backup-temp.json \
  "${API_URL}")

echo "$RESULT"
# Main copy of files is latest copy, and the dated backup is the OLDER version of changed files. How do we ensure that we reference the correct date when looking at available backups?

