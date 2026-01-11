from pathlib import Path
import geopandas as gpd
from sqlalchemy import create_engine

def read_env(path=".env") -> dict:
    env = {}

    p = Path(path)

    if not p.exists():
        raise FileNotFoundError ("Arquivo .env não encontrado na raíz do projeto")
    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or  "=" not in line:
            continue

        k, v = line.split("=",1)
        env[k.strip()] = v.strip()

    for k in ("POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD"):
        if k not in env or not env[k]:
            raise ValueError(f"Faltando {k} no .env")

    return env

def main():
    env = read_env(".env")
    db = env["POSTGRES_DB"]
    user = env["POSTGRES_USER"]
    pwd = env["POSTGRES_PASSWORD"]

    engine = create_engine(f"postgresql+psycopg2://{user}:{pwd}@localhost:5432/{db}")

    gpd.options.io_engine = "fiona"
    gdf = gpd.read_file("data/processed/cnuc.gpkg")

    gdf.to_postgis(
        name="cnuc",
        con=engine,
        if_exists="replace",
        index=False,
        chunksize=5000,
    )

    print("OK: carregado public.cnuc no PostGIS")


if __name__ == "__main__":
    main()