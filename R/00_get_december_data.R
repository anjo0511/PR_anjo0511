# -------------------------------------
# Author:
# Notes:
#
# Copyright(c) Ipsos Sweden
# -------------------------------------

library(tidyverse);library(magrittr)
# 
# https://api.sr.se/api/documentation/v2/generella_parametrar.html#filter
# 
get_songlist_per_channel <- function(DATE='2021-12-01', CHANNEL_ID=c(P3='164',P2='162',P1='132')[1] )  {
  
  LINK <- paste0("http://api.sr.se/api/v2/playlists/getplaylistbychannelid?",
            paste(c(
              glue::glue("id={CHANNEL_ID}"),
              glue::glue("startdatetime={DATE}T00:00:00Z"),
              glue::glue("enddatetime={DATE}T23:59:59Z")  ,
              'pagination=false', 'size=5000'),
              collapse="&") )
  
  b_root <- httr::GET(LINK) %>% 
       XML::xmlParse() %>% 
       XML::xmlRoot()
  
  b_root[-1] %>% 
    XML::xmlToDataFrame() %>% 
    as_tibble() %>% 
    arrange(starttimeutc)
}

res_dec <- 
  seq(as.Date("2018-01-01"), as.Date("2021-12-31"), 1) %>% 
  map_dfr(~{ 
    print(.x)
    get_songlist_per_channel(DATE = .x, CHANNEL_ID = "164") 
    })

res_dec_trimmed <- res_dec %>% 
  mutate(across(.cols = matches("timeutc"), .fns = ~lubridate::as_datetime(.))) %>% 
  mutate(across(.cols = where(is.character), .fns = ~{str_trim(str_squish(.),side = "both")})) %>% 
  mutate(across(.cols = where(is.character), .fns = ~na_if(.,""))) 

res_dec_trimmed %<>% 
  select(-conductor, -producer , -stoptimeutc) %>%
  relocate(starttimeutc,.before = 1)

res_dec_trimmed %<>% 
  mutate(year  = lubridate::year(starttimeutc),
         month = lubridate::month(starttimeutc), 
         hour  = lubridate::hour(starttimeutc), 
         date  = lubridate::as_date(starttimeutc), 
         year_month = glue::glue("{year}_{month}"), .before=1) %>%  
  select(-starttimeutc)

res_dec_trimmed %>% write_csv("Data/sveriges_radio_P3_2018_2021_TOT.csv")

