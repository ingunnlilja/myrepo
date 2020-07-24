
#Dummy kóði

# cue_nocue %>%
#   group_by(qName, cue) %>%
#   summarize(mean = mean(correct)) %>%
#   ggplot(aes(x= qName, y=mean, color=cue)) +
#   geom_point() +
#   theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))


```{r}
# cue_yfir_fimm %>%
#   group_by(cue) %>%
#     summarise(fjoldi=length(cue), medal_einkunn=mean(grade, na.rm = T), midgildi=median(grade, na.rm = T) ) %>%
#       kable() %>%
#         kable_styling(bootstrap_options = c("striped", "hover"))
```

```{r}
# cue_undir_fimm %>%
#   group_by(cue) %>%
#     summarise(fjoldi=length(cue), medal_einkunn=mean(grade, na.rm = T), midgildi=median(grade, na.rm = T) ) %>%
#       kable() %>%
#         kable_styling(bootstrap_options = c("striped", "hover"))
```


```{r}
#broom::tidy(glm1, exp = T)
```

```{r}
broom::augment(glm1, exp=T)
```


Eftirfarandi eru greiningar úr hagnnýtum línulegum tölfræðilíkönum. Vinn með kvörðun og ROC um sinn

```{r}
# #skoða betur
# par(mfrow=c(1,2), mar=c(3.5,3.5,2,1), mgp=c(2, 0.8, 0))
# St.res1 <- residuals(lm.fit)/ summary(lm.fit)$sigma
# plot(fitted(lm.fit), St.res1, xlab = "Fitted values",
# ylab = "Semi-studentized residuals")
# abline(h=0, lty=2)
# qqnorm(St.res1)
# qqline(St.res1)

```


```{r}
# par(mfrow = c(1,2))
# plot(medal$qName, St.res1, xlab = "qName", ylab = "Semi-studentized residuals")
# plot(medal$cue, St.res1, xlab = "cue", ylab = "Semi-studentized residuals")
```

```{r}
# sf <- summary(lm.fit)
# st.res <- lm.fit$residuals/summary(lm.fit)$sigma
# plot(fitted(lm.fit), st.res, xlab = "Fitted values", ylab = "studentized residuals")




```{r}
pcuts <- seq(0.05, 0.95, by=0.01)
ErrRate <- c()
n <- nrow(cue_nocue)

for(i in 1:length(pcuts)){
  pred <- rep(0, n)
  pred[phats > pcuts[i]] <- 1
  # ErrorRate:
  ErrRate[i] <- mean(pred != cue_nocue$correct)
}
plot(pcuts, ErrRate, type="l", ylim=c(0,0.7))
MinER <- min(ErrRate)
pcuts[ErrRate == MinER]; MinER

points(pcuts[ErrRate == MinER], ErrRate[ErrRate == MinER], col="red", pch=20)
#0.5 lookar vel
#26% error rate
```
```
avPlots


```{r}
ranef(glmer1) %>%
  as_tibble() %>%
  summarize(sd(condval))
```


```{r}
ranef(glmer1) %>%
  as_tibble() %>%
  ggplot(aes(x = condval)) +
  geom_density()
```