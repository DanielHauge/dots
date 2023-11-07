#!/bin/bash

mvrs() {
	for file in *; do
		newFile=$(echo $file | sed "s/\[//g" | sed "s/\]//g" | sed "s/ //g")

		mv "$file" "$newFile"
	done
}
