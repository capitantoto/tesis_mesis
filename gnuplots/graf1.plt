set terminal pdfcairo enhanced font 'Verdana,8' size 11.7,8.3
set output 'graf1.pdf'
set title "Grafico I: Percentiles 5, 50 y 95 de los votos de UNEN y PRO en 1000 simulaciones.

set logscale x
set xrange [1:7256]
set yrange [0.2:0.45]
set xlabel 'Log(mesas escrutadas)'
set ylabel '% de votos'


set style line 100 lt 0 lc rgb "black" lw 5
set style line 101 lt 0 lc rgb "black" lw 1
set mytics
set grid xtics ytics mxtics mytics ls 100, ls 101

set style line 1 lt 1 lw 3 pt 1 linecolor rgb "red"
set style line 2 lt 1 lw 3 pt 1 linecolor rgb "blue"
set style line 3 lt 0 lw 3 pt 1 linecolor rgb "red"
set style line 4 lt 0 lw 3 pt 1 linecolor rgb "blue"

src = "/home/gonzalo/tesis_mesis/ruby/"


plot	src."2_50.dat" using 1:2 title "Percentiles UNEN" with lines ls 1,\
	src."2_500.dat" using 1:2 title "" with lines ls 1,\
	src."2_950.dat" using 1:2 title "" with lines ls 1,\
	src."3_50.dat" using 1:2 title "Percentiles PRO" with lines ls 2,\
	src."3_500.dat" using 1:2 title "" with lines ls 2,\
	src."3_950.dat" using 1:2 title "" with lines ls 2,\
	0.3446 title "Resultado PRO (34,45%)"ls 4,\
	0.3223 title "Resultado UNEN (32,23%)"ls 3
