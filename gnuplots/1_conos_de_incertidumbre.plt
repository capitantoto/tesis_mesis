set terminal pngcairo size 1600,1200
set output '1_conos_de_incertidumbre.png'
set logscale x

set yrange [0.2:0.5]

filenames = "max_carrio min_carrio max_bergman min_bergman"
plot for [file in filenames] file.'.dat' with lines,\
0.3233,\
0.3446
