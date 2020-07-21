rm(list = ls())

library(tidyverse)

ccm_link <- read_rds("build/input/wrds/ccmxpf_lnkhist.rds")
comphead <- read_rds("build/input/wrds/comphead.rds")
crsphead <- read_rds("build/input/wrds/crsphead.rds") %>%
  select(permno, begdat, enddat)
idxcst_his <- read_rds("build/input/wrds/idxcst_his.rds")
funda <- read_rds("build/input/wrds/funda.rds") 
gdpdeflator <- read_rds("build/output/gdpdeflator.rds")
gim <- read_rds("build/output/gim.rds")
ipo <- read_rds("build/output/FR-IPO.rds")
tb <- read_rds("build/output/tbill.rds")
cs <- read_rds("build/output/creditspread.rds")

sp500_df <- funda %>%
  inner_join(idxcst_his, by = "gvkey") %>%
  filter(datadate >= from & (datadate <= thru | is.na(thru))) %>%
  mutate(sp500 = 1) %>%
  select(gvkey, fyear, sp500)

df <- funda %>%
  left_join(ccm_link, by = c("gvkey")) %>%
  filter(linktype %in% c("LC", "LU", "LS"),
         linkprim %in% c("P", "C")) %>%
  filter(datadate >= linkdt & (datadate <= linkenddt | is.na(linkenddt))) %>%
  left_join(select(comphead, -costat), by = "gvkey") %>%
  left_join(crsphead, by = c("lpermno" = "permno")) %>%
  left_join(sp500_df, by = c("gvkey", "fyear")) %>%
  replace_na(list(sp500 = 0)) %>%
  left_join(gdpdeflator, by = c("fyear")) %>%
  mutate(stic = str_remove_all(tic, "\\.[:alnum:]*")) %>%
  left_join(gim, by = c("stic" = "tic", "fyear")) %>%
  mutate(cusip8 = str_sub(cusip, 1, 8)) %>%
  left_join(ipo, by = "cusip8") %>%
  left_join(tb, by = c("fyear" = "year")) %>%
  left_join(cs, by = c("fyear" = "year"))

haven::write_dta(df, "build/output/data.dta")
