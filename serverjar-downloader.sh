#!/usr/bin/bash

# download a papermc ServerJar from a specific Project, Minecraft version, Build channel
# !require jq!
# SJ -> serverJar
# made by Macto3001

SJ_NAME="paper.jar"
PAPER_ADRESS="https://fill.papermc.io/v3"
USER_AGENT="macto3001's server script (tomdelahautemaison@gmail.com)"
SILENT=false

# help message function
usage() {
	echo -e "usage: $0 [option]\n\
	download a minecraft serverjar for a definied project, version and channel/build\n\n\
	-p <paper project> 	define the paper project\n\
	-v <mc-version> 	definie the minecrat version\n\
	-c <channel> 		define the build channel (can be either stable, beta or alpha)\n\
	-b <build-number>	define the build number (can be latest for latest build)\n\
	-o <serverjar name>	define the name of the serverjar output file\n\
	-s 			don't output anything to the stdout
	-h 			show this help message and exit"
	exit 1
}

# binding flags to variable
while getopts ":p:v:c:b:o:sh" option
do 
    case "${option}" in
        p)PROJECT=${OPTARG};;
        v)VERSION=${OPTARG};;
        c)CHANNEL=${OPTARG};;
    	b)BUILD=${OPTARG};;
    	o)SJ_NAME=${OPTARG};;
    	s)SILENT=true;;
        h)usage;;
        \?)echo "error: invalid option -$OPTARG"; exit 4;;
    	:)echo "error: option -$OPTARG requires an argument"; exit 4;;
    esac
done
shift $((OPTIND - 1))

# make program silent
if [ $SILENT = true ]; then
	exec >/dev/null 2>&1
fi

# ask for project, version and build channel if no flag
if [ -z $PROJECT ]; then 
	read -p "paper project?: " PROJECT
fi

if [ -z $VERSION ]; then 
	read -p "server version?: " VERSION
fi

if [ -z $CHANNEL ] && [ -z $BUILD ]; then 
	read -p "build channel?(stable/beta/alpha): " CHANNEL

# if channel and build are both defined
elif [ ! -z $CHANNEL ] && [ ! -z $BUILD ]; then
	echo "the option -c and -b cannot be used together"
	exit 2
fi

# different url and download_filter weither build or channel is used
if [ ! -z $BUILD ]; then
	URL="$PAPER_ADRESS/projects/$PROJECT/versions/$VERSION/builds/$BUILD"
	DOWNLOAD_FILTER='.downloads."server:default"'
else
	# if build channel not correct
	if [ $CHANNEL != "stable" ] && [ $CHANNEL != "beta" ] && [ $CHANNEL != "alpha" ]
	then
		echo "please select between stable, beta or alpha"
	fi

	URL="$PAPER_ADRESS/projects/$PROJECT/versions/$VERSION/builds?channel=${CHANNEL^^}"
	DOWNLOAD_FILTER='.[0].downloads."server:default"'
fi

# find correct serverJar
REPONSE=$(curl -s -H "User-Agent: $USER_AGENT" $URL)

# if error in response
if [ $(echo "$REPONSE" | jq -r '. | length') -le 3 ]; then
	ERROR_MESSAGE=$(echo $REPONSE | jq -r ".message")
	echo "error: $ERROR_MESSAGE"
	exit 3
fi

# filtering usefull data
SJ_DATA=$(echo "$REPONSE" | jq -r $DOWNLOAD_FILTER)

# download serverjar
echo "downloading $(echo $SJ_DATA | jq -r '.name')($(echo $SJ_DATA | jq -r ".size") bytes)"
curl -H "User-Agent: $USER_AGENT" $(echo $SJ_DATA | jq -r ".url") -o $SJ_NAME

echo "Done! Server jar downloaded as $SJ_NAME"
exit 0
