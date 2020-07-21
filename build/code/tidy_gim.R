rm(list = ls())

library(tidyverse)

gim <- readxl::read_excel("build/input/GIM/Governance.xlsx", skip = 23) %>%
  select(2, 4, 5, 6, 7) %>%
  set_names("tic", "fyear", "page", "gindex", "dualclass") %>%
  distinct()

write_rds(gim, "build/output/gim.rds")
