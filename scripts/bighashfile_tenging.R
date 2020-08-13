# Þetta eru leifar af kóða til að reyna að tengja saman hashfile og tw.

library(dbplyr)
library(dplyr)
library(RMySQL)
library(tidyr)
library(MASS)
library(compare)
library(ggplot2)
library(rvest)
library(dplyr)
library(knitr)
library(tidyverse)
library(gridExtra)
library(kableExtra)
library(xtable)
# tengjum tw

twDb<-src_mysql("tw_quizdb", 
                host = "127.0.0.1",
                port = 3306, 
                user = "ilb8", 
                password = "AIAtKDEMe2S0I")

# fra gunnari
answer <- tbl(twDb, "answer")
lecture<-tbl(twDb,"lecture")
question<-tbl(twDb,"question")
host<-tbl(twDb,"host")
coinAward<-tbl(twDb,"coinAward")
lectureGlobalSetting<-tbl(twDb,"lectureGlobalSetting")
lectureQuestions<-tbl(twDb,"lectureQuestions")
lectureSetting<-tbl(twDb,"lectureSetting")
lectureStudentSetting<-tbl(twDb,"lectureStudentSetting")
subscription<-as.data.frame(tbl(twDb,"subscription"))

lectureStudentSetting%>%group_by(key)%>%summarise(stdev=sd(value,na.rm=T),stdevlog=sd(log2(value),na.rm=T))->stdevs
hash<-read.csv("bighashfile.wide.txt",sep=" ",col.names = c("dir","qName","hash","hash2","hash3","numQ","notaType"),na.strings = ".")
pathQ<-unique(paste(hash$dir,hash$qName,sep=""))
plonePath<-unique(paste(hash$dir,hash$qName,sep=""))
plonePath<-as.data.frame(plonePath)
hash$plonePath<-paste(hash$dir,hash$qName,sep="")
left_join(plonePath,as.data.frame(question))->myQuestions
answer%>%filter(timeStart>"2020-01-01 00:01:01")->answerRed
answerRed<-as.data.frame(answerRed)
inner_join(answerRed,myQuestions) -> myAnswer
myAnswer<-as.data.frame(myAnswer)
inner_join(myAnswer,hash) -> fullAnswerData
fullAnswerData <- as.data.frame(fullAnswerData)

tibble(fullAnswerData)

cue_id <- read_csv('cue_id.csv', col_names = F)
cue_id2 <- cue_id$X2

fullAnswerData %>%
  filter(questionId %in% cue_id2)

# naum i cue path
cue_path <- read_csv('cue_all.txt', col_names = F)
cue_path$X1

tibble(fullAnswerData) %>%
  mutate(cue = ifelse(grepl('cue', x = plonePath),1, 0))%>%
  filter(cue == 1)


unique(fullAnswerData$plonePath) %>%
  enframe() %>%
  filter(grepl(pattern = 'cue', value))



tmp <- read_csv('bighashfile.txt', col_names = F)

filter(tmp, grepl('cue', X1))

