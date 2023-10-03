#!/bin/bash
#
eval "$(saml2aws --completion-script-bash)"
function s2a {
	saml2aws login --skip-prompt --force
	eval $($(which saml2aws) script --shell=bash --profile=$@)
	awsCurrent=$(aws iam list-account-aliases | jq -r '.AccountAliases[0]')
	export AWS_CURRENT=$awsCurrent
	export AWS_CREDENTIAL_EXPIRATION_EPOCH=$(date --date "$AWS_CREDENTIAL_EXPIRATION" +%s)
}
