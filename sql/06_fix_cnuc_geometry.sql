-- Remove linhas sem geometria
DELETE FROM public.cnuc
WHERE geometry IS NULL OR ST_IsEmpty(geometry);

-- Corrige geometrias inválidas (self-intersection etc.)
UPDATE public.cnuc
SET geometry = ST_Multi(ST_CollectionExtract(ST_MakeValid(geometry), 3))
WHERE NOT ST_IsValid(geometry);

-- Garante SRID 5880 (só por segurança)
UPDATE public.cnuc
SET geometry = ST_SetSRID(geometry, 5880)
WHERE ST_SRID(geometry) IS DISTINCT FROM 5880;
