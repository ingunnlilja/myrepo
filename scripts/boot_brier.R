
# Bootstrap fyrir cue, qName

cue_nocue <- read.csv("data/answers_cue_nocue.csv")

cue_nocue %>% 
  group_by(studentId, lectureId) %>%
  group_nest() %>%
  group_by(lectureId) %>%
  mutate(n = n()) %>%
  group_by(lectureId, n) %>%
  group_nest() -> bs_full

B <- 100
set.seed(1)
time <- Sys.time()
drasl_cue_allt <- data.frame(auc_b = rep(0, B),
                    auc_afgangs = rep(0, B),
                    auc_opt = rep(0, B),
                    brier_b = rep(0, B),
                    brier_afgangs = rep(0, B),
                    brier_opt = rep(0,B))
for (i in 1:B) {
  tmp <- tibble()
  for(j in 1:nrow(bs_full)) {
    n <- bs_full$n[j]
    bs_full %>%
      filter(lectureId == bs_full$lectureId[j]) %>%
      unnest(cols = c(data)) %>%
      dplyr::select(-n) %>%
      sample_n(size = n, replace = T) %>% 
      unnest(cols = c(data)) -> bs_tmp
    tmp <- rbind(tmp, bs_tmp)
  }
  fit <- glmer(correct ~ cue + qName + cue:qName+ (1|studentId), 
               data = tmp,
               nAGQ = 0, 
               control = glmerControl(optimizer = 'nloptwrap'),
               family = 'binomial')
  
  # bootstrap auc
  boot.pred <- predict(fit, type = 'response')
  drasl_cue_allt[i, 1] <- auc(roc(tmp$correct, boot.pred, quiet = T))[[1]]
  
  # afgangur auc
  rest.pred <- predict(fit, type = 'response', newdata = cue_nocue, allow.new.levels = T)
  drasl_cue_allt[i, 2] <- auc(roc(cue_nocue$correct, rest.pred, quiet = T))[[1]]
  
  # optimism auc
  drasl_cue_allt[i, 3] <- drasl_cue_allt[i, 1] - drasl_cue_allt[i, 2]
  
  # bootstrap brier
  b_boot <- mean((tmp$correct - predict(fit, type = 'response'))^2)
  bm_boot <- mean(predict(fit, type = 'response'))* (1-mean(predict(fit, type = 'response')))
  drasl_cue_allt[i,4] <- (1- b_boot/bm_boot)
  
  # afgangur brier
  b_rest <- mean((cue_nocue$correct - predict(fit, type = 'response', newdata = cue_nocue, allow.new.levels = T))^2)
  bm_rest <- mean(predict(fit, type = 'response', newdata = cue_nocue, allow.new.levels = T))* (1-mean(predict(fit, type = 'response', newdata = cue_nocue, allow.new.levels = T)))
  drasl_cue_allt[i,5] <- (1- b_rest/bm_rest)
  
  #optimism brier
  drasl_cue_allt[i,6] <- drasl_cue_allt[i,4]-drasl_cue_allt[i,5]
  
  if (i %% 10 == 0) {print(i)}
}

Sys.time() - time # 20 min fyrir 500 itranir
fit.ful <- glmer(correct ~ cue + qName + cue:qName + (1|studentId), 
                 data = cue_nocue,
                 nAGQ = 0, 
                 control = glmerControl(optimizer = 'nloptwrap'),
                 family = 'binomial')

write_csv(x = drasl_cue_allt, path = 'drasl_cue_allt.csv')
