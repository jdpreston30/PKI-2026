#* 0a: Environment Setup
#+ 0a.1: Verify renv is active
cat("Package environment managed by renv\n")
if (!("renv" %in% loadedNamespaces())) {
  warning("renv is not active. Attempting to activate...")
  source("renv/activate.R")
}
#+ 0a.2: Ensure jdPackages is excluded from renv (it is a global tool, not a project dependency)
tryCatch({
  current_ignored <- renv::settings$ignored.packages()
  if (!"jdPackages" %in% current_ignored) {
    renv::settings$ignored.packages(c(current_ignored, "jdPackages"))
  }
}, error = function(e) NULL)
#+ 0a.3: Read package lists from DESCRIPTION
desc <- read.dcf(here::here("DESCRIPTION"))
#- 0a.3.1: CRAN / Bioconductor packages (Imports field)
raw_imports  <- trimws(strsplit(desc[, "Imports"], ",\\s*|\n\\s*")[[1]])
cran_pkgs    <- raw_imports[nzchar(raw_imports)]
#- 0a.3.2: R-universe packages — installed via install.packages() with r-universe repo
runiverse_pkgs <- c("TernTables")
# Package names only (strip version pins like " (>= 1.0)")
pkg_names <- gsub("\\s*\\(.*\\)", "", cran_pkgs)
#+ 0a.4: Check and install missing packages
#- 0a.4.1: CRAN/Bioconductor packages via renv::restore()
non_runiverse_names <- setdiff(pkg_names, runiverse_pkgs)
missing_cran        <- non_runiverse_names[!sapply(non_runiverse_names, requireNamespace, quietly = TRUE)]
if (length(missing_cran) > 0) {
  cat("Core packages missing:", paste(missing_cran, collapse = ", "), "\n")
  cat("Running renv::restore() to install packages (may take 10-20 min on first run)...\n\n")
  tryCatch({
    renv::restore(prompt = FALSE)
    cat("\nPackage installation complete!\n")
  }, error = function(e) {
    stop("Failed to restore packages: ", e$message,
         "\nPlease run renv::restore() manually and check for errors.")
  })
  still_missing <- non_runiverse_names[!sapply(non_runiverse_names, requireNamespace, quietly = TRUE)]
  if (length(still_missing) > 0) {
    stop("Packages still missing after restore: ", paste(still_missing, collapse = ", "),
         "\nPlease check renv::status() for details.")
  }
} else {
  cat("renv environment verified. All CRAN/Bioconductor packages available.\n")
}
#- 0a.4.2: R-universe packages (e.g. TernTables) via install.packages() with r-universe repo
missing_runiverse <- runiverse_pkgs[!sapply(runiverse_pkgs, requireNamespace, quietly = TRUE)]
if (length(missing_runiverse) > 0) {
  cat("R-universe packages missing:", paste(missing_runiverse, collapse = ", "), "\n")
  install.packages(
    missing_runiverse,
    repos = c("https://jdpreston30.r-universe.dev", "https://cloud.r-project.org")
  )
  still_missing_ru <- missing_runiverse[!sapply(missing_runiverse, requireNamespace, quietly = TRUE)]
  if (length(still_missing_ru) > 0) {
    warning("R-universe packages still missing: ", paste(still_missing_ru, collapse = ", "))
  }
} else {
  cat("R-universe packages verified.\n")
}
#+ 0a.5: Load all packages from DESCRIPTION
cat("Loading packages...\n")
invisible(lapply(pkg_names, function(pkg) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat("  v", pkg, "\n")
  }, error = function(e) {
    warning("Could not load package: ", pkg, " — ", e$message)
  })
}))
cat("All packages loaded.\n")
#+ 0a.6: Check TinyTeX for PDF/supplementary rendering
if (!requireNamespace("tinytex", quietly = TRUE)) {
  cat("tinytex package not found — skipping TinyTeX check.\n")
} else if (!tinytex::is_tinytex()) {
  cat("TinyTeX not found. Installing (needed for PDF rendering)...\n")
  tinytex::install_tinytex()
  cat("TinyTeX installed.\n")
} else {
  cat("TinyTeX OK.\n")
}
#+ 0a.7: Verify Python virtual environment for figure generation scripts
py_bin <- normalizePath(file.path(getwd(), ".venv/bin/python"), mustWork = FALSE)
if (!file.exists(py_bin)) {
  stop(
    "Python virtual environment not found (.venv/).\n",
    "Run the following from the project root in Terminal:\n\n",
    "  python3 -m venv .venv\n",
    "  source .venv/bin/activate\n",
    "  pip install -r requirements.txt\n"
  )
}
pip_bin <- normalizePath(file.path(getwd(), ".venv/bin/pip"), mustWork = FALSE)
py_pkgs <- c("kaleido", "pandas", "plotly", "openpyxl")
py_missing <- py_pkgs[sapply(py_pkgs, function(pkg) {
  system2(pip_bin, args = c("show", pkg),
          stdout = FALSE, stderr = FALSE) != 0
})]
if (length(py_missing) > 0) {
  stop(
    "Python packages missing from .venv: ", paste(py_missing, collapse = ", "), "\n",
    "Run the following from the project root in Terminal:\n\n",
    "  source .venv/bin/activate\n",
    "  pip install -r requirements.txt\n"
  )
} else {
  cat("Python virtual environment verified. All packages available.\n")
}
