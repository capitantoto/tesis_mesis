set terminal pdfcairo enhanced font 'Verdana,8' size 11.7,8.3
set output 'graf3.pdf'
set title "Grafico III: Cantidad de mesas en las que se estabiliza la variacion del error absoluto."

set xrange[0.1:7256]
set logscale x
set xlabel 'Mesas Escrutadas'
set ylabel 'Cantidad de simulaciones''


set style line 100 lt 0 lc rgb "black" lw 5
set style line 101 lt 0 lc rgb "black" lw 1
set mytics
set grid xtics ytics mxtics mytics ls 100, ls 101

set style line 1 lt 1 lw 3 pt 1 linecolor rgb "red"
set style line 2 lt 1 lw 3 pt 1 linecolor rgb "blue"
set style line 3 lt 1 lw 3 pt 1 linecolor rgb "green"
set style line 4 lt 1 lw 3 pt 1 linecolor rgb "violet"

src = "/home/gonzalo/tesis_mesis/ruby/"

plot	src.'quiebres0.dat' u 2:1 title 'ErrAbs < 0.01' ls 1 with lines,\
src.'quiebres1.dat' u 2:1 title 'ErrAbs < 0.1' ls 2 with lines,\
src.'quiebres2.dat' u 2:1 title 'ErrAbs < 1' ls 3 with lines,\
src.'quiebres3.dat' u 2:1 title 'ErrAbs < 10' ls 4 with lines
