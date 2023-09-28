#!/bin/bash

tex() {
	if [ $# -eq 0 ]; then
		local file=$(ls *.tex | head -n 1)
		buildtex $file

	elif [ $# -eq 1 ]; then

		if [ $1 == "-h" ]; then
			echo "Usage: tex [file.tex]"
			return 1
		fi

		local file=$1
		buildtex $file

	else
		echo "Usage: tex [file.tex]"
		return 1
	fi
}

buildtex() {
	if [ $# -eq 0 ]; then
		echo "Usage: easy-tex template.tex"
		return 1
	fi
	local pdf_file=${1%.*}.pdf
	pdflatex --shell-escape $1 && latexmk -c && x $pdf_file
}
