import pandas as pd
import plotly.graph_objects as go
import os
import sys

# =====================
# PATHS — passed from R via system2() as command-line arguments
#   argv[1]: absolute path to raw Excel file (config$paths$raw_data)
#   argv[2]: output directory for PNG (e.g. "Outputs/Figures/Raw")
# Falls back to hardcoded defaults when run interactively.
# =====================
raw_data_path = sys.argv[1] if len(sys.argv) > 1 else "/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/AJS_PKI_Manuscript/raw_data/PKI_JDP_6_28_25.xlsx"
output_dir    = sys.argv[2] if len(sys.argv) > 2 else "Outputs/Figures/Raw"
os.makedirs(output_dir, exist_ok=True)

# =====================
# OPTIONS
# =====================
output_prefix  = "p1A_raw"
use_fixed_order = False         # Fix vertical order of nodes
use_third_stage = False         # Use third stage column
show_labels     = True          # Toggle label display

# ============
# Desired order
# ============
custom_grade_order = ["5", "4", "3"]
custom_first_order = ["IR", "SM", "OR"]
custom_stage_order = {
    "grade": custom_grade_order,
    "first": custom_first_order,
    "second": []  # filled dynamically
}

# =====================
# Load and clean data
# =====================
cols = ["grade", "first", "second"] + (["third"] if use_third_stage else [])
stroke = pd.read_excel(raw_data_path, sheet_name="Final")[cols].fillna("None")

stroke = stroke[~stroke["grade"].astype(str).isin(["1", "2", "1-2"])]
for col in ["first", "second"] + (["third"] if use_third_stage else []):
    stroke[col] = stroke[col].str.replace(r"^OR_K", "OR", regex=True)

# =====================
# Build ordered label list
# =====================
def stage_label(label, stage):
    return f"{label} [{stage}]"

label_list = []
label_list += [stage_label(l, "grade") for l in custom_stage_order["grade"]]
label_list += [stage_label(l, "first") for l in custom_stage_order["first"]]

second_labels = stroke["second"].unique()
second_labels = [l for l in second_labels if l != "None"]
custom_stage_order["second"] = second_labels
label_list += [stage_label(l, "second") for l in second_labels]

labels = label_list
display_labels = [lbl.split(" [")[0] for lbl in labels]
def idx(label): return labels.index(label)

# =====================
# Link builder
# =====================
def build_links(color_map):
    links = []
    for _, row in stroke.iterrows():
        grade, first, second = map(str, (row["grade"], row["first"], row["second"]))
        third = str(row["third"]) if use_third_stage else None

        color = color_map.get(grade, "rgba(100,100,100,0.6)")
        g_lbl = stage_label(grade, "grade")
        f_lbl = stage_label(first, "first")
        s_lbl = stage_label(second, "second")
        t_lbl = stage_label(third, "third") if use_third_stage else None

        if first != "None":
            links.append({"source": idx(g_lbl), "target": idx(f_lbl), "value": 1, "color": color})
        if first != "None" and second != "None":
            links.append({"source": idx(f_lbl), "target": idx(s_lbl), "value": 1, "color": color})
        if use_third_stage and all(val != "None" for val in [first, second, third]):
            links.append({"source": idx(s_lbl), "target": idx(t_lbl), "value": 1, "color": color})
    return links

# =====================
# Sankey Figure Creator
# =====================
def create_figure(links, name_suffix):
    x_map = {"grade": 0.0, "first": 0.33, "second": 0.66, "third": 0.99}
    x_positions = [x_map.get(label.split(" [")[-1].replace("]", ""), 0.0) for label in labels]
    y_positions = [i / max(1, len(labels)-1) for i in range(len(labels))] if use_fixed_order else None

    node_kwargs = dict(
        pad=75,
        thickness=220,
        line=dict(color="black", width=1),
        label=display_labels if show_labels else [""] * len(labels),
        color="rgba(150,150,150,0.15)",
        x=x_positions
    )
    if y_positions:
        node_kwargs["y"] = y_positions

    fig = go.Figure(go.Sankey(
        arrangement="fixed",
        node=node_kwargs,
        link=dict(
            source=[l["source"] for l in links],
            target=[l["target"] for l in links],
            value=[l["value"] for l in links],
            color=[l["color"] for l in links]
        )
    ))
    fig.update_layout(
        font=dict(size=22, color="black", family="Arial"),
        margin=dict(l=40, r=40, t=40, b=40),
        title=""
    )
    out_path = os.path.join(output_dir, f"{output_prefix}.png")
    fig.write_image(out_path, width=5100, height=3493, scale=1)
    print(f"Alluvial diagram written to: {out_path}")
    return fig

# =====================
# Run Sankey Plot
# =====================
color_map_color = {
    "1-2": "rgba(254,217,118,0.6)",
    "3":   "rgba(253,190,133,0.6)",
    "4":   "rgba(230,85,13,0.6)",
    "5":   "rgba(153,0,13,0.6)"
}

links_color = build_links(color_map_color)
fig_color = create_figure(links_color, "color")