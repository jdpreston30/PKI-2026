# PKI-2026

Reproducible research compendium for the retrospective analysis of penetrating renal injuries from Meyer et al. (2026, manuscript in review, *American Journal of Surgery*). This repository contains the **complete analysis pipeline** producing all manuscript tables and figures.

---

## 📋 Repository Structure

```
PKI-2026/
├── All_Run/
│   ├── config_dynamic.yaml   # Computer-specific path configuration (auto-detects machine)
│   └── run.R                 # Master pipeline entry point — source this to run everything
├── R/
│   ├── Scripts/              # Numbered pipeline scripts (00a–07)
│   └── Utilities/            # Reusable functions
│       ├── Analysis/         # Outcome summarization helpers
│       ├── Helpers/          # Config loading, misc utilities
│       └── Visualization/    # Plot construction functions
├── Python Scripts/           # Python figure generation (alluvial diagram)
├── Outputs/
│   ├── Figures/
│   │   ├── Raw/              # Intermediate figure assets (e.g., Python-generated PNG)
│   │   └── Final/            # Compiled publication figures
│   └── Tables/               # Exported .docx tables
├── DESCRIPTION               # R package-style dependency declaration
├── requirements.txt          # Python dependency list (pip freeze)
└── renv.lock                 # Exact R package versions
```

---

## 🚀 Quick Start

### Requirements

- R ≥ 4.5.0
- Python ≥ 3.10 (for Figure 1 alluvial diagram)
- [renv](https://rstudio.github.io/renv/) for R package management
- TinyTeX (`tinytex::install_tinytex()`) for PDF rendering

### 1. Restore R packages

```r
renv::restore()  # First run only — may take 10–20 min
```

### 2. Set up Python virtual environment

```bash
# From the project root in Terminal
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Configure computer-specific paths

Open `All_Run/config_dynamic.yaml` and add or verify your machine's entry under `computers:`. The pipeline auto-detects your home directory to select the correct path set.

### 4. Run the full pipeline

```r
source("All_Run/run.R")
```

This sources all scripts in order, produces Tables 1–4 as a combined `.docx`, and exports Figure 1 as a PNG.

---

## 📊 Analysis Scripts

All scripts live in `R/Scripts/` and are sourced sequentially by `All_Run/run.R`:

| Script | Description | Output |
|--------|-------------|--------|
| `00a_environment_setup.R` | Verify R packages (renv), TinyTeX, and Python `.venv` | — |
| `00b_setup.R` | Load packages, set conflict preferences | — |
| `00c_import.R` | Import raw `.xlsx` data (main sheet + registry supplement) | `raw_data`, `extra_vars` |
| `00d_cleanup.R` | Derive variables, recode, rename to display labels | `raw_joined`, `raw_named` |
| `01_descriptive.R` | Overall cohort descriptive statistics | `T1` |
| `02_mgmt_stratify.R` | Cohort stratified by index management strategy | `T2` |
| `03_grade_stratify.R` | Cohort stratified by AAST grade (III–V) | `T3` |
| `04_success_by_grade.R` | Index management success and renal preservation by grade | `T4` |
| `05_compile_tables.R` | Combine T1–T4 into a single `.docx` via `TernTables::ternB()` | `Outputs/Tables/T1-T4.docx` |
| `06_figure.R` | Call Python alluvial script; build stacked bar and line chart panels | `p1A`, `p1B`, `p1C` |
| `07_render_figures.R` | Compose final Figure 1 and export PNG | `Outputs/Figures/Final/fig1.png` |

**Tables:** Combined export → `Outputs/Tables/T1-T4.docx` (with auto-generated methods supplement)
**Figures:** Intermediate assets → `Outputs/Figures/Raw/`; final publication figure → `Outputs/Figures/Final/fig1.png`

---

## 📦 Dependencies

### R — managed by renv

Key packages:
- **Tables:** [TernTables](https://github.com/jdpreston30/TernTables) (GitHub), `car`, `dplyr`, `tidyr`, `forcats`, `tibble`
- **Figures:** `ggplot2`, `cowplot`, `magick`, `ragg`, `png`, `pdftools`
- **I/O:** `readxl`, `stringr`

```r
renv::restore()  # Installs exact versions from renv.lock
```

> **Note:** TernTables is not on CRAN. It is installed from GitHub automatically via renv. Manual install: `remotes::install_github("jdpreston30/TernTables")`

### Python — managed by `.venv`

Used exclusively for Figure 1's alluvial (Sankey) diagram. Key packages: `plotly`, `kaleido`, `pandas`, `openpyxl`.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The R pipeline calls the Python script automatically via `system2()` — no manual Python step required after initial setup.

---

## 🔄 Reproducibility

- **`renv.lock`** pins exact R package versions (including GitHub commits)
- **`requirements.txt`** pins exact Python package versions (`pip freeze` output)
- **`config_dynamic.yaml`** centralizes all computer-specific paths with automatic machine detection — no hardcoded paths anywhere in the pipeline
- **`DESCRIPTION`** declares all R dependencies in package-style format for reference

**Development environment:** macOS 14.7, R 4.5.1, Python 3.10

---

## 📖 Citation

Meyer et al. *[Title]*. *American Journal of Surgery*. 2026 (In Review).

*Full citation will be updated upon acceptance.*

---

## 👥 Authors

- **Courtney Meyer** — First/Corresponding Author (Emory University School of Medicine, Department of Surgery) [[ORCID]](https://orcid.org/0000-0002-1594-4157)
- **Joshua D. Preston** — Data Science, Development, & Repository Maintainer (Emory University School of Medicine, Department of Surgery) ([@jdpreston30](https://github.com/jdpreston30)) [[ORCID]](https://orcid.org/0000-0001-9834-3017)
- **Jonathan Nguyen** — Senior Author (Morehouse School of Medicine, Department of Surgery) [[ORCID]](https://orcid.org/0000-0002-4880-8418)

---

## 📂 Data Availability

Raw data are **not included** in this repository. The deidentified dataset is available upon reasonable request for research purposes, subject to appropriate data use agreements and IRB approval.

**Contact:** See below.

---

## 📧 Contact

- **Courtney Meyer:** courtney.meyer@emory.edu
- **Joshua Preston:** joshua.preston@emory.edu
- **Jonathan Nguyen:** jnguyen@msm.edu
- **GitHub Repository:** [https://github.com/jdpreston30/PKI-2026](https://github.com/jdpreston30/PKI-2026)

**Report bugs:** [GitHub Issues](https://github.com/jdpreston30/PKI-2026/issues)
