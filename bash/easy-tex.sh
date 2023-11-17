#!/bin/bash

tex() {
	if [ $# -eq 0 ]; then
		local file=$(ls *.tex | head -n 1)
		buildtex $file
		local pdf_file=${file%.*}.pdf
		x "$pdf_file"

	elif [ $# -eq 1 ]; then

		if [ $1 == "-h" ]; then
			echo "$1"
			echo "Usage: tex [file.tex]"

			return 1
		fi

		if [ $1 == "-toc" ]; then
			local file=$(ls *.tex | head -n 1)
			buildtex-toc $file
			local pdf_file=${file%.*}.pdf
			x "$pdf_file"
			return 0
		fi

		buildtex "$file"
		local pdf_file=${file%.*}.pdf
		x "$pdf_file"

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

	local pdf_file=${file%.*}.pdf
	buildtex "$file"
	x "$pdf_file"

	# Await loop with modify not using notifywait
	while true; do
		await-modify "$file"
		buildtex "$file"
	done

}

buildtex() {
	if [ $# -eq 0 ]; then
		echo "Usage: easy-tex template.tex"
		return 1
	fi

	pdflatex --shell-escape --interaction=nonstopmode $1 && latexmk -c

}

buildtex-toc() {
	if [ $# -eq 0 ]; then
		echo "Usage: easy-tex template.tex"
		return 1
	fi
	pdflatex --shell-escape $1 && pdflatex --shell-escape $1 && latexmk -c
}
