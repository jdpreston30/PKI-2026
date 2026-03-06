#* 2: Stratification by Management Strategy
#+ 2.1: Can use exact same data for Table 2 and Table 1 data
T2_data <- T1_data |>
  select(`Index Management Strategy`, everything())
#+ 2.2: Create table 2 stratified by index management strategy
T2 <- ternG(
  data = T2_data,
  group_var = "Index Management Strategy",
  round_intg = FALSE,
  force_ordinal = c("AAST Grade"),
  consider_normality = "ROBUST",
  methods_doc = FALSE,
  show_total = FALSE,
  group_order = c("Conservative Management", "Interventional Radiology", "Operative Management"),
  table_font_size = 9,
  table_caption = "Table 2. Demographic, clinical, and clinical course data in high-grade penetrating kidney injury patients stratified by index management strategy. All values are displayed as n (%), median [IQR], or mean ± SD as appropriate. Nonoperative management included interventional radiology and serial monitoring/conservative management. Calculations for Renal Salvage, AKI, ventilator days, ICU LOS, hospital LOS, and return to ED excluded patients who did not survive the index hospitalization. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = c("Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; HR, heart rate; ISS, Injury Severity Score; MTP, massive transfusion protocol; RBC, red blood cells; FFP, fresh frozen plasma; TXA, tranexamic acid; AKI, acute kidney injury; Cr, creatinine; ICU, intensive care unit; LOS, length of stay; ED, emergency department."),
  variable_footnote = c(
    "Index Management Success" = "Defined as no further kidney-directed procedures or death following the index management strategy; however, nephrectomy at index procedure was not counted as successful index management."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Clinical Course"                 = "Survival",
    "Index Management Details"        = "Nephrectomy"
  )
)
