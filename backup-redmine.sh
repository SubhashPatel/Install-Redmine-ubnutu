#!/bin/bash

#######################################
# Bash script to take automatic Backup Redmine Project Management Tool in ubuntu
# Author: Subhash (serverkaka.com)

/usr/bin/mysqldump -u root -p<password> redmine_default | gzip > /path/to/backups/redmine_db_`date +%y_%m_%d`.gz
rsync -a /var/lib/redmine/default/files /path/to/backups/files
