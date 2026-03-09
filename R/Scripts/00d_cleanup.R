#* 0d: Data Cleanup
#+ 0d.1: Joing with main dataset and clean
#- 0d.1.1: Main data cleaning
raw_joined <- raw |>
  # Only grade 3+
  filter(grade >= 3) |>
  # Exclude early deaths from index success classification
  mutate(index_success = case_when(
    death_24h == "Y" ~ NA_character_,
    if_any(c("second", "third"), ~ !is.na(.)) ~ "N",
    TRUE ~ "Y"
  )) |>
  # Join with additional variables
  left_join(extra_vars, by = "ID") |>
  # Set non-IR variables to NA for IR group and non-OR_K variables to NA for OR_K group to avoid confounding by management strategy in descriptive tables
  mutate(
    # IR_max1_derived: pipeline-derived from IR_angio1/IR_embo1 (N/N=pcn, Y/N=angio, Y/Y=embo)
    # validated against Excel-coded IR_max1: exact match across all 16 IR patients (0 mismatches)
    IR_max1_derived = case_when(
      index_group != "IR"                      ~ NA_character_,
      IR_angio1 == "N" & IR_embo1 == "N"      ~ "pcn", # This one specific patient got PCN and no angio or embo
      IR_angio1 == "Y" & IR_embo1 == "N"      ~ "angio",
      IR_angio1 == "Y" & IR_embo1 == "Y"      ~ "embo",
      TRUE                                     ~ NA_character_
    ),
    renorrhaphy1 = if_else(index_group != "OR_K", NA_character_, renorrhaphy1),
    renal_pack1 = if_else(index_group != "OR_K", NA_character_, renal_pack1),
    topical_hemo1 = if_else(index_group != "OR_K", NA_character_, topical_hemo1),
    any_nephrectomy1 = if_else(index_group != "OR_K", NA_character_, any_nephrectomy1),
    # Assumes OR patients with no recorded renal sub-procedure (nephrectomy, renorrhaphy,
    # topical hemostatic, or renal packing) underwent renal exploration without intervention
    exploration_only1 = if_else(
      index_group == "OR_K" &
        any_nephrectomy1 == "N" & renorrhaphy1 == "N" &
        topical_hemo1 == "N" & renal_pack1 == "N",
      "Y", if_else(index_group == "OR_K", "N", NA_character_)
    )
  ) |>
  # Recode index_group to display labels
  mutate(index_group = dplyr::recode(index_group,
    "IR"   = "Interventional Radiology",
    "SM"   = "Conservative Management",
    "OR_K" = "Operative Management"
  )) |>
  # Mutate variables to NAs when early_death == "Y" to avoid confounding by early mortality
  mutate(
    renal_pres = if_else(death_24h == "Y", NA_character_, renal_pres),
    AKI = if_else(death_24h == "Y", NA_character_, AKI),
    highest_Cr = if_else(death_24h == "Y", NA_real_, highest_Cr),
    return_ed_30d = if_else(death_24h == "Y", NA_character_, return_ed_30d),
    surv_ICU_LOS = if_else(death_24h == "Y", NA_integer_, surv_ICU_LOS),
    vent_LOS = if_else(death_24h == "Y", NA_integer_, vent_LOS),
    surv_hosp_LOS = if_else(death_24h == "Y", NA_integer_, surv_hosp_LOS)
  ) |>
  # Convert appropriate variables to factors
  mutate(across(
    c(MTP_24h, TXA, index_success, index_group, survived, IR_max1_derived, death_24h, renorrhaphy1, renal_pack1, topical_hemo1, any_nephrectomy1, exploration_only1, renal_pres, AKI, return_ed_30d, AKI), factor
  )) |>
  # Specify factor levels
  mutate(
    Gender_M = factor(Gender, levels = c(1, 2), labels = c("N", "Y")),
    grade = as.integer(grade),
    GCS = as.integer(GCS),
    ISS = as.integer(ISS),
    surv_ICU_LOS = as.integer(surv_ICU_LOS),
    vent_LOS = as.integer(vent_LOS),
    surv_hosp_LOS = as.integer(surv_hosp_LOS),
    Age = as.integer(Age)
  ) |>
  select(-Gender)
#- 0d.1.2: Concordance check
# IR_max1_derived (pipeline) vs IR_max1 (Excel); errors on any mismatch
stopifnot(
  raw_joined |>
    filter(index_group == "Interventional Radiology") |>
    mutate(match = as.character(IR_max1_derived) == tolower(IR_max1)) |>
    pull(match) |>
    all()
)
#+ 0d.2: Rename for table production
raw_named <- raw_joined |>
  rename(
    # Demographics
    `AAST Grade`           = grade,
    `Gender (Male)`        = Gender_M,
    # Injury features and vital signs
    MAP                    = MAP_calc,
    SBP                    = ED_SBP,
    DBP                    = ED_DBP,
    HR                     = ED_HR,
    # Lab values
    `Max Lactate (24 h)`   = max_lactate_24h,
    # Blood products (24 h)
    MTP                    = MTP_24h,
    RBC                    = RBC_24h,
    FFP                    = FFP_24h,
    Platelets              = plt_24h,
    Cryoprecipitate        = cryo_24h,
    `Whole Blood`          = WB_24h,
    # Index management details
    `Index Management Success`  = index_success,
    `Index Management Strategy` = index_group,
    `Interventional Radiology Procedure`   = IR_max1_derived,
    Nephrectomy               = any_nephrectomy1,
    Renorrhaphy               = renorrhaphy1,
    `Topical Hemostatic`      = topical_hemo1,
    `Renal Packing`           = renal_pack1,
    `Exploration Only`        = exploration_only1,
    # Clinical course
    Survival               = survived,
    `Renal Salvage`        = renal_pres,
    `Ventilator Days`      = vent_LOS,
    `ICU LOS (d)`              = surv_ICU_LOS,
    `Hospital LOS (d)`         = surv_hosp_LOS,
    `Return to ED (30 d)`  = return_ed_30d
  )
