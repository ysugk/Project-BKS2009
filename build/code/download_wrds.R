rm(list = ls())

library(RPostgres)
library(tidyverse)
library(labelled)

# set-up ------
wrds <- dbConnect(Postgres(),
                  host = 'wrds-pgdata.wharton.upenn.edu',
                  port = 9737,
                  dbname = 'wrds',
                  sslmode = 'require',
                  user = 'ysugk')

# look into schema ------
res <- dbSendQuery(wrds, "select distinct table_schema
                   from information_schema.tables
                   where table_type ='VIEW'
                   or table_type ='FOREIGN TABLE'
                   order by table_schema")

data <- dbFetch(res, n = -1)
dbClearResult(res)

res <- dbSendQuery(wrds, "select distinct table_name
                   from information_schema.columns
                   where table_schema='compa'
                   order by table_name")
data <- dbFetch(res, n = -1)
dbClearResult(res)

res <- dbSendQuery(wrds, "select column_name
                   from information_schema.columns
                   where table_schema='crspa'
                   and table_name='crsp_header'
                   order by ordinal_position")
data <- dbFetch(res, n = -1)
dbClearResult(res)

# download comphead ------
res <- dbSendQuery(wrds, "SELECT *
                   FROM crspa.comphead")
data <- dbFetch(res, n = -1)
dbClearResult(res)

write_rds(data, "build/input/wrds/comphead.rds", compress = "gz")

# download crsp header ------
res <- dbSendQuery(wrds, "SELECT *
                   FROM crspa.dsfhdr")

data <- dbFetch(res, n = -1)
dbClearResult(res)

write_rds(data, "build/input/wrds/crsphead.rds", compress = "gz")

# download link hist ------
res <- dbSendQuery(wrds, "SELECT *
                   FROM crspa.ccmxpf_lnkhist")
data <- dbFetch(res, n = -1)
dbClearResult(res)

write_rds(data, "build/input/wrds/ccmxpf_lnkhist.rds", compress = "gz")

res <- dbSendQuery(wrds, "SELECT *
                   FROM crspa.ccmxpf_lnktable")
data <- dbFetch(res, n = -1)
dbClearResult(res)

write_rds(data, "build/input/wrds/ccmxpf_lnkhist.rds", compress = "gz")

# download index const ------
res <- dbSendQuery(wrds, "SELECT *
                   FROM compa.idxcst_his")
idxcst_his <- dbFetch(res, n = -1)
dbClearResult(res)

res <- dbSendQuery(wrds, "SELECT *
                   FROM compa.idx_index")
idx_index <- dbFetch(res, n = -1)
dbClearResult(res)

data <- idxcst_his %>%
  semi_join(filter(idx_index, tic == "I0003"), by = "gvkeyx")

write_rds(data, "build/input/wrds/idxcst_his.rds", compress = "gz")

# download funda -----
select_condition <- c("gvkey", "datadate", "indfmt", "datafmt", "popsrc", "consol", "curcd", "costat",
           "fyear", "tic", "cusip", "fyr", "che", "dlc", "dltt", "at", "oibdp", "txt", "xint", "dvp", 
           "dvc", "prcc_f", "cshpri", "pstkl", "txditc", "invt", "ppent", "pi", "sale", 
           "re", "act", "lct", "csho", "ajex", "ni", "capx", "xrd", "aqc", "wcap", "ceq", "ebitda",
           "dltis", "dltr", "sstk", "prstkc", "ib") %>%
  paste0(collapse = ", ")

where_condition <- c("(fyear between 1960 and 2011)", "AND",
                     "indfmt = 'INDL'", "AND",
                     "datafmt = 'STD'", "AND",
                     "popsrc = 'D'", "AND",
                     "consol = 'C'") %>%
  paste0(collapse = " ")

from_condition <- "comp.funda"

queue <- paste("SELECT", select_condition, "FROM", from_condition, "WHERE", where_condition, sep = " ")

res <- dbSendQuery(wrds, queue)
data <- dbFetch(res, n = -1)
dbClearResult(res)

var_label(data) <- list(gvkey = "global key",
                        datadate = "data date",
                        indfmt = "industry format",
                        datafmt = "data format",
                        popsrc = "population source",
                        consol = "consolidation level",
                        curcd = "currency",
                        costat = "company status",
                        fyear = "fiscal year", 
                        tic = "ticker",
                        cusip = "cusip",
                        fyr = "fiscal year-end",
                        che = "cash and short-term investments",
                        dlc = "short-term debt", 
                        dltt = "long-term debt", 
                        at = "total assets",
                        oibdp = "operating income before depreciation", 
                        txt = "income taxes - total",
                        txditc = "deferred taxes and investment tax credits",
                        xint = "interest and related expense - total",
                        dvp = "dividends - preferred",
                        dvc = "dividends - common",
                        prcc_f = "stock price", 
                        cshpri = "stock outstanding",
                        pstkl = "preferred stock liquidation value", 
                        invt = "inventory", 
                        ppent = "net PPE", 
                        pi = "pre-tax income", 
                        sale = "sales",
                        re = "retained earnings",
                        act = "current assets", 
                        lct = "current liabilities",
                        csho = "common shares outstanding",
                        ajex = "adjustment factor",
                        ni = "net income",
                        capx = "capital expenditure",
                        xrd = "r&d expenses",
                        aqc = "acquisition",
                        wcap = "working capital",
                        ceq = "common equity total",
                        ebitda = "EBITDA",
                        dltis = "long-term debt issuance",
                        dltr = "long-term debt reduction",
                        sstk = "equity sale",
                        prstkc = "equity purchases",
                        ib = "income before extraordinary items")

write_rds(data, "build/input/wrds/funda.rds", compress = "gz")
