set terminal pngcairo
set output "a.png"

plot "quiebres2.dat" smooth kdensity
