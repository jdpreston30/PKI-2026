#* 3: Stratification by AAST Grade
#+ 3.1: Clean up and structure data for Table 3
T3_data <- raw_named |>
  select(
    # Grouping variable
    `AAST Grade`,
    # Demographics
    Age, `Gender (Male)`, BMI,
    # Injury features and vital signs
    GCS, MAP, SBP, DBP, HR, ISS,
    # Lab values
    initial_lactate, `Max Lactate (24 h)`, initial_base_deficit,
    # Blood products (24 h)
    MTP, RBC, FFP, Platelets, Cryoprecipitate, `Whole Blood`, TXA,
    # Clinical course
    Survival, `Renal Salvage`, `Index Management Success`, `Index Management Strategy`,
    AKI, highest_Cr, `Ventilator Days`, `ICU LOS`, `Hospital LOS`, `Return to ED (30 d)`
  ) |>
  mutate(`AAST Grade` = dplyr::recode(as.character(`AAST Grade`),
    "3" = "Grade III",
    "4" = "Grade IV",
    "5" = "Grade V"
  ))
#+ 3.2: Create Table 3 stratified by AAST grade
T3 <- ternG(
  data = T3_data,
  group_var = "AAST Grade",
  group_order = c("Grade III", "Grade IV", "Grade V"),
  round_intg = FALSE,
  force_ordinal = c("AAST Grade"),
  open_doc = TRUE,
  consider_normality = "ROBUST",
  methods_doc = FALSE,
  show_total = FALSE,
  table_font_size = 9,
  table_caption = "Table 3. Demographic, clinical, and outcomes data in high-grade penetrating kidney injury patients stratified by AAST injury grade. All values are displayed as n (%), median [IQR], or mean ± SD as appropriate. Calculations for Renal Salvage, AKI, ventilator days, ICU LOS, hospital LOS, and return to ED excluded patients who did not survive the index hospitalization. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = c("Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; HR, heart rate; ISS, Injury Severity Score; MTP, massive transfusion protocol; RBC, red blood cells; FFP, fresh frozen plasma; TXA, tranexamic acid; AKI, acute kidney injury; Cr, creatinine; ICU, intensive care unit; LOS, length of stay; ED, emergency department."),
    variable_footnotes = c(
    "Index Management Success" = "Defined as no further kidney-directed procedures or death following the index management strategy; however, nephrectomy at index procedure was not counted as successful index management.",
    "Operative Management" = "Refers to index management strategy."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "GCS",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Index Management Details"       = "Index Management Success",
    "Clinical Course"                 = "Survival"
  )
)
