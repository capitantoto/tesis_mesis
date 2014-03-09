set terminal pngcairo
set output "cumu.png"
set logscale x

plot for [i=0:3] 'quiebres'.i.'.dat' u 2:1 with lines
