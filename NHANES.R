# Clear the workspace
rm(list = ls())

# Set the working directory
setwd("C:\\Users\\RuiandFan\\nhanes2020") # Set working directory

# Load necessary libraries
library(haven)
library(dplyr) 


# ============================
# Read and Process Demographic Data
# ============================

# Read the P_DEMO.XPT data file
demo1 <- read_xpt("P_DEMO.XPT")

# View the column names of demo1 (optional)
# names(demo1)
# dput(names(demo1))

# Select required columns: SEQN (Participant ID), RIAGENDR (Gender), RIDAGEYR (Age), RIDRETH1 (Race/Ethnicity), DMDEDUC2 (Education Level)
demo1 <- demo1 %>% 
  select(SEQN, RIAGENDR, RIDAGEYR, RIDRETH1, DMDEDUC2)

# ============================
# Read and Process Medication Use Data
# ============================

# Read the P_RXQ_RX.XPT data file
med1 <- read_xpt("P_RXQ_RX.XPT")

# Select required columns: SEQN, RXDUSE (Medication Use), RXDRSC1 (Medication Specific Code)
# Note: Assuming that the 15 records without medication codes have already been removed
med1 <- med1 %>% 
  select(SEQN, RXDUSE, RXDRSC1)

# Filter and process the medication data
med1_filtered <- med1 %>%
  filter(RXDUSE %in% c(1, 2)) %>% # Retain records where RXDUSE is 1 (Uses medication) or 2 (Recently not using medication)
  mutate(Epilepsy = case_when(
    RXDUSE == 2 ~ 0, # Control group
    RXDUSE == 1 & RXDRSC1 == "G40" ~ 1 # Disease group (Epilepsy)
  )) %>%
  filter(!is.na(Epilepsy)) %>% # Remove records where Epilepsy is NA
  select(SEQN, Epilepsy) # Keep only SEQN and Epilepsy columns

# View the first few rows of the processed med1_filtered data
head(med1_filtered)
cat("Number of records in med1_filtered:", nrow(med1_filtered), "\n")

# ============================
# Merge Demographic Data with Medication Use Data
# ============================

# Perform an inner join to merge demo1 and med1_filtered based on SEQN
# inner_join: Retains only those participants present in both demo1 and med1_filtered
merged_data <- demo1 %>%
  inner_join(med1_filtered, by = "SEQN")

# View the first few rows of the merged data
head(merged_data)
cat("Number of records in merged_data after merging demo1 and med1_filtered:", nrow(merged_data), "\n")

# ============================
# Read and Process Laboratory Data
# ============================

# ---- Read and Process IRON Data ----

# Read the P_FETIB.XPT data file for Iron levels
iron <- read_xpt("P_FETIB.XPT")
iron <- iron %>% 
  select(SEQN, LBXIRN) # Select SEQN and Iron level (LBXIRN)

# Check for duplicate SEQN entries in iron data
iron_duplicates <- iron %>% 
  group_by(SEQN) %>% 
  filter(n() > 1) %>% 
  ungroup()

if(nrow(iron_duplicates) > 0){
  cat("Duplicates found in IRON data. Processing duplicates...\n")
  # Retain only the first occurrence of each SEQN
  iron <- iron %>%
    distinct(SEQN, .keep_all = TRUE)
}

# View the first few rows of the processed iron data
head(iron)
cat("Number of records in iron:", nrow(iron), "\n")

# ---- Read and Process CBC Data ----

# Read the P_CBC.XPT data file for Complete Blood Count (CBC)
CBC <- read_xpt("P_CBC.XPT")

# Check for duplicate SEQN entries in CBC data
CBC_duplicates <- CBC %>% 
  group_by(SEQN) %>% 
  filter(n() > 1) %>% 
  ungroup()

if(nrow(CBC_duplicates) > 0){
  cat("Duplicates found in CBC data. Processing duplicates...\n")
  # Retain only the first occurrence of each SEQN
  CBC <- CBC %>%
    distinct(SEQN, .keep_all = TRUE)
}

# View the first few rows of the processed CBC data
head(CBC)
cat("Number of records in CBC:", nrow(CBC), "\n")

# ---- Read and Process HDL Data ----

# Read the P_HDL.XPT data file for HDL Cholesterol levels
HDL <- read_xpt("P_HDL.XPT") %>% 
  select(SEQN, LBDHDD) # Select SEQN and HDL level (LBDHDD)

# Check for duplicate SEQN entries in HDL data
HDL_duplicates <- HDL %>% 
  group_by(SEQN) %>% 
  filter(n() > 1) %>% 
  ungroup()

if(nrow(HDL_duplicates) > 0){
  cat("Duplicates found in HDL data. Processing duplicates...\n")
  # Retain only the first occurrence of each SEQN
  HDL <- HDL %>%
    distinct(SEQN, .keep_all = TRUE)
}

# View the first few rows of the processed HDL data
head(HDL)
cat("Number of records in HDL:", nrow(HDL), "\n")

# ============================
# Merge All Data Sets
# ============================

# ---- Merge with IRON Data ----
merged_data <- merged_data %>%
  inner_join(iron, by = "SEQN")
cat("Number of records after merging with IRON data:", nrow(merged_data), "\n")

# ---- Merge with CBC Data ----
merged_data <- merged_data %>%
  inner_join(CBC, by = "SEQN")
cat("Number of records after merging with CBC data:", nrow(merged_data), "\n")

# ---- Merge with HDL Data ----
merged_data <- merged_data %>%
  inner_join(HDL, by = "SEQN")
cat("Number of records after merging with HDL data:", nrow(merged_data), "\n")

# View the final merged data
head(merged_data)
str(merged_data) # Confirm the structure and number of records (e.g., 4916)

# Save the final merged data to a CSV file (optional)
write.csv(merged_data, "merged_data_final.csv", row.names = FALSE)
cat("Final merged data has been saved as 'merged_data_final.csv'\n")
