clear
reset
set key off
set border 3
set auto
 
set xrange[5000:7500]
set xtics 100
 
# Make some suitable labels.
set title "Demo graph"
set xlabel "Value"
set ylabel "Count"
 
set terminal png enhanced font arial 14 size 800, 600
ft="png"
# Set the output-file name.
set output "histograma.".ft
 
set style histogram clustered gap 1
set style fill solid border -1
 
binwidth=100
set boxwidth binwidth
bin(x,width)=width*floor(x/width) + binwidth/2.0
 
plot 'quiebres0.dat' using (bin($1,binwidth)):(1.0) smooth freq with boxes

