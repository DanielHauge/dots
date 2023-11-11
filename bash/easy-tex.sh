#!/bin/bash

tex() {
	if [ $# -eq 0 ]; then
		local file=$(ls *.tex | head -n 1)
		buildtex $file

	elif [ $# -eq 1 ]; then

		if [ $1 == "-h" ]; then
			echo "$1"
			echo "Usage: tex [file.tex]"

			return 1
		fi

		if [ $1 == "-toc" ]; then
			local file=$(ls *.tex | head -n 1)
			buildtex-toc $file
			return 0
		fi

		local file=$1
		buildtex $file

	else
		echo "Usage: tex [file.tex]"
		return 1
	fi
}

texw() {
	file=$1
	if [ $# -eq 0 ]; then
		file=$(ls *.tex | head -n 1)
	fi

	# Await loop with modify not using notifywait
	while true; do
		await-modify $file
		buildtex $file
	done

}

buildtex() {
	if [ $# -eq 0 ]; then
		echo "Usage: easy-tex template.tex"
		return 1
	fi
	local pdf_file=${1%.*}.pdf
	pdflatex --shell-escape $1 && latexmk -c && x $pdf_file
}

buildtex-toc() {
	if [ $# -eq 0 ]; then
		echo "Usage: easy-tex template.tex"
		return 1
	fi
	local pdf_file=${1%.*}.pdf
	pdflatex --shell-escape $1 && pdflatex --shell-escape $1 && latexmk -c && x $pdf_file
}
