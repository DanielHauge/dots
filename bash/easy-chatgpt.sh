#!/bin/bash

function chatgpt() {
	if [ -z "$OPENAI_API_KEY" ]; then
		echo "OPENAI_API_KEY is not set"
		return 1
	fi
	if [ -z "$1" ]; then
		echo "Usage: chatgpt <prompt>"
		return 1
	fi
	resp=$(curl https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$(echo '{"model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are an assistant, skilled in linux and bash, and prefer short one liners in the terminal over a big program."
      },
      {
        "role": "user",
        "content": "¤"
      }
    ]
    }' | sed -e "s/¤/$1/g")")
	echo "$resp"
}
