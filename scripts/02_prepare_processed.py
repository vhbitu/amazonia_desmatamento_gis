import geopandas as gpd
from pathlib import Path

gpd.options.io_engine = "fiona"

TARGET_CRS = "EPSG:5880"  # CRS métrico p/ medidas (dist/área)
PRODES_YEAR = 2022        # ajuste se quiser outro ano

def encoding_from_cpg(shp: Path) -> str | None:
    cpg = shp.with_suffix(".cpg")
    if not cpg.exists():
        return None
    txt = cpg.read_text(errors="ignore").strip().lower().replace(" ", "").replace("-", "")
    if "utf8" in txt:
        return "utf-8"
    if "1252" in txt or "cp1252" in txt:
        return "cp1252"
    if "latin1" in txt or "iso88591" in txt:
        return "latin1"
    return None

def read(shp_path: str) -> gpd.GeoDataFrame:
    p = Path(shp_path)
    enc = encoding_from_cpg(p)
    return gpd.read_file(p, encoding=enc) if enc else gpd.read_file(p)

out_dir = Path("data/processed")
out_dir.mkdir(parents=True, exist_ok=True)

datasets = {
    "cnuc": "data/raw/ucs_cnuc/cnuc_2025_08.shp",
    "rodovias": "data/raw/rodovias_ibge/2014/rodovia_2014.shp",
    "br_uf_2024": "data/raw/estados/BR_UF_2024.shp",
}

# 1) pequenos: salva tudo
for name, fp in datasets.items():
    print(f"\n== {name} ==")
    gdf = read(fp).to_crs(TARGET_CRS)
    out = out_dir / f"{name}.gpkg"
    gdf.to_file(out, layer=name, driver="GPKG")
    print("saved:", out, "| rows:", len(gdf))

# 2) PRODES: salva só 1 ano (pra não explodir)
print("\n== prodes ==")
prodes_fp = "data/raw/desmatamento_prodes/yearly_deforestation_biome.shp"
prodes = gpd.read_file(prodes_fp, where=f"year = {PRODES_YEAR}").to_crs(TARGET_CRS)

# mantém só o essencial
keep = ["state", "source", "main_class", "class_name", "year", "area_km", "uuid", "geometry"]
prodes = prodes[[c for c in keep if c in prodes.columns]]

out = out_dir / f"prodes_{PRODES_YEAR}.gpkg"
prodes.to_file(out, layer=f"prodes_{PRODES_YEAR}", driver="GPKG")
print("saved:", out, "| rows:", len(prodes))
