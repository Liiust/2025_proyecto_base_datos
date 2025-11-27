--1 VEGETACION
--1   diferencia de las areas de las zonas verdas
SELECT
  (SELECT SUM(ST_Area(v.geom)) FROM ano2025.vegetacion v) AS Veg2025,
  (SELECT SUM(ST_Area(s.geom)) FROM ano2025.setos s)AS Setos2025,
  (SELECT SUM(ST_Area(v1.geom)) FROM ano2015."vegetacion" v1) AS Veg2015,
  ((SELECT SUM(ST_Area(v.geom)) FROM ano2025.vegetacion v) +(SELECT SUM(ST_Area(s.geom)) FROM ano2025.setos s) -(SELECT SUM(ST_Area(v1.geom)) FROM ano2015."vegetacion" v1));


--2   porcentaje de las zonas verdes en cada distrito administrativo en ambos años
--el municipios de paris esta dividio en 20 distritos administrativos

SELECT ad."NOM" AS Distrito,100*(SELECT SUM(ST_Area(ST_Intersection(ad.geom, ve.geom)) )FROM ano2025.vegetacion ve
WHERE ST_Intersects(ad.geom, ve.geom))/ ST_Area(ad.geom) AS Pvegetacion2025,

100*(SELECT SUM(ST_Area(ST_Intersection(ad.geom, ve2.geom)))FROM ano2015.vegetacion ve2
WHERE ST_Intersects(ad.geom, ve2.geom))/ST_Area(ad.geom) AS Pvegetacion2015

FROM public."ARRONDISSEMENT_2015" ad
ORDER BY ad."NOM";
--3 estadisticos
WITH porcentajes AS (
    SELECT ad."NOM" AS distrito,
    100 * (SELECT SUM(ST_Area(ST_Intersection(ad.geom,ve.geom)))FROM ano2025.vegetacion ve
            WHERE ST_Intersects(ad.geom,ve.geom))/ST_Area(ad.geom) AS pveg_2025,
    100 * (SELECT SUM(ST_Area(ST_Intersection(ad.geom, ve2.geom)))FROM ano2015.vegetacion ve2
            WHERE ST_Intersects(ad.geom,ve2.geom))/ST_Area(ad.geom) AS pveg_2015
    FROM public."ARRONDISSEMENT_2015" ad)
SELECT
-- 2015
MIN(pveg_2015) AS min_2015,
MAX(pveg_2015) AS max_2015,
MAX(pveg_2015) - MIN(pveg_2015) AS rango_2015,
AVG(pveg_2015) AS media_2015,
STDDEV_POP(pveg_2015) AS desv_2015,
-- 2025
MIN(pveg_2025) AS min_2025,
MAX(pveg_2025) AS max_2025,
MAX(pveg_2025) - MIN(pveg_2025) AS rango_2025,
AVG(pveg_2025) AS media_2025,
STDDEV_POP(pveg_2025) AS desv_2025 FROM porcentajes;


--EDIFICACION
--4  diferencia de las areas de las zonas de edificios
WITH edificios_2015 AS (
    SELECT 'industrial'::text tipo_edificio, geom FROM ano2015.edificios_industriales
	UNION ALL
    SELECT 'indiferenciado'::text tipo_edificio, geom FROM ano2015.edificios_indiferenciados
    UNION ALL
    SELECT 'singular'::text tipo_edificio, geom FROM ano2015.edificios_singulares
),
area_2015 AS (
    SELECT SUM(ST_Area(geom)) area_2015 FROM edificios_2015
),
area_2025 AS (
    SELECT SUM(ST_Area(geom)) area_2025 FROM ano2025.edificios
)
SELECT area_2015,area_2025,area_2025 - area_2015 diferencia_area FROM area_2015, area_2025;

--5  cantidad  total de edificios de cada tipo
--SELECT DISTINCT "NATURE" FROM ano2025.edificios ORDER BY "NATURE";
WITH edificios_2015 AS (
    SELECT 'industrial'::text tipo_edificio, geom FROM ano2015.edificios_industriales
	UNION ALL
    SELECT 'indiferenciado'::text tipo_edificio, geom FROM ano2015.edificios_indiferenciados
    UNION ALL
    SELECT 'singular'::text tipo_edificio, geom FROM ano2015.edificios_singulares
),
ced2015 AS(
    SELECT COUNT(*) total15,
           COUNT(*) FILTER(WHERE tipo_edificio='industrial') indu2015,
           COUNT(*) FILTER(WHERE tipo_edificio='indiferenciado') indi2015 FROM edificios_2015
          --, COUNT(*) FILTER(WHERE tipo_edificio='singular') sing2015 FROM edificios_2015
),
ced2025 AS(
    SELECT COUNT(*) total25,
		   COUNT(*) FILTER(WHERE "NATURE"='Industriel, agricole ou commercial') indu2025,
           COUNT(*) FILTER(WHERE "NATURE"='Indifférenciée') indi2025 FROM ano2025.edificios)
SELECT total15 as total2015,total25 as total2025,indu2015 as industriales2015,indu2025 as industriales2025,indi2015 as indiferenciados2015,indi2025 as indiferenciados2025 FROM ced2015,ced2025;
--5. apartado aparte   --edificios industriales(industrial y comercio)
WITH indus2015 AS(
    SELECT "NATURE" FROM ano2015.edificios_industriales
),
ced2015 AS(
    SELECT COUNT(*) total15,
           SUM(("NATURE"='Bâtiment industriel')::int) ind15,
           SUM(("NATURE"='Bâtiment commercial')::int) com15
    FROM indus2015
),
indus2025 AS(
    SELECT "NATURE","USAGE1" FROM ano2025.edificios
    WHERE "NATURE"='Industriel, agricole ou commercial'),
ced2025 AS(
SELECT COUNT(*) total25,SUM(("USAGE1"='Industriel')::int) ind25,SUM(("USAGE1"='Commercial et services')::int) com25 FROM indus2025)
SELECT total15,total25,ind15,ind25,com15,com25 FROM ced2015,ced2025;


--EDIFICIO Y VEGETACION
--6--¿Cuántas zonas verdes de 2025 se sitúan donde en 2015 había edificios?
WITH edif15 AS(
  SELECT geom FROM ano2015.edificios_industriales
  UNION ALL SELECT geom FROM ano2015.edificios_indiferenciados
  UNION ALL SELECT geom FROM ano2015.edificios_singulares
)
SELECT COUNT(*) veg2025_sobre_edif2015
FROM ano2025.vegetacion v,edif15 e
WHERE ST_Within(ST_Centroid(v.geom),e.geom);

--7--edificios cerca de zonas verdes 2015 vs 2025(teniendo las zonas verdes un área minima de 100m2)
WITH edificios_2015 AS(
    SELECT 'industrial'::text tipo_edificio,"ID",geom FROM ano2015.edificios_industriales
    UNION ALL SELECT 'indiferenciado'::text tipo_edificio,"ID",geom FROM ano2015.edificios_indiferenciados
    UNION ALL SELECT 'singular'::text tipo_edificio,"ID",geom FROM ano2015.edificios_singulares
),
edificios_2025 AS (SELECT "ID",geom AS geom FROM ano2025.edificios),
veg2015 AS (SELECT geom  FROM ano2015.vegetacion
    WHERE ST_Area(geom) >= 100),
veg2025 AS (SELECT geom AS geom FROM ano2025.vegetacion
    WHERE ST_Area(geom) >= 100 ),
tot15 AS(SELECT COUNT(*) tot15 FROM edificios_2015),
tot25 AS(SELECT COUNT(*) tot25 FROM edificios_2025),
cerca_2015 AS(SELECT COUNT(DISTINCT e."ID") AS edif2015_cerca_verde FROM edificios_2015 e, veg2015 v
    WHERE ST_DWithin(e.geom, v.geom, 50)),
cerca_2025 AS(SELECT COUNT(DISTINCT e."ID") AS edif2025_cerca_verde FROM edificios_2025 e, veg2025 v
     WHERE ST_DWithin(e.geom, v.geom, 50))
SELECT tot15.tot15,tot25.tot25,c15.edif2015_cerca_verde,c25.edif2025_cerca_verde FROM cerca_2015 c15, cerca_2025 c25, tot15, tot25;


--8¿Qué distritos tienen más “verde por m² de edificio” en 2015 y en 2025?
WITH edificios_2015 AS(
    SELECT geom FROM ano2015.edificios_industriales
    UNION ALL
	SELECT geom FROM ano2015.edificios_indiferenciados
    UNION ALL
	SELECT geom FROM ano2015.edificios_singulares
),
datos AS(
    SELECT ad."NOM" distrito,
           (SELECT SUM(ST_Area(ST_Intersection(ad.geom,v15.geom))) FROM ano2015.vegetacion v15
            WHERE ST_Intersects(ad.geom,v15.geom)) area_veg15,
           (SELECT SUM(ST_Area(ST_Intersection(ad.geom,e15.geom))) FROM edificios_2015 e15
            WHERE ST_Intersects(ad.geom,e15.geom)) area_edif15,
           (SELECT SUM(ST_Area(ST_Intersection(ad.geom,v25.geom))) FROM ano2025.vegetacion v25
            WHERE ST_Intersects(ad.geom,v25.geom)) area_veg25,
           (SELECT SUM(ST_Area(ST_Intersection(ad.geom,e25.geom))) FROM ano2025.edificios e25
            WHERE ST_Intersects(ad.geom,e25.geom)) area_edif25 FROM public."ARRONDISSEMENT_2015" ad
)
SELECT distrito,area_veg15,area_edif15,area_veg25,area_edif25,area_veg15*100/(area_edif15) rel15,area_veg25*100/(area_edif25) rel25 FROM datos
ORDER BY distrito;



--EDIFICIO Y TREN
--9--¿Cuántos edificios están a menos de 100 metros de la red ferroviaria en 2015 y en 2025?
WITH edificios_2015 AS(
    SELECT 'industrial'::text tipo_edificio,"ID",geom FROM ano2015.edificios_industriales
	UNION ALL 
	SELECT 'indiferenciado'::text tipo_edificio,"ID",geom FROM ano2015.edificios_indiferenciados
    UNION ALL 
	SELECT 'singular'::text tipo_edificio,"ID",geom FROM ano2015.edificios_singulares
),
cerca_2015 AS(
    SELECT COUNT(DISTINCT e."ID") edif2015_cerca_tren FROM edificios_2015 e ,ano2015.lineas_de_tren l
    WHERE ST_DWithin(e.geom,l.geom,100)
),
cerca_2025 AS(
    SELECT COUNT(DISTINCT e."ID") edif2025_cerca_tren FROM ano2025.edificios e,ano2025.viastren l
    WHERE ST_DWithin(e.geom,l.geom,100)
)
SELECT edif2015_cerca_tren,edif2025_cerca_tren,edif2025_cerca_tren-edif2015_cerca_tren diferencia
FROM cerca_2015,cerca_2025;

--SELECT DISTINCT "CATEGORIE" FROM ano2025.actividad_superficie ORDER BY "CATEGORIE";

--EDIFICIO Y CARRETERA
--10--¿Cuantos edificios residenciales estan por lo menos 50 metros de las carreteras de primer orden?
WITH edificios_2015 AS(
    SELECT 'industrial'::text tipo,"ID",geom FROM ano2015.edificios_industriales
    UNION ALL
    SELECT 'indiferenciado',"ID",geom FROM ano2015.edificios_indiferenciados
    UNION ALL
    SELECT 'singular',"ID",geom FROM ano2015.edificios_singulares
),
carre15 AS(SELECT geom FROM ano2015.carreteras WHERE "IMPORTANCE"='1' OR "IMPORTANCE"='2'),
carre25 AS(SELECT geom FROM ano2025.carreteras WHERE "IMPORTANCE"='1' OR "IMPORTANCE"='2'),
cerca_2015 AS(
    SELECT COUNT(DISTINCT e."ID") edif2015_cerca_carretera FROM edificios_2015 e,carre15 c
    WHERE ST_DWithin(e.geom,c.geom,50)
),
cerca_2025 AS(
    SELECT COUNT(DISTINCT e."ID") edif2025_cerca_carretera FROM ano2025.edificios e,carre25 c
    WHERE ST_DWithin(e.geom,c.geom,50)
)
SELECT edif2015_cerca_carretera,edif2025_cerca_carretera,
       edif2025_cerca_carretera-edif2015_cerca_carretera AS diferencia
FROM cerca_2015,cerca_2025;

-- LINEAS DE TREN
--11 ¿Cómo han evolucionado las líneas ferroviarias?

-- Longitud total en París
SELECT
    (SELECT SUM(ST_Length(geom)) FROM ano2015.lineas_de_tren) AS longitud_2015,
    (SELECT SUM(ST_Length(geom)) FROM ano2025.viastren) AS longitud_2025,
    (SELECT SUM(ST_Length(geom)) FROM ano2025.viastren) -
    (SELECT SUM(ST_Length(geom)) FROM ano2015.lineas_de_tren) AS diferencia;

-- Líneas nuevas en 2025 comparado a 2015
WITH params AS (
    SELECT 2 AS tolerancia --en metros
)
SELECT COUNT(*) AS lineas_nuevas_2025
FROM ano2025.viastren l2025
LEFT JOIN ano2015.lineas_de_tren l2015
  ON ST_DWithin(
        l2025.geom,
        l2015.geom,
        (SELECT tolerancia FROM params)
     )
WHERE l2015.id IS NULL;

-- Líneas que han desaparecido en 2025 comparado a 2015
WITH params AS (
    SELECT 2 AS tolerancia   -- en metros
)
SELECT COUNT(*) AS lineas_desaparecidas_2015
FROM ano2015.lineas_de_tren l2015
LEFT JOIN ano2025.viastren l2025
  ON ST_DWithin(
        l2015.geom,
        l2025.geom,
        (SELECT tolerancia FROM params)
     )
WHERE l2025.id IS NULL;

-- 12 ¿Hay una autocorrelación espacial entre la red de transporte y las zonas verdes?
-- En 2015
WITH total AS (
    SELECT SUM(ST_Length(geom)) AS tot
    FROM ano2015.lineas_de_tren
),
buffer_veg AS (
    SELECT ST_Union(ST_Buffer(geom, 100)) AS geom
    FROM ano2015.vegetacion
),
cerca AS (
    SELECT SUM(ST_Length(ST_Intersection(l2015.geom, b.geom))) AS cerca
    FROM ano2015.lineas_de_tren l2015, buffer_veg b
)
SELECT (cerca.cerca / total.tot) * 100 AS porcentaje_2015
FROM cerca, total;

--En 2025
WITH total AS (
    SELECT SUM(ST_Length(geom)) AS tot
    FROM ano2025.viastren
),
buffer_veg AS (
    SELECT ST_Union(ST_Buffer(geom, 100)) AS geom
    FROM ano2025.vegetacion
),
cerca AS (
    SELECT SUM(ST_Length(ST_Intersection(l2025.geom, b.geom))) AS cerca
    FROM ano2025.viastren l2025, buffer_veg b
)
SELECT (cerca.cerca / total.tot) * 100 AS porcentaje_2025
FROM cerca, total;

-- 13 ¿Hay una autocorrelación espacial entre los edificios industriales y las líneas de tren (en 2015)?
WITH tot AS (
    SELECT COUNT(*) AS total
    FROM ano2015.edificios_industriales
),
cerca AS (
    SELECT COUNT(DISTINCT e.id) AS cerca
    FROM ano2015.edificios_industriales e
    JOIN ano2015.lineas_de_tren l
        ON ST_DWithin(e.geom, l.geom, 100)
)
SELECT cerca.cerca, tot.total,
       (cerca.cerca::float / tot.total) * 100 AS porcentaje
FROM cerca, tot;

-- 14 Distritos y su concentración de edificios industriales en 2015
WITH edificios AS (
    SELECT geom FROM ano2015.edificios_industriales
),
datos AS (
    SELECT ad."NOM" distrito,
           SUM(ST_Area(ST_Intersection(ad.geom, e.geom))) AS area_industrial,
           ST_Area(ad.geom) AS area_distrito
    FROM public."ARRONDISSEMENT_2015" ad
    LEFT JOIN edificios e
      ON ST_Intersects(ad.geom, e.geom)
    GROUP BY ad."NOM", ad.geom
)
SELECT distrito,
       area_industrial,
       area_distrito,
       area_industrial / area_distrito * 100 AS porcentaje_industrial
FROM datos
ORDER BY porcentaje_industrial DESC;










	
