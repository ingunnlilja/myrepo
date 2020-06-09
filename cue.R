
ac <- read_csv('data/answer_cue_full.csv')

ac %>%
  mutate(cue = ifelse(questionId %in% cue_id_vec$questionId, 1, 0)) %>%
  group_by(lectureId, studentId) %>%
  mutate(cue_seq1 = ifelse(lag(cue) == 1, 1, 0),
         cue_seq2 = ifelse(lead(cue) == 1, 1, 0),
         cue_seq = cue + cue_seq1 + cue_seq2,
         attempt = row_number()) %>% 
  dplyr::select(cue, cue_seq, attempt, correct) %>%
  filter(cue_seq == 1) %>%
  arrange(lectureId, studentId, attempt) %>%
  mutate(sum_c = sum(cue_seq)) %>%
  filter(sum_c %% 3 == 0)

summary(ac)

