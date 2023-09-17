#!/bin/bash

tex() {
    if [ $# -eq 0 ]; then
        echo "Usage: easy-tex template.tex"
        return 1
    fi
    local pdf_file=${1%.*}.pdf 
    pdflatex --shell-escape $1 && latexmk -c && x $pdf_file
}
