#!/bin/bash

plot() {

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
	# Smooth nice colors
	gnuplotStr="set title 'Plot' ; 
    set terminal wxt dashed size 1480,1080 font 'Verdana,20' persist ;
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
	for i in $(seq 2 "$((cols))"); do
		gnuplotStr+="'$$.dat' using 1:$i with linespoints title '${headers[$i - 1]}' ls $i"
		if [ "$i" -lt "$cols" ]; then
			gnuplotStr+=", "
		fi
	done
	echo "$gnuplotStr"
	echo "$gnuplotStr" | gnuplot -p
	rm $$.dat
}
