#!/bin/bash
(
    cd $XDG_CONFIG_HOME

    if [ -L ${my_link} ]; then
        if [ -e ${my_link} ]; then
        else
            echo "Broken link"
        fi
    elif [ -e ${my_link} ]; then
        echo "nvim is not a symbolic link"
    else
        ln -sf "$DOTS_LOC"/nvim nvim
    fi

    for file in "$DOTS_LOC"/.config/*; do
        ln -sf $file $(basename $file)
    done
)
