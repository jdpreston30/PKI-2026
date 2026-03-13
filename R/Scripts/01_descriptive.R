#* 1: Descriptive Statistics
#+ 1.1: Prepare data for descriptive table
T1_data <- raw_named |>
  select(
    # Demographics
    Age, `Gender (Male)`, BMI,
    # Injury features and vital signs
    `AAST Grade`, GCS, MAP, SBP, DBP, HR, ISS,
    # Lab values
    initial_lactate, `Maximum Lactate (24 h)`, initial_base_deficit,
    # Blood products (24 h)
    MTP, RBC, FFP, Platelets, Cryoprecipitate, `Whole Blood`, TXA,
    # Index Management Details
    `Index Management Success`, `Index Management Strategy`,
    # Clinical Course and Outcomes
    Survival, `Renal Salvage`, AKI, highest_Cr, `Ventilator Days`, `ICU LOS (d)`, `Hospital LOS (d)`, `Return to ED (30 d)`
  ) |>
  mutate(`AAST Grade` = fct_recode(factor(`AAST Grade`), "III" = "3", "IV" = "4", "V" = "5"))
#+ 1.2: Create descriptive statistics table
T1 <- ternD(
  data = T1_data,
  consider_normality = "ROBUST",
  round_intg = FALSE,
  table_font_size = 9,
  line_break_header = FALSE,
  methods_doc = FALSE,
  table_caption = "Table 1. Descriptive statistics of the cohort.",
  abbreviation_footnote = "Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; HR, heart rate; ISS, Injury Severity Score; MTP, massive transfusion protocol; RBC, red blood cells; FFP, fresh frozen plasma; TXA, tranexamic acid; AKI, acute kidney injury; Cr, creatinine; ICU, intensive care unit; LOS, length of stay; ED, emergency department.",
  variable_footnote = c(
    "Index Management Success" = "Defined as no further kidney-directed procedures or death following the index management strategy; however, nephrectomy at index procedure was not counted as successful index management."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Index Management Details"        = "Index Management Success",
    "Clinical Course and Outcomes"    = "Survival"
  )
)
