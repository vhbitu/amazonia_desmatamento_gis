from pathlib import Path
import fiona

DATASETS = [
    ("prodes", Path("data/raw/desmatamento_prodes/yearly_deforestation_biome.shp")),
    ("cnuc", Path("data/raw/ucs_cnuc/cnuc_2025_08.shp")),
    ("rodovias", Path("data/raw/rodovias_ibge/2014/rodovia_2014.shp")),
    ("rg2017", Path("data/raw/estados/RG2017_regioesgeograficas2017.shp")),
]

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

def open_fiona(path: Path):
    preferred = encoding_from_cpg(path)
    candidates = []
    if preferred:
        candidates.append(preferred)
    candidates += ["utf-8", "cp1252", "latin1"]

    last_err = None
    for enc in candidates:
        try:
            src = fiona.open(path, encoding=enc)
            return src, enc
        except Exception as ex:
            last_err = ex

    # último fallback sem encoding explícito
    try:
        src = fiona.open(path)
        return src, None
    except Exception as ex:
        raise last_err or ex

for name, shp in DATASETS:
    print(f"\n== {name} ==")
    print("file:", shp)

    src, enc_used = open_fiona(shp)
    with src:
        print("encoding:", enc_used)
        print("driver:", src.driver)
        print("crs:", src.crs_wkt or src.crs)
        print("bounds:", src.bounds)
        try:
            print("features:", len(src))
        except Exception:
            print("features: (n/a)")

        props = list(src.schema.get("properties", {}).keys())
        print("properties (primeiras 20):", props[:20])
        print("geom:", src.schema.get("geometry"))

        it = iter(src)
        for i in range(2):
            try:
                feat = next(it)
                keys = list((feat.get("properties") or {}).keys())[:8]
                sample = {k: feat["properties"].get(k) for k in keys}
                print(f"sample {i+1} props:", sample)
            except StopIteration:
                break
