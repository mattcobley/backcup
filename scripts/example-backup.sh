#! /bin/bash

./backup.sh -b "/$HOME/test-backup/historical" \
  -s "/$HOME/test-backup/my-folder/" \
  -d "/$HOME/test-backup/my-dest" \
  -a https://localhost:5001/api/Backup
