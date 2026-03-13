import pandas as pd
import plotly.graph_objects as go
import os

# =====================
# PATHS
# =====================
output_dir = "Outputs/Figures/Raw"
os.makedirs(output_dir, exist_ok=True)

# =====================
# LOAD DATA
# =====================
stroke = pd.read_excel(
    "/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/AJS_PKI_Manuscript/raw_data/PKI_JDP_6_28_25.xlsx",
    sheet_name="Final"
)[["grade", "first", "second"]].fillna("None")

stroke = stroke[~stroke["grade"].astype(str).isin(["1", "2", "1-2"])]
stroke["first"]  = stroke["first"].str.replace(r"^OR_K", "OR", regex=True)
stroke["second"] = stroke["second"].str.replace(r"^OR_K", "OR", regex=True)

# =====================
# BUILD NODES
# =====================
def stage_label(label, stage):
    return f"{label} [{stage}]"

label_set = set()
for _, row in stroke.iterrows():
    label_set.update([
        stage_label(row["grade"], "grade"),
        stage_label(row["first"], "first"),
        stage_label(row["second"], "second"),
    ])

labels = sorted(label_set)
display_labels = [lbl.split(" [")[0] for lbl in labels]

def idx(label):
    return labels.index(label)

# =====================
# BUILD LINKS
# =====================
color_map = {
    "3": "rgba(253,190,133,0.6)",
    "4": "rgba(230,85,13,0.6)",
    "5": "rgba(153,0,13,0.6)",
}

links = []
for _, row in stroke.iterrows():
    grade, first, second = str(row["grade"]), str(row["first"]), str(row["second"])
    color = color_map.get(grade, "rgba(100,100,100,0.6)")
    g_lbl = stage_label(grade, "grade")
    f_lbl = stage_label(first, "first")
    s_lbl = stage_label(second, "second")
    if first != "None":
        links.append({"source": idx(g_lbl), "target": idx(f_lbl), "value": 1, "color": color})
    if first != "None" and second != "None":
        links.append({"source": idx(f_lbl), "target": idx(s_lbl), "value": 1, "color": color})

link_args = dict(
    source=[l["source"] for l in links],
    target=[l["target"] for l in links],
    value=[l["value"]  for l in links],
    color=[l["color"]  for l in links],
)

# =====================
# GENERATE: labels ON and labels OFF
# =====================
for show_labels in (True, False):
    suffix = "labeled" if show_labels else "unlabeled"
    fig = go.Figure(go.Sankey(
        arrangement="snap",
        node=dict(
            pad=30,
            thickness=102,
            line=dict(color="black", width=0),
            label=display_labels if show_labels else [""] * len(labels),
            color="rgba(150,150,150,0.15)",
        ),
        link=link_args,
    ))

    fig.update_layout(
        font=dict(size=22, color="black", family="Arial"),
        margin=dict(l=40, r=40, t=40, b=40),
        paper_bgcolor="white",
    )

    out_path = os.path.join(output_dir, f"alluvial_snap_{suffix}.html")
    fig.write_html(out_path)
    print(f"Written: {out_path}")
    if not show_labels:
        png_path = os.path.join(output_dir, "alluvial_snap_unlabeled.png")
        fig.write_image(png_path, width=1400, height=700, scale=4)
        print(f"Written: {png_path}")
