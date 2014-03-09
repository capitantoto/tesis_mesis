set terminal pngcairo size 3200,1600
set output 'delta_errabs.png'
set logscale x
set yrange[-10:10]
set xrange[1.01:1000]

plot for [i=0:99] 'escrutinio'.i.'.dat' using 1:2 with lines,\
for [n=0:5] n
