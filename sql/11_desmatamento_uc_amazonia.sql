ANALYZE public.prodes_2022_amazonia;
ANALYZE public.cnuc_amazonia;

-- 1) Desmatamento por UC (Top 10)
DROP TABLE IF EXISTS public.resumo_desmatamento_uc_amazonia_2022;

CREATE TABLE public.resumo_desmatamento_uc_amazonia_2022 AS
SELECT
  c.uc_id,
  c.nome_uc,
  SUM(ST_Area(ST_Intersection(p.geometry, c.geometry))) / 10000.0 AS area_desmatada_ha
FROM public.prodes_2022_amazonia p
JOIN public.cnuc_amazonia c
  ON ST_Intersects(p.geometry, c.geometry)
GROUP BY c.uc_id, c.nome_uc
ORDER BY area_desmatada_ha DESC;

SELECT *
FROM public.resumo_desmatamento_uc_amazonia_2022
ORDER BY area_desmatada_ha DESC
LIMIT 10;

-- 2) Total dentro vs fora de UCs (união 1 vez)
DROP TABLE IF EXISTS public.cnuc_amazonia_union_5880;

CREATE TABLE public.cnuc_amazonia_union_5880 AS
SELECT ST_SetSRID(ST_UnaryUnion(ST_Collect(geometry)), 5880) AS geometry
FROM public.cnuc_amazonia;

CREATE INDEX IF NOT EXISTS idx_cnuc_amazonia_union_geom
ON public.cnuc_amazonia_union_5880 USING GIST (geometry);

ANALYZE public.cnuc_amazonia_union_5880;

DROP VIEW IF EXISTS public.vw_desmatamento_dentro_fora_uc_amazonia_2022;

CREATE VIEW public.vw_desmatamento_dentro_fora_uc_amazonia_2022 AS
SELECT
  SUM(ST_Area(p.geometry))/10000.0 AS total_ha,
  SUM(ST_Area(ST_Intersection(p.geometry, u.geometry)))/10000.0 AS dentro_uc_ha,
  (SUM(ST_Area(p.geometry)) - SUM(ST_Area(ST_Intersection(p.geometry, u.geometry))))/10000.0 AS fora_uc_ha,
  (SUM(ST_Area(ST_Intersection(p.geometry, u.geometry))) / NULLIF(SUM(ST_Area(p.geometry)),0)) * 100.0 AS pct_dentro_uc
FROM public.prodes_2022_amazonia p
CROSS JOIN public.cnuc_amazonia_union_5880 u;

SELECT * FROM public.vw_desmatamento_dentro_fora_uc_amazonia_2022;
