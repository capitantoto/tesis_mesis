set terminal pngcairo
set output "asd.png"

unset key
set ylabel 'Frequency'
set y2label 'Cumulative frequency'
set y2tics 0,2e3,1e4
set ytics nomirror
set boxwidth 0.7 relative
set style fill solid 0.5
f(x) = a*exp(-(x-b)*(x-b)/c/c)
a=560.0
b=3.0
c = 1.0
bw = 0.1
bin(x,width)=width*floor(x/width)
plot 'quiebres2.dat' using (bin($1,bw)):(1.0) smooth frequency with boxes,\
'' using (bin($1,bw)):(1.0) smooth cumulative axis x1y2 w l lt 2 lw 2, \
f(x) w l lt 3 lw 2
