DROP TABLE IF EXISTS diputados_capital;

CREATE TABLE diputados_capital(
	provincia SMALLINT,
	departamento SMALLINT,
	circuito SMALLINT,
	mesa SMALLINT,
	partido SMALLINT,
	votos SMALLINT);

LOAD DATA INFILE '/home/gonzalo/new_tesis/diputados_capital.csv' INTO TABLE diputados_capital
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

DROP TABLE IF EXISTS senadores_capital;

CREATE TABLE senadores_capital(
	provincia SMALLINT,
	departamento SMALLINT,
	circuito SMALLINT,
	mesa SMALLINT,
	partido SMALLINT,
	votos SMALLINT);

LOAD DATA INFILE '/home/gonzalo/new_tesis/senadores_capital.csv' INTO TABLE senadores_capital
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
