set terminal pngcairo size 3200,1600
set output '2_delta_errabs_200_escrutinios.png'
set logscale x
set yrange[-10:10]
set xrange[1.01:1000]

plot for [i=0:199] '/home/gonzalo/tesis_mesis/dats/escrutinio'.i.'.dat' using 1:2 with lines,\
for [n=-2:1] exp(n)
