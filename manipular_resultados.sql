-- Modificar los datos de diputados para formar una fila por mesa
-- Primero creo las filas con los datos de la mesa y el numero de votos en blanco.

DROP TABLE IF EXISTS mesas_dip;

CREATE TABLE mesas_dip AS
SELECT 	departamento AS seccion,
	circuito,
	mesa,
	votos AS blancos 
FROM	diputados_capital
WHERE partido = 9004;

-- Creo indices sobre el id de la mesa y el circuito para optimizar performance.

ALTER TABLE mesas_dip 
	ADD INDEX idx_mesa(mesa),
	ADD INDEX idx_circuito(circuito);

-- Creo las columnas para los votos de cada uno de los partidos.

ALTER TABLE mesas_dip
	ADD COLUMN ayl SMALLINT,
	ADD COLUMN fpv SMALLINT,
	ADD COLUMN unen SMALLINT,
	ADD COLUMN pro SMALLINT,
	ADD COLUMN fit SMALLINT,
	ADD COLUMN cp SMALLINT;

-- Por una cuestion de orden, muevo la columna 'blancos' al final de la tabla.
ALTER TABLE mesas_dip
	MODIFY COLUMN blancos SMALLINT AFTER cp;

-- Inserto en las columnas por partido, la cantidad de votos que tuvo segun el .csv general.

UPDATE mesas_dip, diputados_capital
SET mesas_dip.ayl = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 187;

UPDATE mesas_dip, diputados_capital
SET mesas_dip.fpv = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 501;

UPDATE mesas_dip, diputados_capital
SET mesas_dip.unen = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 502;

UPDATE mesas_dip, diputados_capital
SET mesas_dip.pro = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 503;

UPDATE mesas_dip, diputados_capital
SET mesas_dip.fit = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 505;

UPDATE mesas_dip, diputados_capital
SET mesas_dip.cp = diputados_capital.votos
WHERE diputados_capital.mesa = mesas_dip.mesa
AND diputados_capital.partido = 506;

-- Remuevo las mesas sin votos afirmativos.
DELETE FROM mesas_dip
WHERE fpv=0 AND unen=0 AND pro=0;


---------------------------------------
---------------------------------------
---------------------------------------

-- Repito todo el proceso, esta vez para senadores.

-- Modificar los datos de senadores para formar una fila por mesa
-- Primero creo las filas con los datos de la mesa y el numero de votos en blanco.

DROP TABLE IF EXISTS mesas_sen;

CREATE TABLE mesas_sen AS
SELECT 	departamento AS seccion,
	circuito,
	mesa,
	votos AS blancos 
FROM	senadores_capital
WHERE partido = 9004;

-- Creo indices sobre el id de la mesa y el circuito para optimizar performance.

ALTER TABLE mesas_sen 
	ADD INDEX idx_mesa(mesa),
	ADD INDEX idx_circuito(circuito);

-- Creo las columnas para los votos de cada uno de los partidos.

ALTER TABLE mesas_sen
	ADD COLUMN ayl SMALLINT,
	ADD COLUMN fpv SMALLINT,
	ADD COLUMN unen SMALLINT,
	ADD COLUMN pro SMALLINT,
	ADD COLUMN fit SMALLINT,
	ADD COLUMN cp SMALLINT;

-- Por una cuestion de orden, muevo la columna 'blancos' al final de la tabla.
ALTER TABLE mesas_sen
	MODIFY COLUMN blancos SMALLINT AFTER cp;

-- Inserto en las columnas por partido, la cantidad de votos que tuvo segun el .csv general.

UPDATE mesas_sen, senadores_capital
SET mesas_sen.ayl = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 187;

UPDATE mesas_sen, senadores_capital
SET mesas_sen.fpv = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 501;

UPDATE mesas_sen, senadores_capital
SET mesas_sen.unen = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 502;

UPDATE mesas_sen, senadores_capital
SET mesas_sen.pro = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 503;

UPDATE mesas_sen, senadores_capital
SET mesas_sen.fit = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 505;

UPDATE mesas_sen, senadores_capital
SET mesas_sen.cp = senadores_capital.votos
WHERE senadores_capital.mesa = mesas_sen.mesa
AND senadores_capital.partido = 506;

-- Remuevo las mesas sin votos afirmativos.
DELETE FROM mesas_sen
WHERE fpv=0 AND unen=0 AND pro=0;

