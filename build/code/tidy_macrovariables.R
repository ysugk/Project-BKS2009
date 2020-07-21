rm(list = ls())

library(tidyverse)
library(lubridate)
library(labelled)

tb <- read_csv("build/input/FRED/TB3MS.csv")
aaa <- readxl::read_excel("build/input/FRED/AAA.xls", skip = 10)
baa <- readxl::read_excel("build/input/FRED/BAA.xls", skip = 10)

tidy_tb <- tb %>%
  mutate(date = ymd(yyyymmdd),
         year = year(date)) %>%
  group_by(year) %>%
  summarise(tb3 = mean(tb3ms))

var_label(tidy_tb) <- c("year", "the average annual t-bill yield (%)")

write_rds(tidy_tb, "build/output/tbill.rds", compress = "gz")

tidy_cs <- full_join(aaa, baa, by = "observation_date") %>%
  mutate(date = ymd(observation_date),
         year = year(date),
         creditspread = BAA - AAA) %>%
  group_by(year) %>%
  summarise(creditspread = mean(creditspread))

var_label(tidy_cs) <- c("year", "the average annual Moodys AAA - BAA (%)")

write_rds(tidy_cs, "build/output/creditspread.rds", compress = "gz")
