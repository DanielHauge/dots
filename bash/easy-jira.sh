#!/bin/bash
# GIT_BASE_URL=""
# JIRA_EMAIL="blabla@blabla.dk"
# JIRA_API_KEY=""
# JIRA_AUTH=$(echo -n "${JIRA_EMAIL}:${JIRA_API_KEY}")
# JIRA_PROJECT_KEY=""
# JIRA_SUB_DOMAIN=""

JIRA_API_VERSION="latest"
JIRA_API_URL="https://$JIRA_SUB_DOMAIN.atlassian.net/rest/api/$JIRA_API_VERSION"
JIRA_ISSUE_API_URL="$JIRA_API_URL/issue/"

# Create a new atlasian api key and insert with basic_auth https://id.atlassian.com/login?application=jira&continue=https%3A%2F%2Fid.atlassian.com%2Fmanage-profile%2Fprofile-and-visibility&prompt=none
function gnew() {
	set -e
	if ! git rev-parse --is-inside-work-tree &>/dev/null; then
		echo "Not in a git repository" >&2
		return
	fi
	mkdir -p ~/.jira
	local project_key
	local issue_number

	if [[ $1 == *-* ]]; then
		project_key=$(echo "$1" | cut -d'-' -f1)
		echo "$project_key" >~/.jira/current_project_key
		issue_number=$(echo "$1" | cut -d'-' -f2)
	elif [[ "$1" -eq "$1" ]]; then
		if [[ ! -f ~/.jira/current_project_key ]]; then
			echo "No project key found, please provide a project key: <project-key>-<number>" >&2
			return
		fi
		project_key=$(cat ~/.jira/current_project_key)
		issue_number=$1
	else
		echo "Input error, expects either: <project-key>-<number> or just <number>" >&2
		return
	fi

	echo "Creating branch for $project_key-$issue_number"

	jiraResp=$(curl -s -X GET -u "$JIRA_AUTH" -H "Content-Type: application/json" "${JIRA_ISSUE_API_URL}$project_key-$issue_number?fields=issuetype,summary")
	summary=$(echo "$jiraResp" | jq -r ."fields.summary" | awk '{print tolower($0)}' | tr -d '.' | tr -d '-' | tr ' ' '-' | tr -cd '[:alnum:]._-')
	echo "$summary"
	type=$(echo "$jiraResp" | jq -r ."fields.issuetype.name" | awk '{print tolower($0)}')
	echo "$type"
	if [[ "$summary" = "null" ]]; then
		echo "$jiraResp" | jq -r ."errorMessages"[] >&2
		return
	fi

	stash=$(git stash)
	# Find branches, return first match of: dev, develop, development, main, master
	dev_branch=$(git branch | tr '*' ' ' | sort | grep 'dev|develop|development|main|master' | head -n 1 | xargs)
	git checkout "$dev_branch"
	git pull
	local new_branch
	if [[ "$type" = "bug" ]]; then
		new_branch="fix/$project_key"-"$issue_number"-"$summary"
	else
		new_branch="feat/$project_key"-"$issue_number"-"$summary"
	fi
	if [[ $(git branch | grep "$new_branch") ]]; then
		git checkout "$new_branch"
	else
		git checkout -b "$new_branch"
	fi
	if ! [[ "$stash" = "No local changes to save" ]]; then
		git stash apply
	fi

	transitions=$(curl -s -X GET -u "$JIRA_AUTH" -H "Content-Type: application/json" "${JIRA_ISSUE_API_URL}$project_key-$issue_number/transitions")
	in_progress_id=$(echo "$transitions" | jq -r '.transitions[] | select(.name | test("progress"; "i")) | .id')
	if [[ "$in_progress_id" = "null" ]]; then
		echo "No transition to In Progress found" >&2
		return
	fi
	transition_data=$(jq -n --arg in_progress_id "$in_progress_id" '{"transition": {"id": $in_progress_id}}')
	transition_resp=$(curl -s -X POST -u "$JIRA_AUTH" -H "Content-Type: application/json" -d "$transition_data" "${JIRA_ISSUE_API_URL}$project_key-$issue_number/transitions")
	echo "$transition_resp" | jq

	comment_data=$(jq -n --arg branch "$new_branch" '{"body": "Branch created for this issue: '"$new_branch"'"}')
	comment_resp=$(curl -s -X POST -u "$JIRA_AUTH" -H "Content-Type: application/json" -d "$comment_data" "${JIRA_ISSUE_API_URL}$project_key-$issue_number/comment")
	echo "$comment_resp" | jq
}

function jira-status() {
	# Just check if a curl to jira is successful with auth token
	curl -s -X GET -u "$JIRA_AUTH" -H "Content-Type: application/json" "${JIRA_API_URL}/myself" | jq
}

function jira-to-review() {
	transitions=$(curl -s -X GET -u "$JIRA_AUTH" -H "Content-Type: application/json" "${JIRA_ISSUE_API_URL}$1/transitions")
	review_id=$(echo "$transitions" | jq -r '.transitions[] | select(.name | test("review"; "i")) | .id')
	if [[ "$review_id" = "null" ]]; then
		echo "No transition to review found" >&2
		return
	fi
	transition_data=$(jq -n --arg review_id "$review_id" '{"transition": {"id": $review_id}}')
	transition_resp=$(curl -s -X POST -u "$JIRA_AUTH" -H "Content-Type: application/json" -d "$transition_data" "${JIRA_ISSUE_API_URL}$1/transitions")
	echo "$transition_resp" | jq
}
