-- 1) Contagem
SELECT 'prodes_2022' AS layer, COUNT(*) AS n FROM public.prodes_2022
UNION ALL
SELECT 'cnuc', COUNT(*) FROM public.cnuc
UNION ALL
SELECT 'rodovias', COUNT(*) FROM public.rodovias
UNION ALL
SELECT 'rg2017', COUNT(*) FROM public.rg2017;

-- 2) SRID + tipo
SELECT 'prodes_2022' AS layer, ST_SRID(geometry) AS srid, GeometryType(geometry) AS geom_type, COUNT(*) AS n
FROM public.prodes_2022 GROUP BY 1,2,3
UNION ALL
SELECT 'cnuc', ST_SRID(geometry), GeometryType(geometry), COUNT(*) FROM public.cnuc GROUP BY 1,2,3
UNION ALL
SELECT 'rodovias', ST_SRID(geometry), GeometryType(geometry), COUNT(*) FROM public.rodovias GROUP BY 1,2,3
UNION ALL
SELECT 'rg2017', ST_SRID(geometry), GeometryType(geometry), COUNT(*) FROM public.rg2017 GROUP BY 1,2,3;

-- 3) Geometrias inválidas
SELECT 'prodes_2022' AS layer, COUNT(*) AS invalid FROM public.prodes_2022 WHERE NOT ST_IsValid(geometry)
UNION ALL
SELECT 'cnuc', COUNT(*) FROM public.cnuc WHERE NOT ST_IsValid(geometry)
UNION ALL
SELECT 'rodovias', COUNT(*) FROM public.rodovias WHERE NOT ST_IsValid(geometry)
UNION ALL
SELECT 'rg2017', COUNT(*) FROM public.rg2017 WHERE NOT ST_IsValid(geometry);

-- 4) Extent (só pra “bater o olho” se está no Brasil)
SELECT 'prodes_2022' AS layer, ST_Extent(geometry) AS extent FROM public.prodes_2022
UNION ALL
SELECT 'cnuc', ST_Extent(geometry) FROM public.cnuc
UNION ALL
SELECT 'rodovias', ST_Extent(geometry) FROM public.rodovias
UNION ALL
SELECT 'rg2017', ST_Extent(geometry) FROM public.rg2017;
