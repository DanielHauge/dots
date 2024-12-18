#!/bin/bash

plot() {
    # check if plot has command line arg

    if [ $# -eq 1 ]; then
        # Set output file name
        outputFile=$1
    fi
    read -r data
    cols=$(echo "$data" | wc -w)
    hasHeader=$(echo "$data" | grep -c "^[a-zA-Z]")
    headers=()
    plottingData=$(mktemp)
    if [ "$hasHeader" -eq 1 ]; then
        for i in $(seq 1 "$cols"); do
            header=$(echo "$data" | cut -d' ' -f"$i")
            headers+=("$header")
        done
    # Else use default headers
    else
        headers+=("x")
        headers+=("y")
        for i in $(seq 3 "$cols"); do
            headers+=("y$((i - 1))")
        done
        echo "$data" >>"$plottingData"
    fi
    while read -r data; do
        echo "$data" >>"$plottingData"
    done
    # terminal="windows"
    terminal="wxt"
    # terminal="gnome-terminal"
    output=""
    cat "$plottingData" >>$$.dat
    if [ -n "$outputFile" ]; then
        terminal="pngcairo"
        output="set output '$outputFile';"
    fi

    gnuplotStr="
    set title 'Plot' ; 
    set terminal $terminal dashed size 1480,1080 font 'Verdana,20';
    $output
    set xlabel '${headers[0]}' ;
    set ylabel '${headers[1]}' ; 
    set style line 2 lc rgb '#0060ad' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 3 lc rgb '#dd181f' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 4 lc rgb '#28ad3f' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 5 lc rgb '#dddd1a' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 6 lc rgb '#1adfac' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 7 lc rgb '#dd90ac' lt 2 lw 3 pt 7 ps 1.5 ;
    set grid;
    set key outside;
    plot "
    if [ "$cols" -gt 1 ]; then
        for i in $(seq 2 "$((cols))"); do
            gnuplotStr+="'$$.dat' using 1:$i with linespoints title '${headers[$i - 1]}' ls $i"
            if [ "$i" -lt "$cols" ]; then
                gnuplotStr+=", "
            fi
        done
    else
        gnuplotStr+="'$$.dat' with linespoints title '${headers[1]}' ls 2"
    fi

    echo "$gnuplotStr" | gnuplot -p
    rm $$.dat
}

plotf() {

    if [ $# -eq 1 ]; then
        # Set output file name
        outputFile=$1
    fi
    read -r data
    cols=$(echo "$data" | wc -w)
    hasHeader=$(echo "$data" | grep -c "^[a-zA-Z]")
    headers=()
    plottingData=$(mktemp)
    if [ "$hasHeader" -eq 1 ]; then
        for i in $(seq 1 "$cols"); do
            header=$(echo "$data" | cut -d' ' -f"$i")
            headers+=("$header")
        done
    # Else use default headers
    else
        headers+=("x")
        headers+=("y")
        for i in $(seq 3 "$cols"); do
            headers+=("y$((i - 1))")
        done
        echo "$data" >>"$plottingData"
    fi
    while read -r data; do
        echo "$data" >>"$plottingData"
    done
    terminal="wxt"
    output=""
    if [ -n "$outputFile" ]; then
        terminal="pngcairo"
        output="set output '$outputFile';"
    fi
    cat "$plottingData" >>$$.dat
    gnuplotStr="
    set title 'Plot' ; 
    set terminal $terminal dashed size 1480,1080 font 'Verdana,20';
    $output
    set xlabel '${headers[0]}' ;
    set style line 2 lc rgb '#0060ad' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 3 lc rgb '#dd181f' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 4 lc rgb '#28ad3f' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 5 lc rgb '#dddd1a' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 6 lc rgb '#1adfac' lt 2 lw 3 pt 7 ps 1.5 ;
    set style line 7 lc rgb '#dd90ac' lt 2 lw 3 pt 7 ps 1.5 ;
    set grid;
    set key outside;
    plot "
    if [ "$cols" -gt 1 ]; then
        for i in $(seq 1 2 "$((cols))"); do
            iy=$((i + 1))
            gnuplotStr+="'$$.dat' using $i:$iy with linespoints title '${headers[$i]}'"
            if [ "$i" -lt "$cols" ]; then
                gnuplotStr+=", "
            fi
        done
    else
        gnuplotStr+="'$$.dat' with linespoints title '${headers[1]}'"
    fi

    echo "$gnuplotStr" | gnuplot -p
    rm $$.dat
}

plotitbrah() {

    seperatorFix=";"
    commaFix="."

    while getopts "sfh:" flag; do
        case $flag in
        s)
            seperatorFix="$OPTARG"
            ;;
        f)
            commaFix="$OPTARG"
            ;;
        h)
            echo "Usage: plotitbrah [-s seperator (;)] [-f commaFix (,)]"
            exit 0
            ;;
        \?)
            echo "Invalid option: $OPTARG"
            exit 0 #Should be 1, and made script.
            ;;
        esac
    done

    files=$(fzf -m --preview="cat {} | head -n 100")
    if [ -z "$files" ]; then
        echo "No files selected"
        exit 0 #Should be 1, and made script.
    fi
    # Sort files by their line count
    files=$(echo "$files" | xargs -n1 wc -l | sort -n -r)
    longestFileLineCount=$(echo "$files" | head -n 1 | awk '{print $1}')
    filesNamesForPaste=$(echo "$files" | awk '{print $2}' | tr '\n' ' ')
    filesNamesForPaste=${filesNamesForPaste::-1}

    # mktemp from pasted files
    rawDat=$(mktemp)

    # We want the string filesNamesForPaste to expand to it's values.
    # shellcheck disable=2086
    paste <(seq 1 "$longestFileLineCount") $filesNamesForPaste | head -n 100 | tr "$seperatorFix" '\t' | tr ',' "$commaFix" >"$rawDat"

    # Get Column count
    cols=$(head -n 1 "$rawDat" | wc -w)
    colHeadersArray=()
    colHeadersArray+=("1:Index")

    firstLine=$(head -n 1 "$rawDat")
    # If headers are present (If first line has letters)

    if [[ $firstLine =~ [a-zA-Z] ]]; then
        for i in $(seq 2 "$cols"); do
            header=$(echo "$firstLine" | tr ' ' '\t' | cut -d$'\t' -f"$i")
            colHeadersArray+=("$i:$header")
        done
    else
        for i in $(seq 2 "$((cols - 1))"); do
            colHeadersArray+=("$i:Column")
        done
    fi

    # Print column headers
    # Select x. (fzf with preview of combined) (headers but can also pick sequence)
    xSelect=$(echo "${colHeadersArray[@]}" | tr ' ' '\n' | fzf)

    # selecty y. (fzf with preview of combined)
    # Add another plot? (y/n)

    # If len > 10000, ask to reduce resolution to 10000

    # Put command into history (history -s)
    # run command
}
