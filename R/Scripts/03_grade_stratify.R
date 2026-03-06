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
    # Index management details
    `Index Management Success`, `Index Management Strategy`,
    `Interventional Radiology Procedure`,
    Nephrectomy, Renorrhaphy, `Topical Hemostatic`, `Renal Packing`, `Exploration Only`,
    # Clinical course
    Survival, `Renal Salvage`, AKI, highest_Cr, `Ventilator Days`, `ICU LOS (d)`, `Hospital LOS (d)`, `Return to ED (30 d)`) |>
  mutate(`AAST Grade` = dplyr::recode(as.character(`AAST Grade`),
    "3" = "Grade III",
    "4" = "Grade IV",
    "5" = "Grade V"
  )) |>
  mutate(`Interventional Radiology Procedure` = dplyr::recode(as.character(`Interventional Radiology Procedure`),
    "angio" = "Diagnostic Angiogram",
    "embo"  = "Embolization",
    "pcn"   = "PCN"
  ))
#+ 3.2: Create Table 3 stratified by AAST grade
T3 <- ternG(
  data = T3_data,
  group_var = "AAST Grade",
  group_order = c("Grade III", "Grade IV", "Grade V"),
  round_intg = FALSE,
  force_ordinal = c("AAST Grade"),
  consider_normality = "ROBUST",
  methods_doc = FALSE,
  show_total = FALSE,
  line_break_header = FALSE,
  table_font_size = 9,
  post_hoc = TRUE,
  table_caption = "Table 3. Demographic, clinical, and outcomes data in high-grade penetrating kidney injury patients stratified by AAST injury grade. All values are displayed as n (%), median [IQR], or mean ± SD as appropriate. Calculations for Renal Salvage, AKI, ventilator days, ICU LOS, hospital LOS, and return to ED excluded patients who did not survive the index hospitalization. p-values < 0.05 are printed in bold.",
  abbreviation_footnote = c("Abbreviations: AAST, American Association for the Surgery of Trauma; GCS, Glasgow Coma Scale; MAP, mean arterial pressure; SBP, systolic blood pressure; DBP, diastolic blood pressure; HR, heart rate; ISS, Injury Severity Score; MTP, massive transfusion protocol; RBC, red blood cells; FFP, fresh frozen plasma; TXA, tranexamic acid; PCN, percutaneous nephrostomy; AKI, acute kidney injury; Cr, creatinine; ICU, intensive care unit; LOS, length of stay; ED, emergency department."),
  variable_footnote = c(
    "Index Management Success" = "Defined as no further kidney-directed procedures or death following the index management strategy; however, nephrectomy at index procedure was not counted as successful index management.",
    "Operative Intervention" = "Refers to index management strategy."
  ),
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Index Management Details"        = "Index Management Success",
    "Clinical Course and Outcomes"    = "Survival"
  ),
  plain_header = c("Operative Intervention" = "Nephrectomy"),
  manual_italic_indent = c("Nephrectomy", "Renorrhaphy", "Topical Hemostatic", "Renal Packing", "Exploration Only")
)