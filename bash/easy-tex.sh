#!/bin/bash

tex() {
    if [ $# -eq 0 ]; then
        local file=$(ls *.tex | head -n 1)
        buildtex "$file"
        local pdf_file=${file%.*}.pdf
        x "$pdf_file"

    elif [ $# -eq 1 ]; then

        if [ "$1" == "-h" ]; then
            echo "$1"
            echo "Usage: tex [file.tex]"

            return 1
        fi

        if [ $1 == "-toc" ]; then
            local file=$(ls *.tex | head -n 1)
            buildtex-toc "$file"
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
    await_modify_entity=$1
    buildfile=$2
    if [ $# -eq 0 ]; then
        await_modify_entity=$(ls *.tex | head -n 1)
        buildfile=$await_modify_entity
    fi

    # If second argument is not provided, then use the first argument
    if [ $# -eq 1 ]; then
        buildfile=$await_modify_entity
    fi

    local pdf_file=${buildfile%.*}.pdf
    buildtex "$buildfile"
    x "$pdf_file"

    # Await loop with modify not using notifywait
    while true; do
        await-modify .
        clear_console
        buildtex "$buildfile"
    done

}

buildtex() {
    if [ $# -eq 0 ]; then
        echo "Usage: easy-tex template.tex"
        return 1
    fi

    # pdflatex --shell-escape --interaction=nonstopmode "$1" && latexmk -c
    # xelatex --interaction=nonstopmode "$1" && latexmk -c
    if command -v tectonic &>/dev/null; then
        tectonic -k --keep-logs --reruns 0 "$1"
    else
        xelatex -shell-escape --interaction=nonstopmode "$1"
    fi

}

buildtex-toc() {
    if [ $# -eq 0 ]; then
        echo "Usage: easy-tex template.tex"
        return 1
    fi
    local fileNameWithoutExtension=${1%.*}
    pdflatex --shell-escape "$1" && bibtex "$fileNameWithoutExtension" && pdflatex --shell-escape "$1" && latexmk -c
}
