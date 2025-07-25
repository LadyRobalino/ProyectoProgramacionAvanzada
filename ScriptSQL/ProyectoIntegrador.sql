
-- Seleccion de base de datos y verificacion de datos iniciales
USE dataProyecto;
SELECT * FROM EMA_2024_1;
Select COUNT(*) FROM EMA_2024_1;

-- Crear tabla Matrimonio
CREATE TABLE Matrimonios AS
    SELECT * FROM EMA_2024_1;

-- Crear tabla Etnia e insertar valores unicos desde Matrimonios
CREATE TABLE Etnia (
    id_etnia INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE
);

INSERT INTO Etnia (descripcion)
SELECT DISTINCT p_etnica1 FROM Matrimonios WHERE p_etnica1 IS NOT NULL
UNION
SELECT DISTINCT p_etnica2 FROM Matrimonios WHERE p_etnica2 IS NOT NULL;

-- Creacion de la tabla NivelInstruccion e insertar valores unicos desde Matrimonio
CREATE TABLE NivelInstruccion (
    id_niv_inst INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE
);

INSERT INTO NivelInstruccion (descripcion)
SELECT DISTINCT niv_inst1 FROM Matrimonios WHERE niv_inst1 IS NOT NULL
UNION
SELECT DISTINCT niv_inst2 FROM Matrimonios WHERE niv_inst2 IS NOT NULL;

-- Creacion de tabla Pais e insertar codigos unicos
CREATE TABLE Pais (
    cod_pais VARCHAR(5) PRIMARY KEY
);

INSERT INTO Pais (cod_pais)
SELECT DISTINCT cod_pais1 FROM Matrimonios
UNION
SELECT DISTINCT cod_pais2 FROM Matrimonios;


-- Crear tabla Persona con sus columnas principales
CREATE TABLE Persona (
    id_persona INT PRIMARY KEY AUTO_INCREMENT,
    sexo CHAR(100),
    fecha_nac DATE,
    edad INT,
    nacionalidad VARCHAR(50),
    est_civil INT,
    etnia INT,
    nivel_instruccion INT,
    sabe_leer BOOLEAN,
    tipo VARCHAR(100) -- 'CONTRAYENTE1' o 'CONTRAYENTE2'
);
-- Insertar datos de CONTRAYENTE1 en la tabla Persona
INSERT INTO Persona (sexo, fecha_nac, edad, nacionalidad, est_civil, etnia, nivel_instruccion, sabe_leer, tipo)
SELECT
    CASE
        WHEN LOWER(sexo_1) LIKE '%m%' THEN 'M'
        WHEN LOWER(sexo_1) LIKE '%h%' THEN 'M'
        WHEN LOWER(sexo_1) LIKE '%f%' THEN 'F'
        WHEN LOWER(sexo_1) LIKE '%mujer%' THEN 'F'
        WHEN LOWER(sexo_1) LIKE '%hombre%' THEN 'M'
        ELSE NULL
    END,
    STR_TO_DATE(
        CONCAT(
            anio_nac1, '-',
            CASE LOWER(mes_nac1)
                WHEN 'enero' THEN '01'
                WHEN 'febrero' THEN '02'
                WHEN 'marzo' THEN '03'
                WHEN 'abril' THEN '04'
                WHEN 'mayo' THEN '05'
                WHEN 'junio' THEN '06'
                WHEN 'julio' THEN '07'
                WHEN 'agosto' THEN '08'
                WHEN 'septiembre' THEN '09'
                WHEN 'setiembre' THEN '09'
                WHEN 'octubre' THEN '10'
                WHEN 'noviembre' THEN '11'
                WHEN 'diciembre' THEN '12'
                ELSE '00'
            END,
            '-', dia_nac1
        ), '%Y-%m-%d'
    ),
    edad_1,
    cod_pais1,
    (SELECT est_civil_id FROM Estado_Civil WHERE descripcion = M.est_civi1),
    (SELECT id_etnia FROM Etnia WHERE descripcion = M.p_etnica1),
    (SELECT id_niv_inst FROM NivelInstruccion WHERE descripcion = M.niv_inst1),
    CASE M.sabe_leer1 WHEN 'SI' THEN TRUE ELSE FALSE END,
    'CONTRAYENTE1'
FROM Matrimonios M;

-- Insertamos datos de CONTRAYENTE2 en la tabla Persona
INSERT INTO Persona (sexo, fecha_nac, edad, nacionalidad, est_civil, etnia, nivel_instruccion, sabe_leer, tipo)
SELECT
    CASE
        WHEN LOWER(sexo_2) LIKE '%m%' THEN 'M'
        WHEN LOWER(sexo_2) LIKE '%h%' THEN 'M'
        WHEN LOWER(sexo_2) LIKE '%f%' THEN 'F'
        WHEN LOWER(sexo_2) LIKE '%mujer%' THEN 'F'
        WHEN LOWER(sexo_2) LIKE '%hombre%' THEN 'M'
        ELSE NULL
    END,
    STR_TO_DATE(
        CONCAT(
            anio_nac2, '-',
            CASE LOWER(mes_nac2)
                WHEN 'enero' THEN '01'
                WHEN 'febrero' THEN '02'
                WHEN 'marzo' THEN '03'
                WHEN 'abril' THEN '04'
                WHEN 'mayo' THEN '05'
                WHEN 'junio' THEN '06'
                WHEN 'julio' THEN '07'
                WHEN 'agosto' THEN '08'
                WHEN 'septiembre' THEN '09'
                WHEN 'setiembre' THEN '09'
                WHEN 'octubre' THEN '10'
                WHEN 'noviembre' THEN '11'
                WHEN 'diciembre' THEN '12'
                ELSE '00'
            END,
            '-', dia_nac2
        ), '%Y-%m-%d'
    ),
    edad_2,
    cod_pais2,
    (SELECT est_civil_id FROM Estado_Civil WHERE descripcion = M.est_civi2),
    (SELECT id_etnia FROM Etnia WHERE descripcion = M.p_etnica2),
    (SELECT id_niv_inst FROM NivelInstruccion WHERE descripcion = M.niv_inst2),
    CASE M.sabe_leer2 WHEN 'SI' THEN TRUE ELSE FALSE END,
    'CONTRAYENTE2'
FROM Matrimonios M;

-- Agregamos columna id_insc a Matrimonio como clave primaria

ALTER TABLE Matrimonios ADD COLUMN id_insc INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- Creamos la tabla de MatrimoniosFinal con claves foraneas a Persona
CREATE TABLE MatrimonioFinal (
    id_matrimonio INT PRIMARY KEY AUTO_INCREMENT,
    fecha_insc DATE,
    hijos_rec INT,
    mcap_bie VARCHAR(50),
    persona1_id INT,
    persona2_id INT,
    FOREIGN KEY (persona1_id) REFERENCES Persona(id_persona),
    FOREIGN KEY (persona2_id) REFERENCES Persona(id_persona)
);

-- Crear tabla temporal para emparejar perosnas por id_insc
CREATE TEMPORARY TABLE PersonasEmparejadas AS
SELECT
    M.id_insc,
    P1.id_persona AS persona1_id,
    P2.id_persona AS persona2_id
FROM Matrimonios M
JOIN (
    SELECT id_persona, ROW_NUMBER() OVER () AS rn FROM Persona WHERE tipo = 'CONTRAYENTE1'
) P1 ON P1.rn = M.id_insc
JOIN (
    SELECT id_persona, ROW_NUMBER() OVER () AS rn FROM Persona WHERE tipo = 'CONTRAYENTE2'
) P2 ON P2.rn = M.id_insc;

-- Insertamos datos en MatrimonioFinal usando los ids emparejados
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    STR_TO_DATE(CONCAT(anio_insc, '-',
        CASE LOWER(mes_insc)
            WHEN 'enero' THEN '01'
            WHEN 'febrero' THEN '02'
            WHEN 'marzo' THEN '03'
            WHEN 'abril' THEN '04'
            WHEN 'mayo' THEN '05'
            WHEN 'junio' THEN '06'
            WHEN 'julio' THEN '07'
            WHEN 'agosto' THEN '08'
            WHEN 'septiembre' THEN '09'
            WHEN 'setiembre' THEN '09'
            WHEN 'octubre' THEN '10'
            WHEN 'noviembre' THEN '11'
            WHEN 'diciembre' THEN '12'
            ELSE '00'
        END,
        '-', dia_insc), '%Y-%m-%d'
    ),
    hijos_rec,
    mcap_bie,
    E.persona1_id,
    E.persona2_id
FROM Matrimonios M
JOIN PersonasEmparejadas E ON M.id_insc = E.id_insc;

-- Creamos la tabla UbicacionResidencia y poblarla con ubicaciones unicas
CREATE TABLE UbicacionResidencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provincia VARCHAR(100),
    canton VARCHAR(100),
    parroquia VARCHAR(100),
    area VARCHAR(100)
);

-- Insertamos ubicaciones unicas desde Matrimonios
INSERT INTO UbicacionResidencia (provincia, canton, parroquia, area)
SELECT DISTINCT prov_hab1, cant_hab1, parr_hab1, area_1 FROM Matrimonios
UNION
SELECT DISTINCT prov_hab2, cant_hab2, parr_hab2, area_2 FROM Matrimonios;

-- Agregamos columnas id_ubicacion_residencia y id_matrimonio a Persona
ALTER TABLE Persona ADD COLUMN id_ubicacion_residencia INT;
ALTER TABLE Persona ADD COLUMN id_matrimonio INT;

-- Mostrar definicion de columna tipo Persona
SHOW COLUMNS FROM Persona LIKE 'tipo';

-- Actualizamos id_ubicacion_residencia en Persona con Join a UbicacionResidencia
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc AND p.tipo = 1
JOIN UbicacionResidencia u ON
    u.provincia = m.prov_hab1 AND
    u.canton = m.cant_hab1 AND
    u.parroquia = m.parr_hab1 AND
    u.area = m.area_1
SET p.id_ubicacion_residencia = u.id
WHERE p.tipo = 1;


-- Agregamos clave foránea de Persona a Matrimonios con actualizacion en casacada
ALTER TABLE Persona
ADD CONSTRAINT id_matrimonio
FOREIGN KEY (id_matrimonio)
REFERENCES Matrimonios(id_insc)
ON UPDATE CASCADE;

-- Mostrar estructura de Persona
Show create table Persona;

-- Creamos la tabla Estado_Civil e insertamos valores unicos
CREATE TABLE Estado_Civil (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) UNIQUE
);

-- Insertamos sus valores unicos en Etsado_Civil desde Matrimonio
INSERT INTO Estado_Civil (descripcion)
SELECT DISTINCT est_civi1 FROM Matrimonios WHERE est_civi1 IS NOT NULL
UNION
SELECT DISTINCT est_civi2 FROM Matrimonios WHERE est_civi2 IS NOT NULL;

-- Agregar columna estado_civil a Persona
ALTER TABLE Persona
ADD COLUMN estado_civil_id INT;

-- Actualizar id_pais en Persona usando datos de nacionalidad
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
JOIN Estado_Civil e ON
    (p.tipo = 'CONTRAYENTE1' AND m.est_civi1 = e.descripcion)
    OR (p.tipo = 'CONTRAYENTE2' AND m.est_civi2 = e.descripcion)
SET p.estado_civil_id = e.id_estado
WHERE p.id_matrimonio IS NOT NULL;

-- Agregamos columna id_pais a Persona y actualizarla
ALTER TABLE Persona ADD COLUMN id_pais VARCHAR(100);

-- Actualizamos id_pais en Persona con datos de nacionalidad
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
SET p.id_pais =
    CASE
        WHEN p.tipo = 'CONTRAYENTE1' THEN m.nac_1
        WHEN p.tipo = 'CONTRAYENTE2' THEN m.nac_2
    END
WHERE p.id_matrimonio IS NOT NULL;

-- Renombramos columnas en Persona para normalizar nombres
ALTER TABLE Persona RENAME COLUMN estado_civil_id to est_civil_id;
ALTER TABLE Persona RENAME COLUMN etnia TO etnia_id;
ALTER TABLE Persona RENAME COLUMN nivel_instruccion TO nivel_instruccion_id;
ALTER TABLE Persona RENAME COLUMN nacionalidad TO pais_id;

-- Mostrar la estructura de Persona
DESCRIBE Persona;

-- Agregamos claves foraneas a Persona
ALTER TABLE Persona
ADD CONSTRAINT fk_pais
FOREIGN KEY (pais_id) REFERENCES Pais(cod_pais);

ALTER TABLE Persona
ADD CONSTRAINT fk_estado_civil
FOREIGN KEY (est_civil_id) REFERENCES Estado_Civil(id_estado);

ALTER TABLE Persona
ADD CONSTRAINT fk_etnia
FOREIGN KEY (etnia_id) REFERENCES Etnia(id_etnia);

ALTER TABLE Persona
ADD CONSTRAINT fk_nivel_inst
FOREIGN KEY (nivel_instruccion_id) REFERENCES NivelInstruccion(id_niv_inst);

-- Verficamos y correguimos codigos de pais en Pais
-- Identificamos y agregamos codigos de pais faltantes en la tabla Pais desde Persona
SELECT DISTINCT pais_id
FROM Persona
WHERE pais_id NOT IN (SELECT cod_pais FROM Pais);

INSERT INTO Pais (cod_pais)
SELECT DISTINCT pais_id
FROM Persona
WHERE pais_id NOT IN (SELECT cod_pais FROM Pais);

-- Modificamos la longuitud de cod_pais en Pais
ALTER TABLE Pais MODIFY cod_pais VARCHAR(40);

-- Renombra la columna id_estado a est_civil_id en Estado_Civil
ALTER TABLE Estado_Civil RENAME COLUMN id_estado to est_civil_id;

-- Mostrar la descripcion de la MatrimonioFinal
describe MatrimonioFinal;

-- Selecciona todos los registros de las tablas creadas para verificacion
SELECT * FROM Etnia;
SELECT * FROM NivelInstruccion;
SELECT * FROM Pais;
SELECT * FROM Persona;
SELECT * FROM UbicacionResidencia;

-- Seleccionamos datos especificos de Persona
SELECT id_persona, tipo, sexo, fecha_nac FROM Persona;

-- Mostrar los primeros 5 registros Matrimonio
SELECT * FROM Matrimonios LIMIT 5;

-- Insertamos datos en MatrimonioFInal
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    m.fecha_insc,
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
JOIN Persona p1 ON p1.tipo = 'CONTRAYENTE1' AND p1.sexo = m.sexo_1 AND p1.fecha_nac = m.fecha_nac1
JOIN Persona p2 ON p2.tipo = 'CONTRAYENTE2' AND p2.sexo = m.sexo_2 AND p2.fecha_nac = m.fecha_nac2;

-- Verificar primero si la cantidad es par
SELECT COUNT(*) FROM Persona;

-- Conteo de personas por tipo
-- Agrupa y cuenta las personas por tipo (CONTRAYENTE1 o CONTRAYENTE2)
SELECT tipo, COUNT(*) FROM Persona GROUP BY tipo;

-- Mostramos datos Matrimonios y Persona para verificar emperejamineto
SELECT
    m.fecha_insc,
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
JOIN Persona p1 ON p1.tipo = 'CONTRAYENTE1' AND p1.sexo = m.sexo_1 AND p1.fecha_nac = m.fecha_nac1
JOIN Persona p2 ON p2.tipo = 'CONTRAYENTE2' AND p2.sexo = m.sexo_2 AND p2.fecha_nac = m.fecha_nac2
LIMIT 10;

-- Mostramps datos específicos de Matrimonios
-- Seleccionamos sexo_1 y fecha_nac1 de Matrimonios para inspección.
SELECT DISTINCT sexo_1, fecha_nac1 FROM Matrimonios LIMIT 5;

-- Mostramos datos específicos de Persona (CONTRAYENTE1)
-- Seleccionamos sexo y fecha_nac de Persona para CONTRAYENTE1.
SELECT DISTINCT sexo, fecha_nac FROM Persona WHERE tipo = 'CONTRAYENTE1' LIMIT 5;

-- Mostramos datos de Persona por tipo
-- Seleccionamos tipo, sexo y fecha_nac para CONTRAYENTE1 y CONTRAYENTE2
SELECT tipo, sexo, fecha_nac FROM Persona WHERE tipo = 'CONTRAYENTE1' LIMIT 5;
SELECT tipo, sexo, fecha_nac FROM Persona WHERE tipo = 'CONTRAYENTE2' LIMIT 5;

-- Inserción alternativa en MatrimonioFinal
-- Insertamos datos en MatrimonioFinal usando sexo y fecha_nac para emparejar
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    m.fecha_insc,
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
JOIN Persona p1
    ON p1.tipo = 'CONTRAYENTE1'
    AND p1.sexo = m.sexo_1
    AND p1.fecha_nac = m.fecha_nac1
JOIN Persona p2
    ON p2.tipo = 'CONTRAYENTE2'
    AND p2.sexo = m.sexo_2
    AND p2.fecha_nac = m.fecha_nac2;

-- Identificamos registros donde no se pudo emparejar personas en MatrimonioFinal
SELECT
    m.fecha_insc,
    m.sexo_1, m.fecha_nac1,
    m.sexo_2, m.fecha_nac2,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
LEFT JOIN Persona p1
    ON p1.tipo = 'CONTRAYENTE1'
    AND p1.sexo = m.sexo_1
    AND p1.fecha_nac = m.fecha_nac1
LEFT JOIN Persona p2
    ON p2.tipo = 'CONTRAYENTE2'
    AND p2.sexo = m.sexo_2
    AND p2.fecha_nac = m.fecha_nac2
WHERE p1.id_persona IS NULL OR p2.id_persona IS NULL
LIMIT 20;

-- Contamos personas con sexo y fecha_nac no nulos para CONTRAYENTE1.
SELECT COUNT(*) FROM Persona
WHERE tipo = 'CONTRAYENTE1' AND fecha_nac IS NOT NULL AND sexo IS NOT NULL;

-- Verifica cuántas fechas son válidas en fecha_nac1 y fecha_nac2
SELECT *
FROM Matrimonios
WHERE STR_TO_DATE(fecha_nac1, '%Y/%m/%d') IS NOT NULL
  AND STR_TO_DATE(fecha_nac2, '%Y/%m/%d') IS NOT NULL;

-- Insertamos datos en MatrimonioFinal asegurando que las fechas sean válidas
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    STR_TO_DATE(m.fecha_insc, '%Y/%m/%d'),
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
JOIN Persona p1
  ON p1.tipo = 'CONTRAYENTE1'
  AND p1.sexo = m.sexo_1
  AND p1.fecha_nac = STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d')
JOIN Persona p2
  ON p2.tipo = 'CONTRAYENTE2'
  AND p2.sexo = m.sexo_2
  AND p2.fecha_nac = STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d')
WHERE STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d') IS NOT NULL
  AND STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d') IS NOT NULL;

-- Seleccionamos los primeros 10 registros de MatrimonioFinal
SELECT * FROM MatrimonioFinal LIMIT 10;

-- Cuenta personas con tipo CONTRAYENTE1 y datos no nulos.
SELECT COUNT(*)
FROM Persona
WHERE UPPER(TRIM(tipo)) = 'CONTRAYENTE1'
AND fecha_nac IS NOT NULL
AND sexo IS NOT NULL;

-- Selecciona los valores únicos de la columna tipo en Persona.
SELECT DISTINCT tipo FROM Persona;

-- Convertimos las fechas de nacimiento (formato 'YYYY/MM/DD') a tipo DATE y muestra las primeras 5 válidas
SELECT
  fecha_nac1,
  STR_TO_DATE(fecha_nac1, '%Y/%m/%d') AS fecha_parseada
FROM Matrimonios
WHERE STR_TO_DATE(fecha_nac1, '%Y/%m/%d') IS NOT NULL
LIMIT 5;

-- Muestramos datos de Matrimonios y Persona para CONTRAYENTE1 con fechas válidas.
SELECT *
FROM Matrimonios m
JOIN Persona p
  ON p.tipo = 'CONTRAYENTE1'
  AND p.sexo = m.sexo_1
  AND p.fecha_nac = STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d')
LIMIT 10;

-- Comparamos fechas de nacimiento entre Persona y Matrimonios para CONTRAYENTE2.
SELECT
  p.fecha_nac AS persona_fecha,
  STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d') AS matrimonio_fecha
FROM Persona p
JOIN Matrimonios m
  ON p.tipo = 'CONTRAYENTE2'
  AND p.sexo = m.sexo_2
WHERE p.fecha_nac = STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d')
LIMIT 10;

-- Insertamos datos en MatrimonioFinal asegurando coincidencia exacta de fechas
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    STR_TO_DATE(m.fecha_insc, '%Y/%m/%d'),
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona,
    p2.id_persona
FROM Matrimonios m
JOIN Persona p1
  ON p1.tipo = 'CONTRAYENTE1'
  AND p1.sexo = m.sexo_1
  AND DATE(p1.fecha_nac) = DATE(STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d'))
JOIN Persona p2
  ON p2.tipo = 'CONTRAYENTE2'
  AND p2.sexo = m.sexo_2
  AND DATE(p2.fecha_nac) = DATE(STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d'))
WHERE STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d') IS NOT NULL
  AND STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d') IS NOT NULL;

-- Conteo de registros en tablas
SELECT COUNT(*) FROM Matrimonios;
SELECT COUNT(*) FROM Persona;
SELECT tipo, COUNT(*) FROM Persona GROUP BY tipo;

-- Mostramos datos específicos para inspección
SELECT DISTINCT sexo_1, sexo_2, anio_nac1, mes_nac1, dia_nac1, anio_nac2, mes_nac2, dia_nac2 FROM Matrimonios LIMIT 5;
SELECT tipo, sexo, fecha_nac FROM Persona LIMIT 5;

-- Verificar valores nulos en fechas de inscripción
SELECT anio_insc, mes_insc, dia_insc FROM Matrimonios WHERE anio_insc IS NULL OR mes_insc IS NULL OR dia_insc IS NULL LIMIT 5;
/*-----------------------------------------------------------------------------------------------------  */
-- Eliminar la tabla Persona existente
DROP TABLE IF EXISTS Persona;

-- Crear tabla Persona con id_matrimonio
CREATE TABLE Persona (
    id_persona INT PRIMARY KEY AUTO_INCREMENT,
    sexo CHAR(100),
    fecha_nac DATE,
    edad INT,
    nacionalidad VARCHAR(50),
    est_civil INT,
    etnia INT,
    nivel_instruccion INT,
    sabe_leer BOOLEAN,
    tipo VARCHAR(100),
    id_matrimonio INT,
    id_ubicacion_residencia INT,
    id_pais VARCHAR(100),
    est_civil_id INT,
    etnia_id INT,
    nivel_instruccion_id INT
);

-- Insertamos CONTRAYENTE1 en Persona
INSERT INTO Persona (sexo, fecha_nac, edad, nacionalidad, est_civil, etnia, nivel_instruccion, sabe_leer, tipo, id_matrimonio)
SELECT
    CASE
        WHEN LOWER(sexo_1) LIKE '%m%' THEN 'M'
        WHEN LOWER(sexo_1) LIKE '%h%' THEN 'M'
        WHEN LOWER(sexo_1) LIKE '%f%' THEN 'F'
        WHEN LOWER(sexo_1) LIKE '%mujer%' THEN 'F'
        WHEN LOWER(sexo_1) LIKE '%hombre%' THEN 'M'
        ELSE NULL
    END,
    STR_TO_DATE(
        CONCAT(
            anio_nac1, '-',
            CASE LOWER(mes_nac1)
                WHEN 'enero' THEN '01'
                WHEN 'febrero' THEN '02'
                WHEN 'marzo' THEN '03'
                WHEN 'abril' THEN '04'
                WHEN 'mayo' THEN '05'
                WHEN 'junio' THEN '06'
                WHEN 'julio' THEN '07'
                WHEN 'agosto' THEN '08'
                WHEN 'septiembre' THEN '09'
                WHEN 'setiembre' THEN '09'
                WHEN 'octubre' THEN '10'
                WHEN 'noviembre' THEN '11'
                WHEN 'diciembre' THEN '12'
                ELSE '00'
            END,
            '-', dia_nac1
        ), '%Y-%m-%d'
    ),
    edad_1,
    cod_pais1,
    (SELECT est_civil_id FROM Estado_Civil WHERE descripcion = M.est_civi1),
    (SELECT id_etnia FROM Etnia WHERE descripcion = M.p_etnica1),
    (SELECT id_niv_inst FROM NivelInstruccion WHERE descripcion = M.niv_inst1),
    CASE M.sabe_leer1 WHEN 'SI' THEN TRUE ELSE FALSE END,
    'CONTRAYENTE1',
    M.id_insc
FROM Matrimonios M;


-- Insertar CONTRAYENTE2 en Persona
INSERT INTO Persona (sexo, fecha_nac, edad, nacionalidad, est_civil, etnia, nivel_instruccion, sabe_leer, tipo, id_matrimonio)
SELECT
    CASE
        WHEN LOWER(sexo_2) LIKE '%m%' THEN 'M'
        WHEN LOWER(sexo_2) LIKE '%h%' THEN 'M'
        WHEN LOWER(sexo_2) LIKE '%f%' THEN 'F'
        WHEN LOWER(sexo_2) LIKE '%mujer%' THEN 'F'
        WHEN LOWER(sexo_2) LIKE '%hombre%' THEN 'M'
        ELSE NULL
    END,
    STR_TO_DATE(
        CONCAT(
            anio_nac2, '-',
            CASE LOWER(mes_nac2)
                WHEN 'enero' THEN '01'
                WHEN 'febrero' THEN '02'
                WHEN 'marzo' THEN '03'
                WHEN 'abril' THEN '04'
                WHEN 'mayo' THEN '05'
                WHEN 'junio' THEN '06'
                WHEN 'julio' THEN '07'
                WHEN 'agosto' THEN '08'
                WHEN 'septiembre' THEN '09'
                WHEN 'setiembre' THEN '09'
                WHEN 'octubre' THEN '10'
                WHEN 'noviembre' THEN '11'
                WHEN 'diciembre' THEN '12'
                ELSE '00'
            END,
            '-', dia_nac2
        ), '%Y-%m-%d'
    ),
    edad_2,
    cod_pais2,
    (SELECT est_civil_id FROM Estado_Civil WHERE descripcion = M.est_civi2),
    (SELECT id_etnia FROM Etnia WHERE descripcion = M.p_etnica2),
    (SELECT id_niv_inst FROM NivelInstruccion WHERE descripcion = M.niv_inst2),
    CASE M.sabe_leer2 WHEN 'SI' THEN TRUE ELSE FALSE END,
    'CONTRAYENTE2',
    M.id_insc
FROM Matrimonios M;

-- Actualizamos fecha_insc en Matrimonios
UPDATE Matrimonios
SET fecha_insc = STR_TO_DATE(
    CONCAT(
        anio_insc, '-',
        CASE LOWER(mes_insc)
            WHEN 'enero' THEN '01'
            WHEN 'febrero' THEN '02'
            WHEN 'marzo' THEN '03'
            WHEN 'abril' THEN '04'
            WHEN 'mayo' THEN '05'
            WHEN 'junio' THEN '06'
            WHEN 'julio' THEN '07'
            WHEN 'agosto' THEN '08'
            WHEN 'septiembre' THEN '09'
            WHEN 'setiembre' THEN '09'
            WHEN 'octubre' THEN '10'
            WHEN 'noviembre' THEN '11'
            WHEN 'diciembre' THEN '12'
            ELSE '00'
        END,
        '-', dia_insc
    ), '%Y-%m-%d'
)
WHERE fecha_insc IS NULL OR fecha_insc != STR_TO_DATE(
    CONCAT(
        anio_insc, '-',
        CASE LOWER(mes_insc)
            WHEN 'enero' THEN '01'
            WHEN 'febrero' THEN '02'
            WHEN 'marzo' THEN '03'
            WHEN 'abril' THEN '04'
            WHEN 'mayo' THEN '05'
            WHEN 'junio' THEN '06'
            WHEN 'julio' THEN '07'
            WHEN 'agosto' THEN '08'
            WHEN 'septiembre' THEN '09'
            WHEN 'setiembre' THEN '09'
            WHEN 'octubre' THEN '10'
            WHEN 'noviembre' THEN '11'
            WHEN 'diciembre' THEN '12'
            ELSE '00'
        END,
        '-', dia_insc
    ), '%Y-%m-%d'
);
/*---------------------*/
-- Contamos los registros que cumplen las condiciones de emparejamiento para MatrimonioFinal.
SELECT COUNT(*)
FROM Matrimonios m
JOIN Persona p1 ON p1.tipo = 'CONTRAYENTE1' AND p1.sexo = m.sexo_1
  AND DATE(p1.fecha_nac) = DATE(STR_TO_DATE(m.fecha_nac1, '%Y/%m/%d'))
JOIN Persona p2 ON p2.tipo = 'CONTRAYENTE2' AND p2.sexo = m.sexo_2
  AND DATE(p2.fecha_nac) = DATE(STR_TO_DATE(m.fecha_nac2, '%Y/%m/%d'));

-- Mostramos datos de Persona
SELECT id_persona, tipo, sexo, fecha_nac FROM Persona LIMIT 10;

-- Mostramos fechas de nacimiento de Matrimonios
SELECT DISTINCT fecha_nac1 FROM Matrimonios WHERE fecha_nac1 IS NOT NULL LIMIT 10;

-- Verificar formato de fechas en Matrimonios
SELECT
  fecha_nac1,
  STR_TO_DATE(fecha_nac1, '%Y/%m/%d') AS fecha_transformada
FROM Matrimonios
WHERE fecha_nac1 IS NOT NULL
LIMIT 10;

-- Seleccionamos datos para emparejar
SELECT
    m.fecha_insc,
    m.hijos_rec,
    m.mcap_bie,
    p1.id_persona AS persona1_id,
    p2.id_persona AS persona2_id
FROM Matrimonios m
JOIN Persona p1 ON p1.tipo = 'CONTRAYENTE1' AND p1.id_matrimonio = m.id_insc
JOIN Persona p2 ON p2.tipo = 'CONTRAYENTE2' AND p2.id_matrimonio = m.id_insc;

-- Insertamos datos en MatrimonioFinal usando id_matrimonio para emparejar personas
INSERT INTO MatrimonioFinal (fecha_insc, hijos_rec, mcap_bie, persona1_id, persona2_id)
SELECT
    STR_TO_DATE(m.fecha_insc, '%m/%d/%Y') AS fecha_insc,
    CASE
        WHEN m.hijos_rec REGEXP '^[0-9]+$' THEN CAST(m.hijos_rec AS UNSIGNED)
        ELSE NULL
    END AS hijos_rec,
    m.mcap_bie,
    p1.id_persona,
    p2.id_persona
FROM Matrimonios m
JOIN Persona p1 ON p1.tipo = 'CONTRAYENTE1' AND p1.id_matrimonio = m.id_insc
JOIN Persona p2 ON p2.tipo = 'CONTRAYENTE2' AND p2.id_matrimonio = m.id_insc;

-- AGregamos la columna id_ubicacion y clave foranea
ALTER TABLE Persona
ADD COLUMN id_ubicacion INT,
ADD FOREIGN KEY (id_ubicacion) REFERENCES UbicacionResidencia(id);

-- Unimos UbicacionResidencia con indicadores_provincia
SELECT ur.provincia, ip.pobreza_ingresos, ip.pobreza_nbi, ip.idh
FROM UbicacionResidencia ur
JOIN dataProyecto.indicadores_provincia ip ON LOWER(TRIM(ur.provincia)) = LOWER(TRIM(ip.provincia));

-- Actualizamos el id_ubicacion_residencia en Persona
UPDATE Persona p
SET p.id_ubicacion_residencia = p.id_ubicacion
WHERE p.id_ubicacion_residencia IS NULL
AND p.id_ubicacion IS NOT NULL;

-- Mostramos las columnas de Persona
SHOW COLUMNS FROM Persona;
select * from Persona;

-- Actualizamos id_ubicacion_residencia e id_ubicacion en Persona usando datos Matrimonios
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
JOIN UbicacionResidencia u ON
    ((p.tipo = 'CONTRAYENTE1' AND u.provincia = m.prov_hab1 AND u.canton = m.cant_hab1 AND u.parroquia = m.parr_hab1 AND u.area = m.area_1)
     OR
     (p.tipo = 'CONTRAYENTE2' AND u.provincia = m.prov_hab2 AND u.canton = m.cant_hab2 AND u.parroquia = m.parr_hab2 AND u.area = m.area_2))
SET
    p.id_ubicacion_residencia = u.id,
    p.id_ubicacion = u.id
WHERE p.id_ubicacion_residencia IS NULL OR p.id_ubicacion IS NULL;

-- Actualizamos id_pais en Persona usando datos de nacionalidad de Matrimonios
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
SET p.id_pais =
    CASE
        WHEN p.tipo = 'CONTRAYENTE1' THEN m.nac_1
        WHEN p.tipo = 'CONTRAYENTE2' THEN m.nac_2
    END
WHERE p.id_pais IS NULL;

-- Actualizamos est_civil_id en Persona usando datos de estado civil de Matrimonios.
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
JOIN Estado_Civil ec ON
    (p.tipo = 'CONTRAYENTE1' AND ec.descripcion = m.est_civi1)
    OR
    (p.tipo = 'CONTRAYENTE2' AND ec.descripcion = m.est_civi2)
SET p.est_civil_id = ec.est_civil_id
WHERE p.est_civil_id IS NULL;

-- Actualizamos etnia_id en Persona usando datos de etnia de Matrimonios.
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
JOIN Etnia e ON
    (p.tipo = 'CONTRAYENTE1' AND e.descripcion = m.p_etnica1)
    OR
    (p.tipo = 'CONTRAYENTE2' AND e.descripcion = m.p_etnica2)
SET p.etnia_id = e.id_etnia
WHERE p.etnia_id IS NULL;

-- Actualizamos nivel_instruccion_id en Persona usando datos de nivel de instrucción de Matrimonios.
UPDATE Persona p
JOIN Matrimonios m ON p.id_matrimonio = m.id_insc
JOIN NivelInstruccion ni ON
    (p.tipo = 'CONTRAYENTE1' AND ni.descripcion = m.niv_inst1)
    OR
    (p.tipo = 'CONTRAYENTE2' AND ni.descripcion = m.niv_inst2)
SET p.nivel_instruccion_id = ni.id_niv_inst
WHERE p.nivel_instruccion_id IS NULL;

-- Creamos una vista que combina datos de MtarimonioFinal
CREATE OR REPLACE VIEW MatrimonioVistaCompleta AS
SELECT
    m.id_matrimonio,
    m.fecha_insc,
    m.hijos_rec,
    m.mcap_bie,

    -- Persona 1
    p1.id_persona AS persona1_id,
    p1.sexo AS sexo1,
    p1.fecha_nac AS fecha_nac1,
    p1.edad AS edad1,
    p1.nacionalidad AS nacionalidad1,
    ec1.descripcion AS estado_civil1,
    e1.descripcion AS etnia1,
    p1.sabe_leer AS sabe_leer1,
    p1.tipo AS tipo1,

    -- Persona 2
    p2.id_persona AS persona2_id,
    p2.sexo AS sexo2,
    p2.fecha_nac AS fecha_nac2,
    p2.edad AS edad2,
    p2.nacionalidad AS nacionalidad2,
    ec2.descripcion AS estado_civil2,
    e2.descripcion AS etnia2,
    p2.sabe_leer AS sabe_leer2,
    p2.tipo AS tipo2,

    -- Ubicación
    ur.provincia,
    ur.canton,
    ur.parroquia,
    ur.area,

    -- País
    pais.cod_pais AS nombre_pais

FROM MatrimonioFinal m
JOIN Persona p1 ON m.persona1_id = p1.id_persona
JOIN Persona p2 ON m.persona2_id = p2.id_persona
LEFT JOIN Estado_Civil ec1 ON p1.est_civil = ec1.est_civil_id
LEFT JOIN Estado_Civil ec2 ON p2.est_civil = ec2.est_civil_id
LEFT JOIN Etnia e1 ON p1.etnia = e1.id_etnia
LEFT JOIN Etnia e2 ON p2.etnia = e2.id_etnia
LEFT JOIN UbicacionResidencia ur ON p1.id_ubicacion_residencia = ur.id
LEFT JOIN Pais pais ON p1.id_pais = pais.cod_pais;


/*---------------CONSULTAS-------------------------------------*/

-- 1. Consulta: Matrimonios durante meses específicos (Tendencias de temporada)
SELECT
    mes,
    CASE mes
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
        ELSE 'Desconocido'
    END AS nombre_mes,
    COUNT(*) AS total_matrimonios
FROM (
    SELECT MONTH(fecha_insc) AS mes
    FROM MatrimonioFinal
    WHERE fecha_insc IS NOT NULL
) AS sub
GROUP BY mes
ORDER BY total_matrimonios DESC;

-- 2. Consulta Matrimonios por etnia (etnia1, etnia2)
SELECT
    e.descripcion AS etnia,
    COUNT(*) AS total_matrimonios
FROM (
    -- Persona 1
    SELECT p.etnia_id
    FROM MatrimonioFinal m
    JOIN Persona p ON m.persona1_id = p.id_persona
    WHERE p.etnia_id IS NOT NULL

    UNION ALL

    -- Persona 2
    SELECT p.etnia_id
    FROM MatrimonioFinal m
    JOIN Persona p ON m.persona2_id = p.id_persona
    WHERE p.etnia_id IS NOT NULL
) AS todas_etnias
JOIN Etnia e ON todas_etnias.etnia_id = e.id_etnia
GROUP BY e.descripcion
ORDER BY total_matrimonios DESC;

-- 3.Consulta Matrimonios por provincia (provincia)
SELECT
    CASE
        WHEN p1.nacionalidad = p2.nacionalidad THEN 'Misma Nacionalidad'
        ELSE 'Diferente Nacionalidad'
    END AS nationality_match,
    COUNT(*) AS total_matrimonios
FROM MatrimonioFinal m
JOIN Persona p1 ON m.persona1_id = p1.id_persona
JOIN Persona p2 ON m.persona2_id = p2.id_persona
WHERE p1.nacionalidad IS NOT NULL AND p2.nacionalidad IS NOT NULL
GROUP BY nationality_match
ORDER BY total_matrimonios DESC;
 -- 4.Consulta Top 10 provincias con más matrimonios
SELECT
    u.provincia,
    COUNT(*) AS total_matrimonios
FROM MatrimonioFinal m
JOIN Persona p1 ON m.persona1_id = p1.id_persona
JOIN UbicacionResidencia u ON p1.id_ubicacion_residencia = u.id
GROUP BY u.provincia
ORDER BY total_matrimonios DESC
LIMIT 10;

-- 5.Consulta Relación entre pobreza (NBI) e IDH por provincia
SELECT
    mv.provincia,
    i.pobreza_nbi,
    i.idh
FROM
    MatrimonioVistaCompleta mv
JOIN
    indicadores_provincia i
    ON LOWER(TRIM(mv.provincia)) = LOWER(TRIM(i.provincia))
GROUP BY
    mv.provincia, i.pobreza_nbi, i.idh
ORDER BY
    i.pobreza_nbi DESC;

