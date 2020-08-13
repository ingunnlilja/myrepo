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

#Bý til vigur úr cue all 
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

#Vel lectureId úr cue_tmp og geri einstakt - Bý til vigur með gildunum
cue_lecture <- unique(cue_tmp$lectureId)

#lecture var sín eigin tafla
#Breytir lecture töflunni þannig að einungis fyrirlestrar með cue eru inni
#Fer svo í gegnum lecture með lectureID úr cue
lecture %>%
  filter(lectureId %in% local(cue_lecture)) %>% 
  collect()

#passsa að kóðinn að ofan býr til cue_tmp ekki breytingu
#aftur í answer töfluna
#Hér breyti ég answer útfrá að lecture passi -
#safna eftir lecture og student -
#filtera svo í gegn með að bara séu sp. í cue.
answer %>%
  group_by(lectureId, studentId) %>%
  #Miðað við þetta er ekki allt cue en er bara með lecture þar sem það kom fyrir
  filter(lectureId %in% local(cue_lecture)) %>%
  collect() %>%
  #Flokka töfluna eftir fyrirlestrum og nemendum.
  group_by(lectureId, studentId) %>%
  #filtera svo aftur þannig það sé dæmi um að nemandi hafi fengið cue á fyrirlestri
  #bara með nemendur sem hafa fengið cue dumpa öðrum
  filter(any(questionId %in% local(cue_id_vec$questionId))) -> answer_cue_full

#Ég vil bæta strax inn cue, 1 ef til staðar annars 0
answer_cue_full %>%
  mutate(cue = ifelse(questionId %in% cue_id_vec$questionId, 1, 0)) -> answer_cue_full

write_csv(x = answer_cue_full, path = 'data/answer_cue_full.csv')


#Búa til cue rétt - skil ekki alveg

# Tek answer_cue_full, 
# nota mutate = ef questionID er í cue_ID_vec$questionID þá 1 annars 0
# groupa svo eftir lectureID og student ID - þarf þá ekki að ofan
# Þá er mutate á að búa til nýja cue sem telur sama
# lag er hvort það sé cue á eftir
# lead er hvort það sé á undan
# Hvað er í gangi neðst????

#Nú er nýr rammi fyrir fyrir og eftir cue skráningu
 answer_cue_full %>%
   #Held þessi lína sé óþörf?
   group_by(lectureId, studentId) %>%
   #mutate bætir inn nýjum línum svo ég er að setja inn dálka.
   #cue_seq1 er hvort það sé vísb á eftir cue, 1 ef svo er og 0 ef ekki - lead á undan.
   mutate(cue_seq1 = ifelse(lag(cue) == 1, 1, 0),
          cue_seq2 = ifelse(lead(cue) == 1, 1, 0),
          #seq gefur hvert gildið er á þeim þrem í röð. 
          cue_seq = cue + cue_seq1 + cue_seq2,
          #set líka attempt = row_number, tilraun númer?
          attempt = row_number()) %>% 
   #Vel svo út aðeins þessa dálka
   dplyr::select(cue, cue_seq, attempt, correct, grade) %>%
   #Vil aðeins hafa cue_seq == 1 þar sem þá fæ ég niðurstöðu á hvort cue hjálpaði eða ekki
   filter(cue_seq == 1) %>%
   #raða í rétta röð
   dplyr::arrange(lectureId, studentId, attempt) %>%
   #bæti tinn sum_c sem er summa cue_seq
   mutate(sum_c = sum(cue_seq)) %>%
   filter(sum_c %% 3 == 0) -> cue_rett
 
 write_csv(x = cue_rett, path = 'data/cue_rett.csv')
 
 
   
 