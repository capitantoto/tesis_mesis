set terminal pngcairo
set output "3_magnitud_estabilizacion_errabs_escrutinios.png"
set logscale x

plot for [i=0:3] 'quiebres'.i.'.dat' u 2:1 with lines
