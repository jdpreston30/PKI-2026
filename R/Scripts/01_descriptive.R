#* 1: Descriptive Statistics
#+ 1.1: Create descriptive statistics table
T1 <- ternD(
  data = table_data,
  round_intg = TRUE,
  factor_order = "levels",
  consider_normality = TRUE,
  table_font_size = 9,
  methods_doc = FALSE,
  table_caption = "Table 1. Descriptive statistics of the cohort.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Clinical Course"                 = "Survival"
  )
)