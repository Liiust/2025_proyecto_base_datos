# 2025_proyecto_base_datos
Comparación de la evolución del uso del suelo en París entre 2015 y 2025 con los planes de planificación urbana de la ciudad con SQL (pgAdmin 4).

Para descargar el backup con la base de datos : https://upm365-my.sharepoint.com/:u:/g/personal/daniel_ortuno_alumnos_upm_es/ERHWrqjPNIxEoDc86VFe19UBClifBrG28CWWj_I4ipTm1Q?e=aW0Bgr  

Utilizando PostGIS, junto con las más extensiones compatibles con PostgreSQL, desarrollamos un proyecto de análisis de datos geoespaciales dirigido por preguntas de interés (por ejemplo, para el análisis exploratorio), objetivos (por ejemplo, creación de mapas temáticos a partir de ráster) e interpretación de los resultados.

Vamos a trabajar usando dos bases de datos de París, una de 2015 y la otra de 2025, con objetivo de ver los cambios espaciales que se han realizado en la ciudad a lo largo de 10 años, profundizando en la edificación, espacios verdes y las infraestructuras de transporte y red viaria.

Los datos provienen del IGN Francés del catálogo de BD TOPO®: BD TOPO® | Géoservices, del departamento 75 (París).

Aunque tengan una diferencia de 10 años, la estructura de los temas es parecida y está inspirado por las normativas Inspire:
  Administrativo (límites y unidades administrativas);
  Edificios (construcciones);
  Hidrografía (elementos relacionados con el agua);
  Lugares con nombre (un lugar o localidad que tiene un topónimo y describe un espacio natural o un lugar habitado);
  Uso del suelo (vegetación, zona costera, setos);
  Servicios y actividades (servicios públicos, almacenamiento y transporte de energía, emplazamientos y ubicaciones industriales);
  Transporte (infraestructura de redes de carreteras, ferrocarriles y aire, rutas);
  Zonas reguladas (la mayoría de las zonas están sujetas a regulaciones específicas)

En ambos años las capas están proyectadas en Lambert 93 con Datum geodésico RGF93, código: EPSG 2154.
