#* 0d: Data Cleanup
#+ 0d.1: Joing with main dataset and clean
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
  mutate(
    IR_max1 = if_else(index_group != "IR", NA_character_, IR_max1),
    renorrhaphy1 = if_else(index_group != "OR_K", NA_character_, renorrhaphy1),
    renal_pack1 = if_else(index_group != "OR_K", NA_character_, renal_pack1),
    topical_hemo1 = if_else(index_group != "OR_K", NA_character_, topical_hemo1),
    any_nephrectomy1 = if_else(index_group != "OR_K", NA_character_, any_nephrectomy1)
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
      c(MTP_24h, TXA, index_success, index_group, survived, IR_max1, death_24h, renorrhaphy1, renal_pack1, topical_hemo1, any_nephrectomy1, renal_pres, AKI, return_ed_30d, AKI), factor
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
    # Clinical course
    Survival               = survived,
    `Renal Salvage`        = renal_pres,
    `Index Management Success`  = index_success,
    `Index Management Strategy` = index_group,
    `Ventilator Days`      = vent_LOS,
    `ICU LOS`              = surv_ICU_LOS,
    `Hospital LOS`         = surv_hosp_LOS,
    `Return to ED (30 d)`  = return_ed_30d
  )
