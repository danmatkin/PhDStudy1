
# Load the datafile
data <- read.csv('Study1Results.csv', header = FALSE)

# V8 = Condition Column
# V52 = Average Accuracy

get_significance <- function(p_vals) {
  sapply(p_vals, function(p_val) {
    if (p_val < 0.001) return("***")
    else if (p_val < 0.01) return("**")
    else if (p_val < 0.05) return("*")
    else return("NS")
  })
}

print('# ============================= 3. Experiment 3 =============================')
# ============================= 3.1 Digit Span Wrangling =============================
digit_data <- data[data$V8 == 'Digit Experimental', ]
digit_control_data <- data[data$V8 == 'Digit Control', ]
all_digit_data <- data[data$V8 %in% c('Digit Experimental', 'Digit Control'), ]

digit_df <- data.frame(Group = all_digit_data$V8, AverageAccuracy = all_digit_data$V52)

print('# ============================= 3.2 Digit Span Assumptions =============================')
print('# ============================= 3.2.1 Digit Span Normality =============================')
digit_normality_sw <- shapiro.test(digit_data$V52)
digit_control_normality_sw <- shapiro.test(digit_control_data$V52)

write.csv(digit_normality_df <- data.frame(
  Variable = c('Digit Experimental', 'Digit Control'),
  W = c(digit_normality_sw$statistic, digit_control_normality_sw$statistic),
  p.value = c(digit_normality_sw$p.value, digit_control_normality_sw$p.value),
  Significance = c(get_significance(digit_normality_sw$p.value),
                   get_significance(digit_control_normality_sw$p.value))
), "Experiment3/3.2.1 Digit Data Normality.csv")
digit_normality_df

# c_qq <- ggplot(digit_data, aes(sample = V52)) +
#   stat_qq() +
#   stat_qq_line() +
#   ggtitle("Q-Q Plot for digit")
#
# cc_qq <- ggplot(digit_control_data, aes(sample = V52)) +
#   stat_qq() +
#   stat_qq_line() +
#   ggtitle("Q-Q Plot for digit Control")

library(ggplot2)

digit_combined_qq <- ggplot(all_digit_data, aes(sample = V52, colour = factor(V8))) +
  stat_qq() +
  stat_qq_line()

ggsave("Experiment3/3.2.1 Digit QQ-Plot.png", plot = digit_combined_qq, width = 8, height = 4, dpi = 300)

print('# ============================= 3.2.2 Digit Span Homoscedasticity =============================')
library(car)
write.csv(as.data.frame(all_digit_data_homoscedasticity <- leveneTest(V52 ~ V8, data=all_digit_data)),
          'Experiment3/3.2.2 Digit Homoscedasticity.csv')
all_digit_data_homoscedasticity

print('# ============================= 3.3 Digit Span Descriptives =============================')
library(dplyr)
library(psych)
write.csv(as.data.frame(digit_descriptives <- digit_df %>%
  group_by(Group) %>%
  summarise(n = n(),
            mean = mean(AverageAccuracy, na.rm=TRUE),
            med = median(AverageAccuracy),
            sd = sd(AverageAccuracy),
            IQR = IQR(AverageAccuracy),
            skew = skew(AverageAccuracy),
            min = min(AverageAccuracy),
            max = max(AverageAccuracy))
), 'Experiment3/3.3 Digit Descriptives.csv')
digit_descriptives

print('# ============================= 3.4 Digit Span Inferentials =============================')
print('# ============================= 3.4.1 Digit Span T Test =============================')
digit_t_test <- t.test(AverageAccuracy ~ Group, var.equal = FALSE, data = digit_df)

print('# ============================= 3.4.2 Digit Span Effect Size =============================')
library(effsize)
digit_effect <- cohen.d(digit_data$V52, digit_control_data$V52, conf.level = 0.95)

print('# ============================= 3.4.3 Digit Parametric Inferential Saving =============================')
write.csv(digit_t_test_df <- data.frame(
  Variable = 'Experimental - Control',
  t = digit_t_test$statistic,
  df = digit_t_test$parameter,
  p.value = digit_t_test$p.value,
  Significance = get_significance(digit_t_test$p.value),
  LowerCI = digit_t_test$conf.int[1],
  UpperCI = digit_t_test$conf.int[2],
  MeanDifference = digit_t_test$estimate[1] - digit_t_test$estimate[2],
  CohensD = digit_effect$estimate,
  DMag. = digit_effect$magnitude,
  DLwrCI = digit_effect$conf.int[1],
  DUprCI = digit_effect$conf.int[2]
), "Experiment3/3.4.1 Digit Data T-Test.csv")
digit_t_test_df

print('# ============================= 3.4.4 Digit Span Non Parametric =============================')
digit_mann_whitney <- wilcox.test(AverageAccuracy ~ Group, data = digit_df, paired = FALSE, conf.int = TRUE)

print('# ============================= 3.4.5 Digit Span Non Parametric Effect Size =============================')
U <- digit_mann_whitney$statistic
r <- U / sqrt(length(digit_data) * length(digit_control_data)) # The formula for r is U / sqrt(group1_sample_size * group2_sample_size)
r

print('# ============================= 3.4.6 Digit Span Non-Parametric Inferential Saving =============================')
write.csv(digit_mann_whitney_df <- data.frame(
  Variable = 'Experimental - Control',
  W = digit_mann_whitney$statistic,
  p.value = digit_mann_whitney$p.value,
  Significance = get_significance(digit_mann_whitney$p.value),
  LowerCI = digit_mann_whitney$conf.int[1],
  UpperCI = digit_mann_whitney$conf.int[2],
  MeanDifference = digit_mann_whitney$estimate,
  r_Eff.Size = r
), "Experiment3/3.4.3 Digit Data Mann Whitney.csv")
digit_mann_whitney_df

print('# ============================= 3.5 Corsi x VPT x Digit Span One Way ANOVA =============================')
# ============================= 3.5.1 Data Wrangling =============================
all_data <- data[data$V8 %in% c('VPT Experimental', 'VPT Control', 'Corsi Experimental', 'Corsi Control', 'Digit Experimental', 'Digit Control'), ]
all_df <- data.frame(Group = all_data$V8, AverageAccuracy = all_data$V52)

print('# ============================= 3.5.2 All One Way ANOVA =============================')
all_df_aov <- aov(AverageAccuracy ~ Group, data = all_df)
all_model <- summary(all_df_aov)
hist(resid(all_df_aov))
qqnorm(resid(all_df_aov))
qqline(resid(all_df_aov))
plot(fitted(all_df_aov), resid(all_df_aov))
abline(h = 0, lty=2)
library(moments)
skewness(resid(all_df_aov))
kurtosis(resid(all_df_aov))

ks.test(resid(all_df_aov), 'pnorm', mean=mean(resid(all_df_aov)), sd = sd(resid(all_df_aov)))

print('# ============================= 3.5.3 All ANOVA Effect Size =============================')
library(effectsize)
all_effect_size <- eta_squared(all_df_aov)
all_effect_size

print('# ============================= 3.5.4 All One Way ANOVA Saving =============================')
all_aov_df <- as.data.frame(all_model[[1]])
all_aov_df <- cbind(all_aov_df, setNames(list(all_effect_size$Eta2, all_effect_size$CI_low, all_effect_size$CI_high),
                                         c("Eta2", "CI_low", "CI_High")))
write.csv(all_aov_df, "Experiment3/3.5.2 Corsi x VPT x Digit One Way ANOVA.csv")
all_aov_df

by(all_df$AverageAccuracy, all_df$Group, stat.desc)
stat.desc(all_df$AverageAccuracy)
library(pwr)
pwr.anova.test(k = 6, f = 19.16965, n = 20)

print('# ============================= 3.5.5 All Bonferroni Adjusted Pairwise Comparisons  =============================')
library(multcomp)
all_df$Group <- as.factor(all_df$Group)
all_df_aov <- aov(AverageAccuracy ~ Group, data = all_df)
all_df_pw <- glht(all_df_aov, linfct=mcp(Group='Tukey'))
all_sum_res <- summary(all_df_pw, test = adjusted('bonferroni'))
all_conf_res <- confint(all_df_pw)

all_conf_df <- as.data.frame(all_conf_res$confint)
all_conf_int <- all_conf_df[, c('lwr', 'upr')]

pairs <- names(all_sum_res$test$coefficients)

all_d_results <- list()

for(pair in pairs) {
  conditions <- unlist(strsplit(pair, ' - '))
  cond1 <- conditions[1]
  cond2 <- conditions[2]

  d <- cohen.d(all_df$AverageAccuracy[all_df$Group == cond1], all_df$AverageAccuracy[all_df$Group == cond2],
               conf.level = 0.95)
  all_d_results[[pair]] <- d
}

all_d_df <- data.frame(estimate=numeric(), magnitude=character(), lwr=numeric(), upr=numeric(), stringsAsFactors=FALSE)

for(lst in all_d_results) {
  estimate <- lst$estimate
  magnitude <- lst$magnitude
  lwr <- lst$conf.int[1]
  upr <- lst$conf.int[2]

  # Append to dataframe
  all_d_df <- rbind(all_d_df, data.frame(estimate=estimate, magnitude=magnitude, lwr=lwr, upr=upr, stringsAsFactors=FALSE))
}

write.csv(complete_all_pw_df <- data.frame(
  Estimate = all_sum_res$test$coefficients,
  TValue = all_sum_res$test$tstat,
  df = all_sum_res$df,
  p.value = all_sum_res$test$pvalues,
  Significance = get_significance(all_sum_res$test$pvalues),
  LowerCI = all_conf_df$lwr,
  UpperCI = all_conf_df$upr,
  CohensD = all_d_df$estimate,
  DMag. = all_d_df$magnitude,
  DLwrCI = all_d_df$lwr,
  DUprCI = all_d_df$upr
), 'Experiment3/3.5.5 Corsi x VPT x Digit Bonferroni Post Hocs.csv')
complete_all_pw_df

print('# ============================= 3.5.6 All Estimated Marginal Means Plot  =============================')
library(emmeans)

all_df <- all_df %>%
  mutate(Type = case_when(
    Group == 'Corsi Experimental' ~ 'Corsi',
    Group == 'Corsi Control' ~ 'Corsi',
    Group == 'VPT Experimental' ~ 'VPT',
    Group == 'VPT Control' ~ 'VPT',
    Group == 'Digit Experimental' ~ 'Digit',
    Group == 'Digit Control' ~ 'Digit'
  ))

all_df <- all_df %>%
  mutate(Condition = case_when(
    Group == 'Corsi Experimental' ~ 'Experimental',
    Group == 'Corsi Control' ~ 'Control',
    Group == 'VPT Experimental' ~ 'Experimental',
    Group == 'VPT Control' ~ 'Control',
    Group == 'Digit Experimental' ~ 'Experimental',
    Group == 'Digit Control' ~ 'Control'
  ))

all_df

emm_model <- lm(AverageAccuracy ~ Type*Condition, data = all_df)

emm_df <- as.data.frame(emm <- emmeans(emm_model, ~ Type | Condition))

all_emm_plot <- ggplot(emm_df, aes(x=Type, y = emmean, group = Condition)) +
  geom_jitter(data=all_df, aes(y = AverageAccuracy, color = Type), width = 0.2, height = 0) +
  geom_point(aes(color = Type), size = 3) +
  geom_errorbar(aes(ymin = emmean - SE, ymax = emmean + SE, color = Type), width = 0.2) +
  labs(y = "Estimated Marginal Means", x = "", color = "Condition") +
  facet_grid(~ Condition, scales = "free_x", space = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_text(size = 14, face = 'bold')) +
  scale_x_discrete(limits = c("Corsi", "VPT", "Digit"))

all_emm_plot

ggsave("Experiment3/3.5.6 Complete Estimated Marginal Means.png", plot = all_emm_plot, width = 1226, height = 840, dpi = 300)

print('# ============================= 3.5.7 Nested Model Comparison =============================')
all_df$Group_Reduced <- ifelse(all_df$Group %in% c('Digit Experimental', 'Digit Control'), 'Other', as.character(all_df$Group))

model1 <- lm(AverageAccuracy ~ Group_Reduced, data=all_df)
model2 <- lm(AverageAccuracy ~ Group, data = all_df)

write.csv(comparison <- anova(model1, model2), "Experiment3/3.5.7 Likelihood Ratio Nested Model Comparison.csv")
comparison