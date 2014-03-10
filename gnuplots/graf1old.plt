set terminal pngcairo enhanced font 'Verdana,10' size 3500,2400 
set output 'graf1.png'
set logscale x

set xlabel 'Log(mesas escrutadas)'
set ylabel '% de votos'

set style line 1 lt 1 lw 1 pt 1 linecolor rgb "red"
set style line 2 lt 1 lw 2 pt 1 linecolor rgb "red"
set style line 3 lt 1 lw 3 pt 1 linecolor rgb "red"
set style line 4 lt 1 lw 4 pt 1 linecolor rgb "red"
set style line 5 lt 1 lw 1 pt 1 linecolor rgb "blue"
set style line 6 lt 1 lw 2 pt 1 linecolor rgb "blue"
set style line 7 lt 1 lw 3 pt 1 linecolor rgb "blue"
set style line 8 lt 1 lw 4 pt 1 linecolor rgb "blue"

src = "/home/gonzalo/tesis_mesis/ruby/"


plot 	src."2_1.dat" using 1:2 with lines ls 4,\
	src."2_10.dat" using 1:2 with lines ls 3,\
	src."2_50.dat" using 1:2 with lines ls 2,\
	src."2_100.dat" using 1:2 with lines ls 1,\
	src."2_500.dat" using 1:2 with lines ls 1,\
	src."2_900.dat" using 1:2 with lines ls 1,\
	src."2_950.dat" using 1:2 with lines ls 2,\
	src."2_990.dat" using 1:2 with lines ls 3,\
	src."2_1000.dat" using 1:2 with lines ls 4,\
	src."3_1.dat" using 1:2 with lines ls 8,\
	src."3_10.dat" using 1:2 with lines ls 7,\
	src."3_50.dat" using 1:2 with lines ls 6,\
	src."3_100.dat" using 1:2 with lines ls 5,\
	src."3_500.dat" using 1:2 with lines ls 5,\
	src."3_900.dat" using 1:2 with lines ls 5,\
	src."3_950.dat" using 1:2 with lines ls 6,\
	src."3_990.dat" using 1:2 with lines ls 7,\
	src."3_1000.dat" using 1:2 with lines ls 8
