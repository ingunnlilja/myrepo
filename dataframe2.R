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


answer<-tbl(con,"answer")
lecture<-tbl(con,"lecture")
question<-tbl(con,"question")
subscript <- tbl(con, 'subscription')
lectureStudentSetting<-tbl(con,"lectureStudentSetting")


read_csv('data/cue_all.txt', col_names = F) %>% pull() -> cue_vec


read_csv('data/cue_all.txt', col_names = F) %>%
  separate(X1, into = c('plonePath', 'cue'), sep = '.cue') %>%
  pull(plonePath) -> nocue_vec


question %>%
  filter(plonePath %in% cue_vec) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> cue_id_vec


question %>%
  filter(plonePath %in% nocue_vec) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> nocue_id_vec


intersect(nocue_id_vec$questionId, cue_id_vec$questionId)


answer %>%
  filter(questionId %in% local(cue_id_vec$questionId)) %>%
  collect() -> cue_tmp


answer %>%
  filter(questionId %in% local(nocue_id_vec$questionId)) %>%
  collect() -> nocue_tmp

nocue_tmp %>%
  left_join(nocue_id_vec) %>%
  dplyr::select(answerId, lectureId, studentId, questionId, plonePath, everything()) %>%
  mutate(cue = 0) -> tmp1

cue_tmp %>%
  left_join(cue_id_vec) %>%
  dplyr::select(answerId, lectureId, studentId, questionId, plonePath, everything()) %>%
  mutate(cue = 1) -> tmp2

rbind(tmp1, tmp2) -> ans

tmp3 <- (strsplit(ans$plonePath, "/"))

df <- data.frame(matrix(unlist(tmp3), nrow=length(tmp3), byrow=T))

names(df)

glimpse(df)

df %>% 
  dplyr::select(X6) -> qName

bind_cols(ans, qName) -> ans

names(ans) <- c("answerId", "lectureId", "studentId", "questionId", "plonePath", "chosenAnswer", "grade", "correct", "timeStart",
                "timeEnd", "practice", "coinsAwarded", "ugQuestionGuid", "lectureVersion", "cue", "qName")


write_csv(x = ans, path = 'data/answers_cue_nocue.csv')
