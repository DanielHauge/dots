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

	if ! [[ "$1" -eq "$1" ]]; then
		echo "error: Not a number" >&2
		return
	fi
	local jiraResp=$(curl -s -X GET -u $JIRA_AUTH -H "Content-Type: application/json" "${JIRA_ISSUE_API_URL}$1?fields=issuetype,summary")
	echo "$jiraResp"
	local summary=$(echo "$jiraResp" | jq -r ."fields.summary" | awk '{print tolower($0)}' | tr -d '.' | tr -d '-' | tr ' ' '-' | tr -cd '[:alnum:]._-')
	local type=$(echo "$jiraResp" | jq -r ."fields.issuetype.name" | awk '{print tolower($0)}')
	if [[ "$summary" = "null" ]]; then
		echo "$jiraResp" | jq -r ."errorMessages"[] >&2
		return
	fi

	local stash=$(git stash)
	git checkout main
	git pull
	if [[ "$type" = "bug" ]]; then
		git checkout -b "$JIRA_PROJECT_KEY"-"$1"-"$summary"
	else
		git checkout -b "$JIRA_PROJECT_KEY"-"$1"-"$summary"
	fi

	if ! [[ "$stash" = "No local changes to save" ]]; then
		git stash apply
	fi
}
