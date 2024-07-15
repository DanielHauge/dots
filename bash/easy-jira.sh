#!/bin/bash
# GIT_BASE_URL=""
# JIRA_EMAIL="blabla@blabla.dk"
# JIRA_API_KEY=""
# JIRA_AUTH=$(echo -n "${JIRA_EMAIL}:${JIRA_API_KEY}")
# JIRA_PROJECT_KEY=""
# JIRA_SUB_DOMAIN=""

JIRA_API_VERSION="latest"
JIRA_API_URL="https://$JIRA_SUB_DOMAIN.atlassian.net/rest/api/$JIRA_API_VERSION"
JIRA_ISSUE_API_URL="$JIRA_API_URL/issue/${JIRA_PROJECT_KEY}-"

# Create a new atlasian api key and insert with basic_auth https://id.atlassian.com/login?application=jira&continue=https%3A%2F%2Fid.atlassian.com%2Fmanage-profile%2Fprofile-and-visibility&prompt=none
function gnew() {
	mkdir -p ~/.jira
	local project_key
	local issue_number

	# Check if input contains -
	if [[ $1 == *-* ]]; then
		# Extract project key from first part of input
		project_key=$(echo "$1" | cut -d'-' -f1)
		echo "$project_key" >~/.jira/current_project_key
		# Extract issue number from second part of input
		issue_number=$(echo "$1" | cut -d'-' -f2)
	elif [[ "$1" -eq "$1" ]]; then
		# Extract project key from current project
		if [[ ! -f ~/.jira/current_project_key ]]; then
			echo "No project key found, please provide a project key: <project-key>-<number>" >&2
			return
		fi
		project_key=$(cat ~/.jira/current_project_key)
		# Extract issue number from input
		issue_number=$1
	else
		echo "Input error, expects either: <project-key>-<number> or just <number>" >&2
		return
	fi

	echo "Creating branch for $project_key-$issue_number"

	local jiraResp=$(curl -s -X GET -u $JIRA_AUTH -H "Content-Type: application/json" "${JIRA_ISSUE_API_URL}$1?fields=issuetype,summary")
	# echo "$jiraResp" | jq
	local summary=$(echo "$jiraResp" | jq -r ."fields.summary" | awk '{print tolower($0)}' | tr -d '.' | tr -d '-' | tr ' ' '-' | tr -cd '[:alnum:]._-')
	echo "$summary"
	local type=$(echo "$jiraResp" | jq -r ."fields.issuetype.name" | awk '{print tolower($0)}')
	echo "$type"
	if [[ "$summary" = "null" ]]; then
		echo "$jiraResp" | jq -r ."errorMessages"[] >&2
		return
	fi

	local stash=$(git stash)
	# Find branches, return first match of: dev, develop, development, main, master
	dev_branch=$(git branch | tr '*' ' ' | sort | grep 'dev|develop|development|main|master' | head -n 1 | xargs)
	git checkout "$dev_branch"
	git pull
	local new_branch
	if [[ "$type" = "bug" ]]; then
		new_branch="fix/$JIRA_PROJECT_KEY"-"$1"-"$summary"
	else
		new_branch="feat/$JIRA_PROJECT_KEY"-"$1"-"$summary"
	fi
	# if new branch already exist just checkout, otherwise do -b
	if [[ $(git branch | grep "$new_branch") ]]; then
		git checkout "$new_branch"
	else
		git checkout -b "$new_branch"
	fi
	if ! [[ "$stash" = "No local changes to save" ]]; then
		git stash apply
	fi
}
