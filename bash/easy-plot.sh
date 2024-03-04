#!/bin/bash

plot() {
	# check if plot has command line arg

	if [ $# -eq 1 ]; then
		# Set output file name
		outputFile=$1
	fi
	read -r data
	cols=$(echo "$data" | wc -w)
	hasHeader=$(echo "$data" | grep -c -E "^[a-zA-Z]")
	headers=()
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
		echo "$data" >>$$.dat
	fi
	while read -r data; do
		echo "$data" >>$$.dat
	done
	terminal="wxt"
	output=""
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
	hasHeader=$(echo "$data" | grep -c -E "^[a-zA-Z]")
	headers=()
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
		echo "$data" >>$$.dat
	fi
	while read -r data; do
		echo "$data" >>$$.dat
	done
	terminal="wxt"
	output=""
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
		for i in $(seq 1 2 "$((cols))"); do
			iy=$((i + 1))
			gnuplotStr+="'$$.dat' using $i:$iy with linespoints title '${headers[$i - 1]}'"
			if [ "$i" -lt "$cols" ]; then
				gnuplotStr+=", "
			fi
		done
	else
		gnuplotStr+="'$$.dat' with linespoints title '${headers[1]}'"
	fi
	# echo "$gnuplotStr"

	echo "$gnuplotStr" | gnuplot -p
	rm $$.dat

}
