set terminal pngcairo size 3500,2400
set output "3_magnitud_estabilizacion_errabs_escrutinios.png"
set logscale x


plot for [i=0:3] '/home/gonzalo/tesis_mesis/dats/quiebres'.i.'.dat' u 2:1 with lines
