
#Les inn gagnatöfluna
cue_nocue <- read.csv("../myr/data/answers_cue_nocue.csv")

cue_nocue %>%
  filter(cue==0) %>%
  dplyr::select(qName, correct, cue)  %>% 
  group_by(qName) %>% 
  summarise(medal = 10*sum(correct==1)/length(qName))-> tmp_nocue_medal

cue_nocue %>%
  filter(cue==1) %>%
  dplyr::select(qName, correct, cue) %>% 
  group_by(qName) %>% 
  summarise(medal = 10*sum(correct==1)/length(qName)) -> tmp_cue_medal


#Tapaði út cue en fæ það aftur inn svona:

tmp_cue_medal$cue <- "1"
tmp_nocue_medal$cue <- "0"

rbind.data.frame(tmp_cue_medal, tmp_nocue_medal) -> medal

write_csv(x = medal, path = 'data/medal.csv')
