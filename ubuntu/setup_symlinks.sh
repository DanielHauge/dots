#!/bin/bash
(
    cd $XDG_CONFIG_HOME


    ln -sf "$DOTS_LOC"/config/nvim nvim
    for file in "$DOTS_LOC"/config/*; do
        ln -sf $file $(basename $file)
    done
)
