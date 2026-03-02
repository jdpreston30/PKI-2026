{
source("R/Utilities/Helpers/load_dynamic_config.R")
config <- load_dynamic_config(computer = "auto", config_path = "All_Run/config_dynamic.yaml")
source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")
source("R/Scripts/00c_import.R")
source("R/Scripts/00d_cleanup.R")
source("R/Scripts/01_descriptive.R")
source("R/Scripts/02_mgmt_stratify.R")
source("R/Scripts/03_grade_stratify.R")
source("R/Scripts/04_success_by_grade.R")
}
