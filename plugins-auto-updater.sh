#!/usr/bin/bash

PLUGIN_DIR="./plugins"
SERVER_VER="26.3"
PLUGINS=$(ls $PLUGIN_DIR | grep ".jar")
#($(find $PLUGIN_DIR -maxdepth 1 -type f))
PLUGINS_NUM=${#PLUGINS[@]}

MODRINTH_API_URL="https://api.modrinth.com/v2"
USER_AGENT="User-Agent: macto3001's plugins auto updater (tomdelahautemaison@gmail.com)"

if ! [ $PLUGINS_NUM -ge 1 ]; then
	echo "no plugins found, nothing done"
	exit 0
fi

for PLUGIN in $PLUGINS; do
	PLUGIN_NAME=$(echo $PLUGIN | cut -d '-' -f 1)
	PLUGIN_LOADER=$(echo $PLUGIN | cut -d '-' -f 2)
	PLUGIN_VER=$(echo $PLUGIN | cut -d '-' -f 3)
	echo $PLUGIN
	echo $PLUGIN_NAME
	echo $PLUGIN_LOADER
	echo $PLUGIN_VER
	RESPONSE=$(curl -G -A "$USER_AGENT" "$MODRINTH_API_URL/project/$PLUGIN_NAME/version" \
	--data-urlencode "loaders=[\"$PLUGIN_LOADER\"]" --data-urlencode "game_versions=[\"$SERVER_VER\"]")
	echo $RESPONSE | jq .
	#https://cdn.modrinth.com/data/9eGKb6K1/versions/5OqsnSs7/voicechat-bukkit-2.6.25.jar?mr_download_reason=standalone&mr_game_version=26.3&mr_loader=paper
done