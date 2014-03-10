set terminal pdfcairo enhanced font 'Verdana,8' size 11.7,8.3
set output 'graf2.pdf'
set title "Grafico II: Variacion del error absoluto en funcion de las mesas escrutadas, 200 simulaciones.
unset key
set yrange[-10:10]
set xrange[1.01:1000]

set logscale x
set xrange [1:7256]
set xlabel 'Log(mesas escrutadas)'
set ylabel 'Variacion del error absoluto'


set style line 100 lt 0 lc rgb "black" lw 3
set style line 101 lt 0 lc rgb "black" lw 1
set mytics
set grid xtics ytics mxtics mytics ls 100, ls 101

set style line 1 lt 1 lw 1 pt 1 linecolor rgb "green"
set style line 2 lt 1 lw 1 pt 1 linecolor rgb "red"
set style line 3 lt 1 lw 1 pt 1 linecolor rgb "black"
src = "/home/gonzalo/tesis_mesis/ruby/"

plot for [i=0:199] src.'escrutinio'.i.'.dat' using 1:2 with points ls 1,\
1 ls 3,\
0.1 ls 3,\
0 ls 3,\
-0.1 ls 3,\
-1 ls 3
