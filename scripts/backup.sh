#! /bin/bash

# TODO add some help information!!

# TODO: delete in destination, compression, exclude and include files. Pass through extra args to rsync?

USERNAME="$USER"
SUFFIX=$(date '+%Y_%m_%d-%H_%M_%S')
BACKUP_OUTPUT_FILE_FORMAT="backup-log-${USERNAME}-${SUFFIX}"
BACKUP_LOG_FILE_NAME="${BACKUP_OUTPUT_FILE_FORMAT}.log"
BACKUP_JSON_FILE_NAME="${BACKUP_OUTPUT_FILE_FORMAT}.json"
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

CURL_RESULTS=false

while getopts b:s:d:a:c: flag
do
    case "${flag}" in
        b) output_to_console_and_log "Setting backup directory to ${OPTARG}"; BACKUP_DIR=${OPTARG};;
        s) output_to_console_and_log "Setting source directory to ${OPTARG}"; SOURCE=${OPTARG};;
        d) output_to_console_and_log "Setting destination directory to ${OPTARG}"; DEST=${OPTARG};;
        a) output_to_console_and_log "Setting API URL to ${OPTARG}"; API_URL=${OPTARG};;
        c) output_to_console_and_log "Enabling curl of results to network location"; CURL_RESULTS=true;;
        *) output_to_console_and_log "Flag ${flag} is invalid";; # TODO: Echo help from here
    esac
done

FULL_BACKUP_DIR="${BACKUP_DIR}-${SUFFIX}"

# Create directories if they don't exist
mkdir -m 777 -p "${FULL_BACKUP_DIR}"
mkdir -m 777 -p "${DEST}"

# Run the backup
FILES=$(rsync -rtDvb --backup-dir="${FULL_BACKUP_DIR}" "${SOURCE}" "${DEST}" \
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

# For debugging
#echo "FILES WITH FILTER: $FILTERED"

FILES_JSON=$(get_json_array "$FILTERED")

# For debugging
#echo "Files copied: $FILES_JSON"

# TODO: Get username and pwd from arguments? Prompt for password?
DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_NAME="${FULL_BACKUP_DIR}"

printf '{
  "User":"%s",
  "Name":"%s",
  "DateTime":"%s",
  "Files":%s
}' "${USERNAME}" "${BACKUP_NAME}" "${DATETIME}" "${FILES_JSON}" > "${BACKUP_JSON_FILE_NAME}"

if [ $CURL_RESULTS = true ]; then
  echo "Curling results to network location at ${API_URL}"
  # TODO: Remove --insecure
  RESULT=$(curl --header "Content-Type: application/json" \
    --insecure \
    --request POST \
    --data @"${BACKUP_JSON_FILE_NAME}" \
    "${API_URL}")
else
  echo "Not curling results to network location"
  exit
fi

echo "$RESULT"
# Main copy of files is latest copy, and the dated backup is the OLDER version of changed files. How do we ensure that we reference the correct date when looking at available backups?

