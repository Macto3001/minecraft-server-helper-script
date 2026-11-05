#!/usr/bin/bash

# be carfull server will create itself in working directory
server_dir="."

echo "before start:"
./auto-backup-maker.sh -S auto-backup-maker.sh
echo "checking for serverjar update"
./serverjar-autoupdater.sh
# echo "checking for plugins update"


echo "starting the server!👍🔥"

/usr/bin/java -Xmx16G -Xms4G -jar $server_dir/paper.jar nogui

echo "server stopped🍟"
exit 0