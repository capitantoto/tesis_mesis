set terminal pngcairo
set output 'asd.png'
plot 'multiseries.dat' using 1:2 with lines,\
 'multiseries.dat' using 1:3 with lines,\
 'multiseries.dat' using 1:4 with lines,\
 'multiseries.dat' using 1:5 with lines,\
 'multiseries.dat' using 1:6 with lines,\
 'multiseries.dat' using 1:7 with lines
