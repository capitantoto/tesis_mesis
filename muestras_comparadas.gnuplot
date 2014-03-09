set terminal pngcairo
set output 'muestras_comparadas.png'

filenames = "cien quinientos dosmil diezmil"
plot for [file in filenames] file.'.dat' u 2:1 with lines
