import pandas as pd
import plotly.graph_objects as go
import os
# =====================
# OPTIONS
# =====================
output_prefix = "IndexFlow_HighGrade"
output_title = "Index Flow (High Grade)"
output_dir = "/Users/jdp2019/Library/CloudStorage/OneDrive-Emory/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/PKI EAST/CHM_JDP_PKI_2025/PKI-2025/Outputs"
output_svg_path = os.path.join(output_dir, f"{output_prefix}.svg")

# =====================
# Settings
# =====================
# Activate external venv (only on macbook)
# source ~/venv/tern-env/bin/activate
# Set working directory
# os.chdir("/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/PKI EAST/CHM_JDP_PKI_2025/PHI")
os.chdir("/Users/jdp2019/Library/CloudStorage/OneDrive-Emory/Research/Manuscripts and Projects/Grady/Penetrating Kidney Injuries/PKI EAST/CHM_JDP_PKI_2025/raw_data")
# Load and clean data
stroke = pd.read_excel("PKI_JDP.xlsx", sheet_name="Final")[["grade", "first", "second"]]
stroke = stroke.fillna("None")
#! Exclude grades 1 and 2
stroke = stroke[~stroke["grade"].astype(str).isin(["1", "2", "1-2"])]
#! Change OR_K to OR
stroke["first"] = stroke["first"].str.replace(r"^OR_K", "OR", regex=True)
stroke["second"] = stroke["second"].str.replace(r"^OR_K", "OR", regex=True)

# Create unique node labels by stage
def stage_label(label, stage):
    return f"{label} [{stage}]"

# Build all internal labels for Sankey (unique per stage)
label_set = set()
for _, row in stroke.iterrows():
    label_set.update([
        stage_label(row["grade"], "grade"),
        stage_label(row["first"], "first"),
        stage_label(row["second"], "second"),
    ])

labels = sorted(label_set)

# Hide grade labels, keep others clean
display_labels = [lbl.split(" [")[0] for lbl in labels]

# Mapping for internal label to Sankey index
def idx(label):
    return labels.index(label)

# Build link list for Sankey
def build_links(color_map):
    links = []
    for _, row in stroke.iterrows():
        grade = str(row["grade"])
        first = str(row["first"])
        second = str(row["second"])

        color = color_map.get(grade, "rgba(100,100,100,0.6)")

        g_lbl = stage_label(grade, "grade")
        f_lbl = stage_label(first, "first")
        s_lbl = stage_label(second, "second")

        if first != "None":
            links.append({"source": idx(g_lbl), "target": idx(f_lbl), "value": 1, "color": color})
        if first != "None" and second != "None":
            links.append({"source": idx(f_lbl), "target": idx(s_lbl), "value": 1, "color": color})

    return links

# Create and save Sankey diagram
def create_figure(links, name_suffix):
    x_map = {
        "grade": 0.0,
        "first": 0.5,
        "second": 0.99
    }
    x_positions = [x_map.get(label.split(" [")[-1].replace("]", ""), 0.0) for label in labels]

    fig = go.Figure(go.Sankey(
        arrangement="fixed",
        node=dict(
            pad=30,
            thickness=40,
            line=dict(color="black", width=1),
            # label=display_labels,
            label=[""] * len(display_labels),
            color="rgba(150,150,150,0.15)",
            x=x_positions
        ),
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

    fig.write_image(output_svg_path, width=2800, height=1800, scale=4)
    return fig

# Color maps
color_map_color = {
    "1-2": "rgba(254,217,118,0.6)",
    "3":   "rgba(253,190,133,0.6)",
    "4":   "rgba(230,85,13,0.6)",
    "5":   "rgba(153,0,13,0.6)"
}
# color_map_bw = {
#     "1-2": "rgba(220,220,220,0.7)",
#     "3":   "rgba(160,160,160,0.7)",
#     "4":   "rgba(100,100,100,0.7)",
#     "5":   "rgba(30,30,30,0.7)"
# }

# Generate diagrams
links_color = build_links(color_map_color)
fig_color = create_figure(links_color, "color")

# links_bw = build_links(color_map_bw)
# fig_bw = create_figure(links_bw, "bw")

fig_color.show()
# fig_bw.show()