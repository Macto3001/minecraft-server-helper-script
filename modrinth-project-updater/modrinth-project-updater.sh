# compare version, echo 1 when the first argument is greater than the second
version_gt() {
	if [ $1 == $2 ]; then
		echo 0
	fi

	greatest_version=$(echo -e "$1\n$2" | sort -V | cut -d $'\n' -f 2)
	if [ $1 == $greatest_version ]; then
		echo 1
	else
		echo 0
	fi
}

file_path="./project-list.json"
project_file=$(jq . $file_path)
modrinth_api="https://api.modrinth.com/v2"
user_agent="Macto3001's modrinth downloader (tomdelahautemaison@gmail.com)"

minecraft_version=$(echo $project_file | jq -r .minecraft_version)
projects=$(echo $project_file | jq -r .projects)
projects_list=$(echo $projects | jq -r "keys[]")

# hashmap to store project to update
declare -A to_update=()

for project in $projects_list; do
	project_id=$(echo $projects | jq -r ".$project.id")
	project_loader=$(echo $projects | jq -r ".$project.loader")
	project_version=$(echo $projects | jq -r ".$project.version")

	# get project data
	response=$(curl -sGA "$user_agent" "$modrinth_api/project/$project_id/version" \
	--data-urlencode "loaders=[\"$project_loader\"]" \
	--data-urlencode "game_versions=[\"$minecraft_version\"]")

	# filtering data for latest version
	latest_version=$(echo $response | jq -r ".[0].version_number" | cut -d "-" -f 2)

	# if current version is outdated
	if [[ $(version_gt "$latest_version" "$project_version") == 1 ]]; then
		echo "project $projects_list outdated(current: $project_version, latest: $latest_version)"

		# getting download url and the name of the project file
		download_url=$(echo $response | jq -r ".[0].files.[0].url")
		filename=$(echo $response | jq -r ".[0].files.[0].filename")
		# adding them to hashmap for updating them later
		to_update[$filename]=$download_url

		# updating $file_path's project version
		project_file=$(echo $project_file | jq ".projects.$project.version |= \"$latest_version\"")
	fi
done

# downloading new project version
echo "updating ${#to_update[@]} projects"
for i in "${!to_update[@]}"; do
	curl -A "$user_agent" "${to_update[$i]}" -o "$i"
done

# updating $file_path
echo $project_file | jq . > $file_path
echo "$file_path successfully updated"

echo "done!"