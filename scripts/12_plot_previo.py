from pathlib import Path
import textwrap

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

BASE = Path("outputs")
TOP10 = BASE / "top10_uc_desmatamento_2022.csv"
KPI = BASE / "kpi_amazonia_2022.csv"


def fmt_ha(x, _pos=None):
    # 1234567 -> 1.234.567 (pt-BR)
    return f"{int(round(x)):,}".replace(",", ".")


def wrap(s: str, width: int = 34) -> str:
    return "\n".join(textwrap.wrap(str(s), width=width))


def main():
    BASE.mkdir(exist_ok=True)

    kpi = pd.read_csv(KPI, encoding="utf-8").iloc[0]

    total = float(kpi["total_ha"])
    dentro = float(kpi["dentro_uc_ha"])
    fora = float(kpi["fora_uc_ha"])
    ate5 = float(kpi["ate_5km_ha"])
    acima5 = float(kpi["acima_5km_ha"])

    # -------------------------
    # Gráfico 1: Donut UC (centralizado + ha + %)
    # -------------------------
    plt.figure(figsize=(9, 6))  # mais largo pra sobrar margem
    vals = [dentro, fora]
    labels = ["Dentro de UC", "Fora de UC"]
    colors = ["#2ca02c", "#bdbdbd"]

    def autopct_uc(pct):
        total_local = sum(vals)
        ha = (pct / 100.0) * total_local
        return f"{pct:.1f}%\n({fmt_ha(ha)} ha)"

    wedges, texts, autotexts = plt.pie(
        vals,
        labels=labels,
        autopct=autopct_uc,
        startangle=90,
        colors=colors,
        wedgeprops={"width": 0.45, "edgecolor": "white"},
        textprops={"fontsize": 12},
        pctdistance=0.72,
        labeldistance=1.12,
    )

    # garante que o donut fique "redondo" e centralizado
    plt.gca().set_aspect("equal")

    # título com um pouco de espaço
    plt.title("Desmatamento 2022 — Dentro vs Fora de UC (Amazônia Legal)", fontsize=16, pad=16)

    # margem extra (pra não ficar colado)
    plt.subplots_adjust(left=0.10, right=0.90, top=0.85, bottom=0.10)

    plt.savefig(BASE / "grafico_dentro_fora_uc_2022.png", dpi=200, bbox_inches="tight", pad_inches=0.4)
    plt.close()


    # -------------------------
    # Gráfico 2: Rodovias (barra + ha + %)
    # -------------------------
    plt.figure(figsize=(9, 3.8))
    labels = ["Até 5 km", "Acima de 5 km"]
    vals = [ate5, acima5]
    colors = ["#9467bd", "#bdbdbd"]  # roxo + cinza

    plt.barh(labels, vals, color=colors)
    plt.gca().xaxis.set_major_formatter(FuncFormatter(fmt_ha))
    plt.xlabel("Área desmatada (ha)")
    plt.title("Desmatamento 2022 — Proximidade de rodovias (Amazônia Legal)", fontsize=16)

    # anotações
    pct_ate = (ate5 / total) * 100 if total else 0
    pct_acima = (acima5 / total) * 100 if total else 0
    for y, (v, p) in enumerate([(ate5, pct_ate), (acima5, pct_acima)]):
        plt.text(v * 1.01, y, f"{fmt_ha(v)} ha  ({p:.1f}%)", va="center", fontsize=11)

    plt.tight_layout()
    plt.savefig(BASE / "grafico_rodovias_5km_2022.png", dpi=200)
    plt.close()

    # -------------------------
    # Gráfico 3: Top 10 UCs (melhor legibilidade)
    # -------------------------
    top10 = pd.read_csv(TOP10, encoding="utf-8")
    top10 = top10.sort_values("area_desmatada_ha", ascending=True)

    ylabels = [wrap(s, 38) for s in top10["nome_uc"]]

    plt.figure(figsize=(14, 7))
    plt.barh(ylabels, top10["area_desmatada_ha"], color="#1f77b4")
    plt.gca().xaxis.set_major_formatter(FuncFormatter(fmt_ha))
    plt.xlabel("Área desmatada (ha)")
    plt.title("Top 10 UCs com maior desmatamento (ha) — Amazônia Legal, 2022", fontsize=16)
    plt.yticks(fontsize=10)
    plt.tight_layout()
    plt.savefig(BASE / "grafico_top10_uc_2022.png", dpi=200)
    plt.close()

    print("OK: gráficos atualizados em outputs/")


if __name__ == "__main__":
    main()
