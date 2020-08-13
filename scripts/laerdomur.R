cue_nocue <- read.csv("data/answers_cue_nocue.csv")

cue_nocue %>%
dplyr::select(timeEnd, cue, studentId, lectureId) -> timi

timi %>%
  group_by(studentId, lectureId) %>%
  dplyr::select(timeEnd, cue) -> ab

timi %>% 
  filter(cue==0) -> timi_cue

timi %>% 
  filter(cue==1) -> timi_ancue
# Nei græddi ekkert á þessu
# Þarf gagnaramma með engu cue en cue en merkt við allar spruningar sem komu á eftir cue.
# Merkja við spurningar sem voru spurning á eftir cue fyrir hvern nemenda
# cuenocue eru allar spurningar sem voru bornar fram sem bæði cue og ekki cue. Ég hlut þá að geta dregið upplýsingar 
# úr stóra gagnarammanum aftur.


# GAME PLAN


# er inní gagnarammanum fyrir öll svör tutor-web. Þar fer ég og finn allar cue spurningar. - 
## Þarf ekki á því að halda að spurningin sem er cue hafi líka verið borin fram sem án cue.JÚ BULL

#fyrir hverja spurningu sem var borin fram sem bæði cue og ekki cue skoða ég gengið hjá sama nemenda eftir á.

# Okei hef semsagt ramma með cue og án cue með sama qName. Ég þarf að finna fyrir hvern nemenda og lecture spurninguna-
## sem kom á eftir. Bý þá til fyrir sitthvorn rammann nýja ramma sem innihalda spurningarnar sem komu á eftir. 


