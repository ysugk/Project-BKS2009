rm(list = ls())

library(tidyverse)
sdc <- read_csv("build/input/SDC/sdcipo.csv") %>%
  set_names("filingdate", "issuedate", "Issuer", "State", "Nation","IPO_Flag", "Original_IPO_Flag",
            "Offer_Price", "Type", "Description", "REIT", "Unit", "Depositary", "Deal_number", "CEF", 
            "CUSIP", "CUSIP9", "Proceeds", "VC", "Gross_spread", 
            "Mgr_codes","Tech_ind", "Low_Price", "High_Price", "Low_Price_History", "High_Price_History") %>%
  filter(IPO_Flag != "No") %>%
  mutate_at(vars(ends_with("date")), lubridate::mdy)

ex_types <- c("Units", "Ltd Prtnr Int", "MLP-Common Shs", "Shs Benficl Int",
              "Ltd Liab Int", "Stock Unit", "Trust Units", "Beneficial Ints")

tidy_sdc <- sdc %>%
  filter(!(Type %in% ex_types)) %>%
  filter(Depositary == "No") %>%
  filter(Unit == "No") %>%
  mutate(cusip8 = paste0(CUSIP, "10"))

write_rds(tidy_sdc, "build/output/sdcipo.rds", compress = "gz")

