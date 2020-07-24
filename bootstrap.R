# Bootstrap

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
drasl <- data.frame(auc_b = rep(0, B),
                    auc_afgangs = rep(0, B),
                    auc_opt = rep(0, B))
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
  fit <- glmer(correct ~ cue + qName + cue:qName + (1|studentId), 
               data = tmp,
               nAGQ = 0, 
               control = glmerControl(optimizer = 'nloptwrap'),
               family = 'binomial')
  
  # bootstrap auc
  boot.pred <- predict(fit, type = 'response')
  drasl[i, 1] <- auc(roc(tmp$correct, boot.pred, quiet = T))[[1]]
  # afgangur auc
  rest.pred <- predict(fit, type = 'response', newdata = cue_nocue, allow.new.levels = T)
  drasl[i, 2] <- auc(roc(cue_nocue$correct, rest.pred, quiet = T))[[1]]
  # optimism
  drasl[i, 3] <- drasl[i, 1] - drasl[i, 2]
  if (i %% 10 == 0) {print(i)}
}
Sys.time() - time # 20 min fyrir 500 itranir
fit.ful <- glmer(correct ~ cue + qName + cue:qName + (1|studentId), 
                 data = cue_nocue,
                 nAGQ = 0, 
                 control = glmerControl(optimizer = 'nloptwrap'),
                 family = 'binomial')

auc(roc(cue_nocue$correct, predict(fit.ful, type = 'response'), quiet = T))[[1]] - mean(drasl$auc_opt)

write_csv(x = drasl, path = 'drasl.csv')