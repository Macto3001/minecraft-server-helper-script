#!/usr/bin/bash

BACKUP_DIR="../backups/$(basename $PWD)/"
SERVER_DIR="."
SILENT=false

while getopts "B:S:sh" option; do
	case "${option}" in
		B)BACKUP_DIR=${OPTARG};;
		S)SERVER_DIR=${OPTARG};;
		s)SILENT=true;;
		h)
			echo "usage: $0 \
			[-B <bachup_file_path>] [-S <server_file_path>] [-s (silent)] [-h (help)]"
			exit 1
			;;
	esac
done

# if server directory not found
if [ ! -e $SERVER_DIR ]; then
	echo "error: server directory not found ($SERVER_DIR)"
	exit 2
fi

# if backup directory not found
if [ ! -e $BACKUP_DIR ]; then
	mkdir -p $BACKUP_DIR
fi

if [ ! $SILENT ]; then
	echo "making backup"
fi

cp -br $SERVER_DIR $BACKUP_DIR

if [ ! $SILENT ]; then
	echo "backups done (saved in $BACKUP_DIR)"
fi
