set terminal pngcairo
set output 'carrio_bergman.png'

filenames = "max_carrio min_carrio max_bergman min_bergman"
plot for [file in filenames] file.'.dat' with lines
