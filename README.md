Segue um README pronto (bloco 1). Só copiar e colar.

---

# Projeto GIS Data Science: Amazônia (Bloco 1) - Concluído 11/01/2026

## Objetivo

Montar um pipeline geoespacial reprodutível para analisar desmatamento (PRODES) em relação a infraestrutura (rodovias) e áreas protegidas (CNUC), preparando os dados e carregando em um banco PostGIS para consultas espaciais performáticas.

---

## O que foi feito no Bloco 1

1. **Ingestão e validação dos dados brutos**

   * Fontes carregadas em `data/raw`:

     * PRODES (desmatamento)
     * CNUC (Unidades de Conservação)
     * IBGE Rodovias 2014
     * IBGE RG2017 (limites)
   * Criação de script de checagem leve para inspecionar CRS, bounds e colunas sem carregar tudo em memória.
   * Ajustes de encoding via `.cpg` para garantir acentuação correta.

2. **Tratamento e padronização espacial**

   * Padronização de CRS para **EPSG:5880** (métrico, recomendado para medidas de área/distância).
   * Exportação do “dataset de trabalho” para `data/processed` em **GeoPackage (.gpkg)**:

     * `cnuc.gpkg`
     * `rodovias.gpkg`
     * `rg2017.gpkg`
     * `prodes_2022.gpkg` (PRODES filtrado para 2022 para reduzir volume)

3. **Infra local de banco (Docker + PostGIS)**

   * Banco PostGIS local via Docker Compose com:

     * variáveis no `.env` (não versionado)
     * persistência em `.docker/postgres` (não versionado)
     * acesso por `localhost:5432`

4. **Carga no PostGIS e otimização**

   * Script genérico em Python para carregar os `.gpkg` no PostGIS:

     * `cnuc`, `rodovias`, `rg2017`, `prodes_2022`
   * Criação de índices espaciais **GiST** nas geometrias.
  
---

## Estrutura do projeto (relevante para o Bloco 1)

```
data/
  raw/            # dados brutos (ignorado no Git)
  processed/      # dados tratados .gpkg (ignorado no Git)

scripts/
  01_check_layers.py
  02_prepare_processed.py
  03_load_to_postgis.py

sql/
  04_create_spatial_indexes.sql

docker-compose.yml
.env              # ignorado no Git
.docker/          # ignorado no Git (persistência do Postgres)
```

---

## Requisitos

* Python (venv) com GeoPandas
* Docker Desktop (WSL2 habilitado)
* PostGIS via imagem Docker

---

## Como rodar (Bloco 1)

### 1) Subir PostGIS

Crie `.env` na raiz (exemplo) - Substituir conforme variáveis de sistema do usuário:

```
POSTGRES_DB=projeto_gis
POSTGRES_USER=user_name
POSTGRES_PASSWORD=password
```

Subir:

```powershell
docker compose up -d
```

Validar que PostGIS está ativo:

```powershell
docker exec -it projeto_gis_postgis psql -U vhbitu -d projeto_gis -c "SELECT postgis_version();"
```

---

### 2) Preparar dados processados (EPSG:5880)

```powershell
python scripts/02_prepare_processed.py
```

Saídas esperadas em `data/processed`:

* `cnuc.gpkg`
* `rodovias.gpkg`
* `rg2017.gpkg`
* `prodes_2022.gpkg`

---

### 3) Carregar camadas no PostGIS

```powershell
python scripts/03_load_to_postgis.py cnuc
python scripts/03_load_to_postgis.py rodovias
python scripts/03_load_to_postgis.py rg2017
python scripts/03_load_to_postgis.py prodes_2022
```

Validar contagens (exemplo):

```powershell
docker exec -it projeto_gis_postgis psql -U vhbitu -d projeto_gis -c "SELECT COUNT(*) FROM public.cnuc;"
```

---

### 4) Criar índices espaciais (GiST)

Rodar o SQL versionado:

```powershell
docker exec -i projeto_gis_postgis psql -U vhbitu -d projeto_gis < sql/04_create_spatial_indexes.sql
```

Checar índices:

```powershell
docker exec -it projeto_gis_postgis psql -U vhbitu -d projeto_gis -c "\di+ public.idx_*"
```

---

## Entregáveis do Bloco 1

* Dados validados e reprojetados para CRS métrico (EPSG:5880)
* Banco PostGIS local reprodutível via Docker Compose
* Tabelas carregadas no PostGIS:

  * `public.cnuc`
  * `public.rodovias`
  * `public.rg2017`
  * `public.prodes_2022`
* Índices GiST configurados para performance

---

## Próxima etapa (Bloco 2) - Iniciado 11/01/2026

Executar análises espaciais no PostGIS (interseção/proximidade), gerar tabelas derivadas e indicadores para visualização/relatório.

---
