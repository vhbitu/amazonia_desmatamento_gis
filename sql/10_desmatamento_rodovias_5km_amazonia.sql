DROP VIEW IF EXISTS public.vw_desmatamento_ate_5km_rodovias_amazonia_2022;
DROP TABLE IF EXISTS public.rodovias_amazonia_buffer_5km_5880;
DROP TABLE IF EXISTS public.rodovias_amazonia_union_5880;

ANALYZE public.prodes_2022_amazonia;
ANALYZE public.rodovias_amazonia;

-- 1) Une rodovias (1 geometria)
DROP TABLE IF EXISTS public.rodovias_amazonia_union_5880;

CREATE TABLE public.rodovias_amazonia_union_5880 AS
SELECT ST_SetSRID(ST_UnaryUnion(ST_Collect(geometry)), 5880) AS geometry
FROM public.rodovias_amazonia;

CREATE INDEX IF NOT EXISTS idx_rodovias_amazonia_union_geom
ON public.rodovias_amazonia_union_5880 USING GIST (geometry);

ANALYZE public.rodovias_amazonia_union_5880;

-- 2) Buffer 5km
DROP TABLE IF EXISTS public.rodovias_amazonia_buffer_5km_5880;

CREATE TABLE public.rodovias_amazonia_buffer_5km_5880 AS
SELECT ST_Buffer(geometry, 5000) AS geometry
FROM public.rodovias_amazonia_union_5880;

CREATE INDEX IF NOT EXISTS idx_rodovias_amazonia_buffer_5km_geom
ON public.rodovias_amazonia_buffer_5km_5880 USING GIST (geometry);

ANALYZE public.rodovias_amazonia_buffer_5km_5880;

-- 3) Métrica (ha) até 5km vs acima
DROP VIEW IF EXISTS public.vw_desmatamento_ate_5km_rodovias_amazonia_2022;

CREATE VIEW public.vw_desmatamento_ate_5km_rodovias_amazonia_2022 AS
SELECT
  SUM(ST_Area(p.geometry))/10000.0 AS total_ha,
  SUM(ST_Area(ST_Intersection(p.geometry, b.geometry)))/10000.0 AS ate_5km_ha,
  (SUM(ST_Area(p.geometry)) - SUM(ST_Area(ST_Intersection(p.geometry, b.geometry))))/10000.0 AS acima_5km_ha,
  (SUM(ST_Area(ST_Intersection(p.geometry, b.geometry))) / NULLIF(SUM(ST_Area(p.geometry)),0)) * 100.0 AS pct_ate_5km
FROM public.prodes_2022_amazonia p
CROSS JOIN public.rodovias_amazonia_buffer_5km_5880 b;

SELECT * FROM public.vw_desmatamento_ate_5km_rodovias_amazonia_2022;
