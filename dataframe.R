library(tidyverse)
library(DBI)
library(RMySQL)
library(lubridate)
library(dbplyr)
library(RMariaDB)

con<-src_mysql("tw_quizdb",
                host = "127.0.0.1", 
                port = 3306, 
                user = "ilb8", 
                password = "AIAtKDEMe2S0I")

# connect
answer<-tbl(con,"answer")
lecture<-tbl(con,"lecture")
question<-tbl(con,"question")
subscript <- tbl(con, 'subscription')
lectureStudentSetting<-tbl(con,"lectureStudentSetting")

read_csv('data/cue_all.txt', col_names = F) %>% pull() -> cue_vec

question %>%
  filter(plonePath %in% cue_vec) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> cue_id_vec

answer %>%
  filter(questionId %in% local(cue_id_vec$questionId)) %>%
  collect() -> cue_tmp

cue_lecture <- unique(cue_tmp$lectureId)

lecture %>%
  filter(lectureId %in% local(cue_lecture)) %>% 
  collect()

answer %>%
  #group_by(lectureId, studentId) %>%
  filter(lectureId %in% local(cue_lecture)) %>%
  collect() %>%
  group_by(lectureId, studentId) %>%
  filter(any(questionId %in% local(cue_id_vec$questionId))) -> answer_cue_full

write_csv(x = answer_cue_full, path = 'data/answer_cue_full.csv')

#Rammi kominn til að vinna með.
         