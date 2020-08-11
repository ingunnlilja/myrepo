library(tidyverse)
library(gridExtra)
library(ggthemes)
library(ggpubr)
library(knitr)
library(kableExtra)
library(latex2exp)
library(bookdown)
library(scales)
theme_set(theme_tufte() +
            theme(panel.border = element_rect('black', fill = NA),
                  text = element_text(size = 14),
                  legend.text=element_text(size=14),
                  axis.text=element_text(size=14),
                  axis.title = element_text(size = 14),
                  plot.title = element_text(hjust = 0.5)))

ifelse(exists('d'), print('Loaded'), d <- read_csv('data/binom_sim.csv'))
