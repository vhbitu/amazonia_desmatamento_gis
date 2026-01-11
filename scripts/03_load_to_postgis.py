from pathlib import Path
import sys

import geopandas as gpd
from sqlalchemy import create_engine


DATASETS = {
    "cnuc": ("data/processed/cnuc.gpkg", "cnuc"),
    "rodovias": ("data/processed/rodovias.gpkg", "rodovias"),
    "rg2017": ("data/processed/rg2017.gpkg", "rg2017"),
    "prodes_2022": ("data/processed/prodes_2022.gpkg", "prodes_2022"),
}


def read_env(path=".env") -> dict:
    env = {}
    p = Path(path)

    if not p.exists():
        raise FileNotFoundError("Arquivo .env não encontrado na raiz do projeto")

    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        env[k.strip()] = v.strip()

    for k in ("POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD"):
        if k not in env or not env[k]:
            raise ValueError(f"Faltando {k} no .env")

    return env


def main():
    if len(sys.argv) < 2:
        print("Uso: python scripts/03_load_to_postgis.py <dataset>")
        print("Datasets disponíveis:", ", ".join(DATASETS.keys()))
        sys.exit(1)

    dataset = sys.argv[1].strip()
    if dataset not in DATASETS:
        print(f"Dataset inválido: {dataset}")
        print("Datasets disponíveis:", ", ".join(DATASETS.keys()))
        sys.exit(1)

    gpkg_path, table_name = DATASETS[dataset]

    env = read_env(".env")
    db = env["POSTGRES_DB"]
    user = env["POSTGRES_USER"]
    pwd = env["POSTGRES_PASSWORD"]

    engine = create_engine(f"postgresql+psycopg2://{user}:{pwd}@localhost:5432/{db}")

    gpd.options.io_engine = "fiona"
    gdf = gpd.read_file(gpkg_path)

    gdf.to_postgis(
        name=table_name,
        con=engine,
        if_exists="replace",
        index=False,
        chunksize=5000,
    )

    print(f"OK: carregado public.{table_name} no PostGIS (rows={len(gdf)})")


if __name__ == "__main__":
    main()
