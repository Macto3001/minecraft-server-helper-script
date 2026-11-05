project_file=$(jq -r . project-list.json)
modrinth_api="https://api.modrinth.com/v2"
user_agent="Macto3001's modrinth downloader (tomdelahautemaison@gmail.com)"


minecraft_version=$(echo $project_file | jq -r .minecraft_version)
projects=$(echo $project_file | jq -r .projects)
projects_list=$(echo $projects | jq -r "keys[]")

for project in $projects_list; do
	project_name=$(echo $projects | jq -r ".$project.name")
	project_loader=$(echo $projects | jq -r ".$project.loader")
	project_version=$(echo $projects | jq -r ".$project.version")

	response=$(curl -sGA "$user_agent" "$modrinth_api/project/$project_name/version" \
	--data-urlencode "loaders=[\"$project_loader\"]" \
	--data-urlencode "game_versions=[\"$minecraft_version\"]")

	latest_version=$(echo $response | jq -r ".[0].version_number" | cut -d "-" -f 2)	
	echo $latest_version
done

echo 1 $minecraft_version
echo 2 $projects
echo 3 $projects_list