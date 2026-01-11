-- 07_prodes_vs_cnuc.sql (otimizado)

ANALYZE public.cnuc;
ANALYZE public.prodes_2022;

-- 1) Área desmatada por UC (ha)
DROP TABLE IF EXISTS public.resumo_desmatamento_uc_2022;

CREATE TABLE public.resumo_desmatamento_uc_2022 AS
SELECT
  c.uc_id,
  c.nome_uc,
  SUM(ST_Area(ST_Intersection(p.geometry, c.geometry))) / 10000.0 AS area_desmatada_ha
FROM public.prodes_2022 p
JOIN public.cnuc c
  ON ST_Intersects(p.geometry, c.geometry)
GROUP BY c.uc_id, c.nome_uc
ORDER BY area_desmatada_ha DESC;

-- Top 10
SELECT *
FROM public.resumo_desmatamento_uc_2022
ORDER BY area_desmatada_ha DESC
LIMIT 10;

-- 2) Materializa a união de todas as UCs (1 vez)
DROP TABLE IF EXISTS public.cnuc_union_5880;

CREATE TABLE public.cnuc_union_5880 AS
SELECT ST_SetSRID(ST_UnaryUnion(ST_Collect(geometry)), 5880) AS geometry
FROM public.cnuc;

ANALYZE public.cnuc_union_5880;

-- 3) Total dentro vs fora (ha)
DROP VIEW IF EXISTS public.vw_desmatamento_dentro_fora_uc_2022;

CREATE VIEW public.vw_desmatamento_dentro_fora_uc_2022 AS
SELECT
  SUM(ST_Area(p.geometry))/10000.0 AS total_ha,
  SUM(ST_Area(ST_Intersection(p.geometry, u.geometry)))/10000.0 AS dentro_ha,
  (SUM(ST_Area(p.geometry)) - SUM(ST_Area(ST_Intersection(p.geometry, u.geometry))))/10000.0 AS fora_ha,
  (SUM(ST_Area(ST_Intersection(p.geometry, u.geometry))) / NULLIF(SUM(ST_Area(p.geometry)),0)) * 100.0 AS pct_dentro_uc
FROM public.prodes_2022 p
CROSS JOIN public.cnuc_union_5880 u;

SELECT * FROM public.vw_desmatamento_dentro_fora_uc_2022