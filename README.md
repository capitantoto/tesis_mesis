# tesis_mesis
Repositorio personal de mi trabajo de tesis. Está medio sucio pero hey, al menos está.

## Data
Fuente:  [Portal Nacional de Datos Publicos](http://datospublicos.gob.ar/data/dataset/elecciones-2013)
  
  - [Resultados Electorales - Diputados Nacionales](http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T14%3A45%3A50.732Z/electoral-2013-diputados-nacionales.csv)
  - [Resultados Electorales - Senadores Nacionales](http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T15%3A24%3A30.086Z/electoral-2013-senadores-nacionales.csv)
  - [Resultados Electorales - Descripción General](http://www.datospublicos.gob.ar/data/storage/f/2013-10-29T15%3A42%3A53.979Z/electoral-2013-descripcion-general.txt)


## Setup
### Importación y manipulación de resultados
```sh
mysql -uroot -p tesis < importar_resultados.sql
mysql -uroot -p tesis < manipular_resultados.sql
```

### Exportación del dataset de análisis
Número de votos agregado por partido y jerarquía geográfica (mesa, circuito, sección)
```sh
mysql -uroot -p tesis -e 'SELECT mesa, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY mesa' > mesas_raw.tsv

mysql -uroot -p tesis -e 'SELECT circuito, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY circuito' > circuitos_raw.tsv

mysql -uroot -p tesis -e 'SELECT seccion, sum(ayl), sum(fpv), sum(unen), sum(pro), sum(fit), sum(cp), sum(blancos) FROM mesas_dip GROUP BY seccion' > secciones_raw.tsv
```
## Otros recursos
 - (Video) Florencio Randazzo anuncia resultado parcial con <10% escrutado. [link](https://www.youtube.com/watch?v=yW1sXTgKJIg)
