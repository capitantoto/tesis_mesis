# De aca saque los .csv con los resultados por mesa.
http://datospublicos.gob.ar/data/dataset/elecciones-2013
	http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T14%3A45%3A50.732Z/electoral-2013-diputados-nacionales.csv
	http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T15%3A24%3A30.086Z/electoral-2013-senadores-nacionales.csv
	http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T15%3A42%3A53.979Z/electoral-2013-descripcion-general.txt


# En este orden se ejecutaron los archivos para manipular los resultados y ordenarlos en filillas.

gonzalo@gonzalo-xagax:~/new_tesis$ mysql -uroot -pxagax911 tesis < importar_resultados.sql
gonzalo@gonzalo-xagax:~/new_tesis$ mysql -uroot -pxagax911 tesis < manipular_resultados.sql

# Luego se ejecutaron las siguientes consultas para obtener la informacion relevante:

mysql -uroot -pxagax911 tesis -e 'SELECT mesa, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY mesa' > mesas_raw.tsv

mysql -uroot -pxagax911 tesis -e 'SELECT circuito, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY circuito' > circuitos_raw.tsv

mysql -uroot -pxagax911 tesis -e 'SELECT seccion, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY seccion' > secciones_raw.tsv

https://www.youtube.com/watch?v=yW1sXTgKJIg -- Randazzo mencionando los resultados.
