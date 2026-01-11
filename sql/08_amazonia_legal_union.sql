DROP TABLE IF EXISTS public.amazonia_legal_union_5880;

CREATE TABLE public.amazonia_legal_union_5880 AS
SELECT
  ST_SetSRID(ST_UnaryUnion(ST_Collect(geometry)), 5880) AS geometry
FROM public.rg2017
WHERE (NULLIF(TRIM("UF"),'')::integer) IN (11,12,13,14,15,16,17,21,51);

CREATE INDEX IF NOT EXISTS idx_amazonia_legal_union_geom
ON public.amazonia_legal_union_5880 USING GIST (geometry);

ANALYZE public.amazonia_legal_union_5880;

-- conferência rápida
SELECT ST_Area(geometry)/10000.0 AS area_ha
FROM public.amazonia_legal_union_5880;
Get-Content -Raw .\sql\08_amazonia_legal_union.sql | docker exec -i projeto_gis_postgis psql -U vhbitu -d projeto_gis
