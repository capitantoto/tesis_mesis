set terminal pdfcairo enhanced font 'Verdana,8' size 11.7,8.3
set output 'graf5.pdf'
set title "Grafico V: Percentiles 1, 5, 10, 50, 90, 95, 99 para el error absoluto como funcion del tamano muestral."
unset key

set logscale xy
set xlabel 'Tamano Muestral'
set ylabel 'Error Absoluto'


set style line 100 lt 0 lc rgb "black" lw 5
set style line 101 lt 0 lc rgb "black" lw 1
set mytics
set grid xtics ytics mxtics mytics ls 100, ls 101

set style line 1 lt 1 lw 3 pt 1 linecolor rgb "red"
set style line 2 lt 1 lw 3 pt 1 linecolor rgb "blue"
set style line 3 lt 1 lw 3 pt 1 linecolor rgb "purple"
set style line 4 lt 1 lw 3 pt 1 linecolor rgb "green"

src = "/home/gonzalo/tesis_mesis/ruby/"


plot	src."perc1.dat" using 1:2 title "" with lines ls 1,\
	src."perc5.dat" using 1:2 title "" with lines ls 2,\
	src."perc10.dat" using 1:2 title "" with lines ls 3,\
	src."perc50.dat" using 1:2 title "" with lines ls 4,\
	src."perc90.dat" using 1:2 title "" with lines ls 3,\
	src."perc95.dat" using 1:2 title "" with lines ls 2,\
	src."perc99.dat" using 1:2 title "" with lines ls 1
