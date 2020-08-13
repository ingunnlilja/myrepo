library(tidyverse)
library(DBI)
library(RMySQL)
library(lubridate)
library(dbplyr)
library(RMariaDB)
library(dplyr)

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
  filter(plonePath %in% nocue_vec) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> nocue_id_vec

nocue_id_vec$cue <- ".cue"
cue_plonepath<-unique(paste(nocue_id_vec$plonePath,nocue_id_vec$cue,sep=""))

question %>%
  filter(plonePath %in% cue_plonepath) %>%
  collect() %>%
  dplyr::select(questionId, plonePath) -> cue_id_vec

#eyða cue dálknum aftur út.
nocue_id_vec <- dplyr::select(nocue_id_vec, -(cue))

intersect(nocue_id_vec$questionId, cue_id_vec$questionId)

answer %>%
  filter(questionId %in% local(cue_id_vec$questionId)) %>%
  collect() -> cue_tmp

glimpse(cue_tmp)

answer %>%
  filter(questionId %in% local(nocue_id_vec$questionId)) %>%
  collect() -> nocue_tmp

glimpse(nocue_tmp)

nocue_tmp %>%
  left_join(nocue_id_vec) %>%
  dplyr::select(answerId, lectureId, studentId, questionId, plonePath, everything()) %>%
  mutate(cue = 0) -> tmp1

#setja inn dálkana og setja inn cue=1 fyrir allar sp.
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

ans$qName <- gsub(ans$qName, pattern=".cue$", replacement="")

ans <- filter(ans, qName != "Qgen-q0199")
ans <- filter(ans, qName != "question-008")

ans$answerId <- as.factor(ans$answerId)
ans$lectureId <- as.factor(ans$lectureId)
ans$studentId <- as.factor(ans$studentId)
ans$questionId <- as.factor(ans$questionId)
ans$correct <- as.integer(ans$correct)
ans$cue <- as.factor(ans$cue)

ans <- dplyr::select(ans, -(ugQuestionGuid))
ans <- dplyr::select(ans, -(coinsAwarded))
ans <- dplyr::select(ans, -(practice))
ans <- dplyr::select(ans, -(lectureVersion))
ans <- dplyr::select(ans, -(chosenAnswer))

write_csv(x = ans, path = 'data/answers_cue_nocue.csv')
