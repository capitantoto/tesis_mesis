set terminal pngcairo size 1600,1200
set output '5_percentiles_errabs_segun_n_muestral.png'
set logscale xy

percs = "1 5 10 50 90 95 99"
plot for [n in percs] 'perc'.n.'.dat' with lines,\
10,\
1,\
0.1

