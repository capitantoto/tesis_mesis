set terminal pdfcairo enhanced font 'Verdana,8' size 11.7,8.3
set output 'graf4.pdf'
set title "Grafico IV: Frecuencia acumulada del error absoluto para muestras elegidas (10.000 simulaciones)."

set logscale x
set xlabel 'Error Absoluto'
set ylabel 'Frecuencia Acumulada'


set style line 100 lt 0 lc rgb "black" lw 5
set style line 101 lt 0 lc rgb "black" lw 1
set mytics
set grid xtics ytics mxtics mytics ls 100, ls 101

set style line 1 lt 1 lw 3 pt 1 linecolor rgb "red"
set style line 2 lt 1 lw 3 pt 1 linecolor rgb "blue"
set style line 3 lt 1 lw 3 pt 1 linecolor rgb "green"
set style line 4 lt 1 lw 3 pt 1 linecolor rgb "purple"

src = "/home/gonzalo/tesis_mesis/ruby/"


plot	src."graf4_100.dat" using 2:1 title "n = 100" with lines ls 1,\
	src."graf4_500.dat" using 2:1 title "n = 500" with lines ls 2,\
	src."graf4_2000.dat" using 2:1 title "n = 2.000" with lines ls 3,\
	src."graf4_10000.dat" using 2:1 title "n = 10.000" with lines ls 4
