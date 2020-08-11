source('scripts/settings.R')
d <- read_csv('data/binom_sim.csv')

# Plot barplot of sum
ggplot(data = d, aes(x = sum)) +
  geom_bar() +
  labs(x = 'Sum of string',
       y = 'Count') -> sum_bp
# Export plot
ggsave(filename = 'img/sum_bp.png', plot = sum_bp,
       width = 6, height = 6, dpi = 320)

# Get 10 most popular strings and their proportion
d %>%
  group_by(string) %>%
  summarize(p = n()/nrow(d)) %>%
  arrange(desc(p)) %>%
  ungroup() %>%
  filter(row_number() <= 10) -> pop_strings
# Export data
write_csv(x = pop_strings, 'tables/pop_strings.csv')

# Plot proprtions for pop_strings
ggplot(data = pop_strings, aes(x = string, y = p, group = 1)) +
  geom_point() +
  geom_line(size = 1, color = 'red', lty = 2) +
  labs(x = 'Binary string',
       y = 'Proportion') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) -> prop_plt
# Export
ggsave(filename = 'img/prop_plt.png', plot = prop_plt,
       width = 6, height = 6, dpi = 1000)
