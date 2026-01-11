CREATE INDEX IF NOT EXISTS idx_cnuc_geom
ON public.cnuc USING GIST (geometry);

CREATE INDEX IF NOT EXISTS idx_rodovias_geom
ON public.rodovias USING GIST (geometry);

CREATE INDEX IF NOT EXISTS idx_rg2017_geom
ON public.rg2017 USING GIST (geometry);

CREATE INDEX IF NOT EXISTS idx_prodes_2022_geom
ON public.prodes_2022 USING GIST (geometry);


-- Comando que deve ser executado no terminal para criação dos indexes:
-- docker exec -i projeto_gis_postgis psql -U vhbitu -d projeto_gis < sql/04_create_spatial_indexes.sql