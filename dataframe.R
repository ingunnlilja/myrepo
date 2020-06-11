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

# Töflur
answer<-tbl(con,"answer")
lecture<-tbl(con,"lecture")
question<-tbl(con,"question")
subscript <- tbl(con, 'subscription')
lectureStudentSetting<-tbl(con,"lectureStudentSetting")

read_csv('data/cue_all.txt', col_names = F) %>% pull() -> cue_vec

#Fer í gegnum question töfluna og vel út þau plonepath sem matcha við cue_vec
#Safna þeim saman og svo vel ég úr questionId og plonepath og bý til, cue_id_vec
#Er þá komin með töflu sem inniheldur id og plonepath
question %>%
  filter(plonePath %in% cue_vec) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> cue_id_vec

#Vel úr answer töflunni sameiginleg gildi á milli ID - safnað saman í cue_tmp
answer %>%
  filter(questionId %in% local(cue_id_vec$questionId)) %>%
  collect() -> cue_tmp

#Vel lectureId úr cue_tmp og geri einstakt
cue_lecture <- unique(cue_tmp$lectureId)

#Fer svo í gegnum lecture með lectureID úr cue
lecture %>%
  filter(lectureId %in% local(cue_lecture)) %>% 
  collect()

#aftur í answer töfluna 
answer %>%
  group_by(lectureId, studentId) %>%
  filter(lectureId %in% local(cue_lecture)) %>%
  collect() %>%
  group_by(lectureId, studentId) %>%
  filter(any(questionId %in% local(cue_id_vec$questionId))) -> answer_cue_full


write_csv(x = answer_cue_full, path = 'data/answer_cue_full.csv')

#Rammi kominn til að vinna með.
         