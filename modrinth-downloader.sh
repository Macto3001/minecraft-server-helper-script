#!/usr/bin/bash

# download a modrinth project with a specific name|id, minecraft version and loader
# !require jq!
# made by Macto3001

# initiate variable
modrinth_api="https://api.modrinth.com/v2"
user_agent="Macto3001's modrinth downloader (tomdelahautemaison@gmail.com)"
filedir="./"

# help message function
usage(){
	echo -e "Usage: $0 [option]\n\
	download project from modrinth for a define version and loader\n\
	-p <project_name/id> 		define the modrinth project's name or id\n\
	-l <mod_loader> 		define the loader from which to download\n\
	-v <minecraft_version> 		define the minecraft version from which to download\n\
	-o <filename> 			define the name of the output project file\n\
	-d <directory>			define the directory where the file will be\n\
	-s 				put program in silent mode, don't output anything\n\
	-h 				show this help message and exit"

	exit 1
}

# get arguments
while getopts ":p:v:l:o:d:sh" option; do
	case "${option}" in 
		p)project=${OPTARG};;
		l)loader=${OPTARG};;
		v)version=${OPTARG};;
		o)filename=${OPTARG};;
		d)filedir=${OPTARG};;
		s)silent=true;;
		h)usage;;
	esac
done
shift $((OPTIND - 1))

# mouving output out of stdout if silent
if [[ -n $silent ]]; then
	exec >/dev/null 2>&1
fi

# no -p, -v or -l
if [ -z $project ] || [ -z $version ] || [ -z $loader ]; then
	usage
fi
# adding a / just in case
filedir+="/"

# getting project info from modrinth api with curl and jq
response=$(curl -sG -A "$user_agent" "$modrinth_api/project/$project/version" \
--data-urlencode "loaders=[\"$loader\"]" --data-urlencode "game_versions=[\"$version\"]" \
| jq ".[0].files.[0]")

# if error with url
if [[ $response == "" ]]; then
	echo "error: project, loader or version not found"
	exit 2
fi
	
# filtering download url with jq
project_url=$(echo $response | jq -r ".url")

# getting the default file name if none specified
if [ -z $filename ]; then
	filename=$(echo $response | jq -r ".filename")
fi

# download the project .jar with curl
curl "$project_url" -o "$filedir$filename" -A "$user_agent"

exit 0