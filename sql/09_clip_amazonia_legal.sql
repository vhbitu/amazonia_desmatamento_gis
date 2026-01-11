-- 09_clip_amazonia_legal.sql

ANALYZE public.amazonia_legal_union_5880;
ANALYZE public.prodes_2022;
ANALYZE public.cnuc;
ANALYZE public.rodovias;

-- PRODES recortado pela Amazônia Legal (geometria clipada)
DROP TABLE IF EXISTS public.prodes_2022_amazonia;

CREATE TABLE public.prodes_2022_amazonia AS
SELECT
  p.*,
  ST_Multi(ST_CollectionExtract(ST_Intersection(p.geometry, a.geometry), 3)) AS geom_clip
FROM public.prodes_2022 p
JOIN public.amazonia_legal_union_5880 a
  ON ST_Intersects(p.geometry, a.geometry);

ALTER TABLE public.prodes_2022_amazonia DROP COLUMN geometry;
ALTER TABLE public.prodes_2022_amazonia RENAME COLUMN geom_clip TO geometry;

DELETE FROM public.prodes_2022_amazonia
WHERE geometry IS NULL OR ST_IsEmpty(geometry);

CREATE INDEX IF NOT EXISTS idx_prodes_2022_amazonia_geom
ON public.prodes_2022_amazonia USING GIST (geometry);

ANALYZE public.prodes_2022_amazonia;

-- CNUC (só UCs com parte na Amazônia e não marinhas)
DROP TABLE IF EXISTS public.cnuc_amazonia;

CREATE TABLE public.cnuc_amazonia AS
SELECT c.*
FROM public.cnuc c
JOIN public.amazonia_legal_union_5880 a
  ON ST_Intersects(c.geometry, a.geometry)
WHERE (NULLIF(TRIM(c.amazonia),'')::double precision) > 0
  AND COALESCE(NULLIF(TRIM(c.marinho),'')::double precision, 0) = 0;

CREATE INDEX IF NOT EXISTS idx_cnuc_amazonia_geom
ON public.cnuc_amazonia USING GIST (geometry);

ANALYZE public.cnuc_amazonia;

-- Rodovias dentro da Amazônia Legal
DROP TABLE IF EXISTS public.rodovias_amazonia;

CREATE TABLE public.rodovias_amazonia AS
SELECT r.*
FROM public.rodovias r
JOIN public.amazonia_legal_union_5880 a
  ON ST_Intersects(r.geometry, a.geometry);

CREATE INDEX IF NOT EXISTS idx_rodovias_amazonia_geom
ON public.rodovias_amazonia USING GIST (geometry);

ANALYZE public.rodovias_amazonia;

-- Checagem rápida
SELECT 'prodes_2022_amazonia' AS layer, COUNT(*) AS n FROM public.prodes_2022_amazonia
UNION ALL
SELECT 'cnuc_amazonia', COUNT(*) FROM public.cnuc_amazonia
UNION ALL
SELECT 'rodovias_amazonia', COUNT(*) FROM public.rodovias_amazonia;
