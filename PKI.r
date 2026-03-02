#* Preprocess
  #+ Add additional variables of interest
    extra_vars <- read_excel(raw_path, sheet = "registry_add")
  #+ Import raw data, add extra variables
    raw_HG <- read_excel(raw_path, sheet = "Final") %>%
      filter(grade >= 3) %>%
        mutate(index_success = case_when(
          death_24h == "Y" ~ NA_character_,
          if_any(c("second", "third"), ~ !is.na(.)) ~ "N",
          TRUE ~ "Y"
        )) %>%
      left_join(extra_vars, by = "MRN")
  #+ Clean up for demographics
    demographics_i <- raw_HG %>%
      select(
        MRN,
        # --- Demographics ---
        Age, Gender, BMI,
        # --- Clinical Features ---
        grade, GCS, MAP_calc, ED_SBP, ED_DBP,ED_HR, ISS, MTP_24h,RBC_24h:initial_base_deficit,
        # --- Index Management Details ---
        index_success, index_group, IR_max1, any_nephrectomy1, renorrhaphy1, topical_hemo1, renal_pack1,
        # --- Clinical Course ---
        death_24h,survived,renal_pres, AKI, vent_LOS, surv_ICU_LOS, surv_hosp_LOS, return_ed_30d) %>%
      mutate(
        IR_max1 = if_else(index_group != "IR", NA_character_, IR_max1),
        renorrhaphy1 = if_else(index_group != "OR_K", NA_character_, renorrhaphy1),
        renal_pack1 = if_else(index_group != "OR_K", NA_character_, renal_pack1),
        topical_hemo1 = if_else(index_group != "OR_K", NA_character_, topical_hemo1),
        any_nephrectomy1 = if_else(index_group != "OR_K", NA_character_, any_nephrectomy1)) %>%
      mutate(
        renal_pres = if_else(death_24h == "Y", NA_character_, renal_pres),
        AKI = if_else(death_24h == "Y", NA_character_, AKI),
        highest_Cr = if_else(death_24h == "Y", NA_real_, highest_Cr),
        return_ed_30d = if_else(death_24h == "Y", NA_character_, return_ed_30d),
        surv_ICU_LOS = if_else(death_24h == "Y", NA_integer_, surv_ICU_LOS),
        vent_LOS = if_else(death_24h == "Y", NA_integer_, vent_LOS),
        surv_hosp_LOS = if_else(death_24h == "Y", NA_integer_, surv_hosp_LOS)) %>%
      mutate(across(
        c(MTP_24h, TXA, index_success,index_group, survived, IR_max1, death_24h, renorrhaphy1, renal_pack1, topical_hemo1, any_nephrectomy1, renal_pres, AKI, return_ed_30d,AKI),factor)) %>%
      mutate(
        Gender = factor(Gender, levels = c(1, 2), labels = c("F", "M")),
        grade = as.integer(grade),
        GCS = as.integer(GCS),
        ISS = as.integer(ISS),
        surv_ICU_LOS = as.integer(surv_ICU_LOS),
        vent_LOS = as.integer(vent_LOS),
        surv_hosp_LOS = as.integer(surv_hosp_LOS),
        Age = as.integer(Age))
#* Table 1-3 (Descriptive, clinical data by operative versus nonoperative, and grade stratified)
  #+ Create descriptive statistics table
    descriptive <- ternD(
      data = demographics_i,
      exclude_vars = c("MRN"),
      # force_ordinal = "grade",
      output_xlsx = NULL,
      output_docx = "descriptive_table.docx"
    )
  #+ Create table for demographics by strategy
    demographics_strategy <- ternG(
      data = demographics_i,
      exclude_vars = c("MRN"),
      group_var = "index_group",
      force_ordinal = c("grade"),
      group_order = c("SM", "IR", "OR_K"),
      output_xlsx = "demographics_strategy.xlsx",
      output_docx = "demographics_strategy.docx"
    )
  #+ Create table for demographics by grade
    demographics_graded <- ternG(
      data = demographics_i,
      exclude_vars = c("MRN"),
      group_var = "grade",
      group_order = c(3,4,5),
      output_xlsx = "demographics_graded.xlsx",
      output_docx = "demographics_graded.docx"
    )
#* Figure 1- renal pres by index grouping
  renal_pres_table <- demographics_i %>%
    select(renal_pres, index_group, grade) %>%
    filter(!is.na(renal_pres)) %>%
    arrange(renal_pres) %>%
    mutate(
      renal_pres = factor(renal_pres, levels = c("N", "Y")),
      grade = factor(grade)
    ) %>%
    group_by(index_group, grade) %>%
    summarise(
      Y = sum(renal_pres == "Y"),
      N = sum(renal_pres == "N"),
      `% Preserved` = round(100 * Y / (n()), 1),
      .groups = "drop"
    )
  write.csv(renal_pres_table, "renal_pres_table.csv", row.names = FALSE)
  #! Worked this figure in Prism from here
#* Tables 4
  #+ Helper function to generate n/N (%) summary
    summarize_index_success <- function(data, outcome_col, stratify_col = grade) {
      outcome_col <- rlang::ensym(outcome_col)
      stratify_col <- rlang::ensym(stratify_col)

      # Internal helper for n/N (%) summary
      get_success_summary <- function(df) {
        df %>%
          group_by(index_group) %>%
          summarise(
            N_Y = sum(!!outcome_col == "Y"),
            N_N = sum(!!outcome_col == "N"),
            Total = N_Y + N_N,
            Percent_Y = round(100 * N_Y / Total, 1),
            Summary = paste0(N_Y, "/", Total, " (", Percent_Y, "%)"),
            .groups = "drop"
          ) %>%
          select(index_group, Summary)
      }

      # Get stratified summaries
      tbl_all <- get_success_summary(data) %>% rename(`All Grades` = Summary)
      tbl_g3 <- get_success_summary(data %>% filter(!!stratify_col == 3)) %>% rename(`Grade 3` = Summary)
      tbl_g4 <- get_success_summary(data %>% filter(!!stratify_col == 4)) %>% rename(`Grade 4` = Summary)
      tbl_g5 <- get_success_summary(data %>% filter(!!stratify_col == 5)) %>% rename(`Grade 5` = Summary)

      # Join tables
      summary_tbl <- tbl_all %>%
        full_join(tbl_g3, by = "index_group") %>%
        full_join(tbl_g4, by = "index_group") %>%
        full_join(tbl_g5, by = "index_group") %>%
        arrange(index_group)

      # Compute overall (ALL) row
      total_all <- data %>%
        summarise(
          N_Y = sum(!!outcome_col == "Y"),
          N_N = sum(!!outcome_col == "N"),
          Total = N_Y + N_N,
          `All Grades` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
        )

      total_g3 <- data %>%
        filter(!!stratify_col == 3) %>%
        summarise(
          N_Y = sum(!!outcome_col == "Y"),
          N_N = sum(!!outcome_col == "N"),
          Total = N_Y + N_N,
          `Grade 3` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
        ) %>%
        select(`Grade 3`)

      total_g4 <- data %>%
        filter(!!stratify_col == 4) %>%
        summarise(
          N_Y = sum(!!outcome_col == "Y"),
          N_N = sum(!!outcome_col == "N"),
          Total = N_Y + N_N,
          `Grade 4` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
        ) %>%
        select(`Grade 4`)

      total_g5 <- data %>%
        filter(!!stratify_col == 5) %>%
        summarise(
          N_Y = sum(!!outcome_col == "Y"),
          N_N = sum(!!outcome_col == "N"),
          Total = N_Y + N_N,
          `Grade 5` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
        ) %>%
        select(`Grade 5`)

      # Bind overall row
      total_row <- bind_cols(
        tibble(index_group = "ALL"),
        total_all %>% select(`All Grades`),
        total_g3,
        total_g4,
        total_g5
      )

      bind_rows(summary_tbl, total_row)
    }
  #+ Prep data
    succ_salvage_final <- demographics_i %>%
      select(grade, index_success, index_group, renal_pres) %>%
      filter(!is.na(index_success))
  #+ Index success table
    index_success_table <- summarize_index_success(succ_salvage_final, index_success) %>%
      mutate(variable = "Index Success")
  #+ Renal salvage table
    renal_salvage_table <- summarize_index_success(succ_salvage_final, renal_pres) %>%
      mutate(variable = "Renal Salvage")
    salvage_succ_table <- rbind(index_success_table, renal_salvage_table)
    write.csv(salvage_succ_table, "salvage_succ_table.csv", row.names = FALSE)
