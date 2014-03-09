set terminal pngcairo
set output '4_frecuencias_acumuladas_errabs_seleccionados.png'

filenames = "cien quinientos dosmil diezmil"
plot for [file in filenames] file.'.dat' u 2:1 with lines
