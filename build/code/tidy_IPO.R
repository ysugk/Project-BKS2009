rm(list = ls())

library(tidyverse)

df <- readxl::read_excel("build/input/FR/age19752019.xlsx") %>%
  select(2, 4, 5) %>%
  set_names("FR_ipodate", "cusip8", "permno") %>%
  mutate(FR_ipodate = lubridate::ymd(FR_ipodate),
         permno = na_if(permno, ".") %>%
           as.numeric())

write_rds(df, "build/output/FR-IPO.rds", compress = "gz")
