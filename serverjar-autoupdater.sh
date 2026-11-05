# variables
loader="paper"
api_adress="https://fill.papermc.io/v3"
user_agent="macto3001's auto updater (tomdelahautemaison@gmail.com)"

# get server version and build
version_hist=`cat ".paper/version_history.json" | jq -r '.currentVersion'`
version=`echo $version_hist | cut -d '-' -f 1`
current_build=`echo $version_hist | cut -d '-' -f 2`

# get latest build
output=`curl -s -H "User-Agent: $user_agent" "$api_adress/projects/$loader/versions/$version/builds/latest"`
latest_build=`echo "$output" | jq -r ".id"`

# download latest build
if [ $latest_build -gt $current_build ]; then
	echo "you are $[$latest_build-$current_build] build behind -> updating"
	url=`echo "$output" | jq -r '.downloads."server:default".url'`
	curl -H "User-Agent: $user_agent" $url --output paper.jar
	echo "server updated to build $latest_build"
else
	echo "build up to date"
fi