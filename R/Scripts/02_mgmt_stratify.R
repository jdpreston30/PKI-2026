#* 2: Stratification by Management Strategy
#+ 2.1: Format data for table 2
#+ 2.2: Create table 2 stratified by index management strategy
T2 <- ternG(
  data = T1_data, # Can directly reuse T1 data
  output_docx = "Outputs/Tables/T2.docx",
  round_intg = FALSE,
  factor_order = "levels",
  consider_normality = TRUE,
  methods_doc = FALSE,
  group_order = c("Conservative Management", "Interventional Radiology", "Operative Management"),
  table_font_size = 9,
  table_caption = "Table 2. Demographic, clinical, and clinical course data in high-grade penetrating kidney injury patients stratified by index management strategy. All values are displayed as n (%), median [IQR], or mean ± SD as appropriate. Nonoperative management included interventional radiology and serial monitoring/conservative management. Calculations for Renal Salvage, AKI, ventilator days, ICU LOS, hospital LOS, and return to ED excluded patients who did not survive the index hospitalization. p-values < 0.05 are printed in bold. *Defined as no further procedures or death following the index management strategy; however, nephrectomy at index procedure was not counted as successful index management.",
  category_start = c(
    "Demographics"                    = "Age",
    "Injury Features and Vital Signs" = "AAST Grade",
    "Lab Values"                      = "Initial Lactate",
    "Blood Products (24 h)"           = "MTP",
    "Clinical Course"                 = "Survival"
  )
)