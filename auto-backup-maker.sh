#!/usr/bin/bash

BACKUP_DIR="backups/$(basename $PWD)/"
SERVER_DIR="$(basename $PWD)"
SILENT=false
COPY=false

while getopts "B:S:csh" option; do
	case "${option}" in
		B)BACKUP_DIR=${OPTARG};;
		S)SERVER_DIR=${OPTARG};;
		c)COPY=true;;
		s)SILENT=true;;
		h)
			echo "usage: $0 \
			[-B <bachup_file_path>] [-S <server_file_path>] [-c (copy)] [-s (silent)] [-h (help)]"
			exit 1
			;;
	esac
done

cd ..

# if server directory not found
if [ ! -e $SERVER_DIR ]; then
	echo "error: server directory not found ($SERVER_DIR)"
	exit 2
fi

# if backup directory not found
if [ ! -e $BACKUP_DIR ]; then
	mkdir -p $BACKUP_DIR
fi

if [ $SILENT == false ]; then
	echo "making backup"
fi

if [ COPY == true ]; then
	cp -br $SERVER_DIR $BACKUP_DIR # if copy
else
	tar -czf $BACKUP_DIR/$SERVER_DIR.tar.gz $SERVER_DIR # if compressed backup
fi

if [ $SILENT == false ]; then
	echo "backups done (saved in ../$BACKUP_DIR)"
fi
