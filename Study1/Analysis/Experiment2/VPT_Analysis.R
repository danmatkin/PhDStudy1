
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

# V8 = Condition Column
# V52 = Average Accuracy
print('# ============================= 2. Experiment 2 =============================')
# ============================= 2.1 VPT Wrangling =============================
vpt_data <- data[data$V8 == 'VPT Experimental', ]
vpt_control_data <- data[data$V8 == 'VPT Control', ]
all_vpt_data <- data[data$V8 %in% c('VPT Experimental', 'VPT Control'), ]

vpt_df <- data.frame(Group = all_vpt_data$V8, AverageAccuracy = all_vpt_data$V52)

print('# ============================= 2.2 VPT Assumptions =============================')
print('# ============================= 2.2.1 VPT Normality =============================')
library(DescTools)

vpt_normality_sw <- shapiro.test(vpt_data$V52)
vpt_control_normality_sw <- shapiro.test(vpt_control_data$V52)

write.csv(vpt_normality_df <- data.frame(
  Variable = c('VPT Experimental', 'VPT Control'),
  W = c(vpt_normality_sw$statistic, vpt_control_normality_sw$statistic),
  p.value = c(vpt_normality_sw$p.value, vpt_control_normality_sw$p.value),
  Significance = c(get_significance(vpt_normality_sw$p.value),
                   get_significance(vpt_control_normality_sw$p.value))
), "Experiment2/2.2.1 VPT Data Normality.csv")
vpt_normality_df

library(ggplot2)
vpt_combined_qq <- ggplot(all_vpt_data, aes(sample = V52, colour = factor(V8))) +
  stat_qq() +
  stat_qq_line()

ggsave("Experiment2/2.2.1 VPT QQ-Plot.png", plot = vpt_combined_qq, width = 8, height = 4, dpi = 300)

print('# ============================= 2.2.2 VPT Control Transformation ============================')
library(psych)
vpt_control_df <- data.frame(Group = vpt_control_data$V8, AverageAccuracy = vpt_control_data$V52)
vpt_control_rev <- 2 - vpt_control_df$AverageAccuracy
vpt_control_df <- cbind(vpt_control_df, vpt_control_rev)
names(vpt_control_df)[3] <- 'Reversed'

vpt_control_df <- cbind(vpt_control_df, 1/vpt_control_rev)
names(vpt_control_df)[4] <- 'Reciprocal'

reciprocal <- ggplot(vpt_control_df, aes(x=Reciprocal)) +
  geom_histogram()

vpt_cont_rec_norm <- shapiro.test(vpt_control_df$Reciprocal)
vpt_cont_rec_skew <- skew(vpt_control_df$Reciprocal)

write.csv(vpt_cont_rec_normality_df <- data.frame(
  Variable = 'VPT Control',
  W = vpt_cont_rec_norm$statistic,
  p.value = vpt_cont_rec_norm$p.value,
  Significance = get_significance(vpt_cont_rec_norm$p.value),
  Skewness = vpt_cont_rec_skew
), 'Experiment2/2.2.2 VPT Control Reciprocal Transformed.csv')
vpt_cont_rec_normality_df

print('# ============================= 2.2.3 VPT Homoscedasticity =============================')
library(car)
write.csv(vpt_homoscedasticity <- as.data.frame(leveneTest(AverageAccuracy ~ Group, data=vpt_df)),
          'Experiment2/2.2.3 VPT Homoscedasticity.csv')
vpt_homoscedasticity

print('# ============================= 2.3 VPT Descriptives =============================')
library(GGally)
library(dplyr)
write.csv(as.data.frame(vpt_descriptives <- vpt_df %>% group_by(Group) %>%
  summarise(n = n(),
            mean = mean(AverageAccuracy, na.rm=TRUE),
            med = median(AverageAccuracy),
            sd = sd(AverageAccuracy),
            IQR = IQR(AverageAccuracy),
            skew = skew(AverageAccuracy),
            min = min(AverageAccuracy),
            max = max(AverageAccuracy))),
          'Experiment2/2.3 VPT Descriptives.csv')
vpt_descriptives

print('# ============================= 2.4 VPT Inferentials =============================')
print('# ============================= 2.4.1 VPT T Test =============================')
vpt_t_test <- t.test(AverageAccuracy ~ Group, data = vpt_df, var.equal = TRUE)

# R Squared
t_value <- vpt_t_test$statistic
df <- vpt_t_test$parameter

t_R_squared <- t_value^2 / (t_value^2 + df)
print(t_R_squared)

print('# ============================= 2.4.2 VPT Effect Size =============================')
library(effsize)
vpt_effect <- cohen.d(vpt_data$V52, vpt_control_data$V52, conf.level = 0.95)

print('# ============================= 2.4.4 VPT Parametric Inferential Saving =============================')

write.csv(vpt_t_test_df <- data.frame(
  Variable = 'Experimental - Control',
  t = vpt_t_test$statistic,
  df = vpt_t_test$parameter,
  p.value = vpt_t_test$p.value,
  Significance = get_significance(vpt_t_test$p.value),
  LowerCI = vpt_t_test$conf.int[1],
  UpperCI = vpt_t_test$conf.int[2],
  MeanDifference = vpt_t_test$estimate[1] - vpt_t_test$estimate[2],
  CohensD = vpt_effect$estimate,
  DMag. = vpt_effect$magnitude,
  DLwrCI = vpt_effect$conf.int[1],
  DUprCI = vpt_effect$conf.int[2]
), "Experiment2/2.4.1 VPT Data T-Test.csv")
vpt_t_test_df

print('# ============================= 2.4.3 VPT Non Parametric =============================')
vpt_mann_whitney <- wilcox.test(AverageAccuracy ~ Group, data = vpt_df, paired = FALSE, conf.int = TRUE)

print('# ============================= 2.4.4 VPT Non Parametric Effect Size =============================')
U <- vpt_mann_whitney$statistic
U
r <- U / (length(vpt_data) * length(vpt_control_data)) # The formula for r is U / sqrt(group1_sample_size * group2_sample_size)
r

print('# ============================= 2.4.5 VPT Non-Parametric Inferential Saving =============================')
write.csv(vpt_mann_whitney_df <- data.frame(
  Variable = 'Experimental - Control',
  W = vpt_mann_whitney$statistic,
  p.value = vpt_mann_whitney$p.value,
  Significance = get_significance(vpt_mann_whitney$p.value),
  LowerCI = vpt_mann_whitney$conf.int[1],
  UpperCI = vpt_mann_whitney$conf.int[2],
  MeanDifference = vpt_mann_whitney$estimate,
  r_Eff.Size = r
), "Experiment2/2.4.3 VPT Data Mann Whitney.csv")
vpt_mann_whitney_df

print('# ============================= 2.5 Corsi x VPT One Way ANOVA =============================')
# ============================= 2.5.1 Data Wrangling =============================
all_cor_vpt <- data[data$V8 %in% c('VPT Experimental', 'VPT Control', 'Corsi Experimental', 'Corsi Control'), ]
cor_vpt_df <- data.frame(Group = all_cor_vpt$V8, AverageAccuracy = all_cor_vpt$V52)

print('# ============================= 2.5.2 Corsi x VPT One Way ANOVA =============================')
cor_vpt_aov <- aov(AverageAccuracy ~ Group, data = cor_vpt_df)
model <- summary(cor_vpt_aov)
model

anova_RSS <- model[[1]]['Residuals', 'Sum Sq']

n <- length(cor_vpt_df$AverageAccuracy)
p <- 2  # For the t-test (two groups - 1)
q <- df.residual(cor_vpt_aov)
RSS_diff <- anova_RSS - t_test_RSS
if (RSS_diff < 0) {
  RSS_diff <- -RSS_diff
}

# Compute F-statistic
F_statistic <- (RSS_diff / p) / (anova_RSS / q)

# Compute p-value
p_value <- 1 - pf(F_statistic, p, q)

print(F_statistic)
print(p_value)

hist(resid(cor_vpt_aov))
qqnorm(resid(cor_vpt_aov))
qqline(resid(cor_vpt_aov))
plot(fitted(cor_vpt_aov), resid(cor_vpt_aov))
abline(h = 0, lty=2)
library(moments)
skewness(resid(cor_vpt_aov))
kurtosis(resid(cor_vpt_aov))

ks.test(resid(cor_vpt_aov), 'pnorm', mean=mean(resid(cor_vpt_aov)), sd = sd(resid(cor_vpt_aov)))

# R Squared for the ANOVA
model_sum_sq <- model[[1]]['Group', 'Sum Sq']
residuals_sum_sq <- model[[1]]["Residuals", "Sum Sq"]

R_squared <- model_sum_sq / (model_sum_sq + residuals_sum_sq)
R_squared

print('# ============================= 2.5.3 Corsi x VPT Effect Size =============================')
library(effectsize)
cor_vpt_effect <- eta_squared(cor_vpt_aov)

print('# ============================= 2.5.4 Corsi x VPT ANOVA Model Saving  =============================')
cor_vpt_aov_df <- as.data.frame(model[[1]])
cor_vpt_aov_df <- cbind(cor_vpt_aov_df, setNames(list(cor_vpt_effect$Eta2, cor_vpt_effect$CI_low, cor_vpt_effect$CI_high),
                                                 c("Eta2", "CI_low", "CI_High")))
write.csv(cor_vpt_aov_df, "Experiment2/2.5.2 Corsi x VPT One Way ANOVA.csv")
cor_vpt_aov_df

print('# ============================= 2.5.5 Corsi x VPT Bonferroni Adjusted Pairwise Comparisons  =============================')
library(multcomp)
cor_vpt_df$Group <- as.factor(cor_vpt_df$Group)
cor_vpt_aov <- aov(AverageAccuracy ~ Group, data = cor_vpt_df)

pairwise <- glht(cor_vpt_aov, linfct = mcp(Group = 'Tukey'))
summary(pairwise, test = adjusted('bonferroni'))
confint(pairwise)

sum_res <- summary(pairwise, test = adjusted('bonferroni'))
conf_res <- confint(pairwise)

conf_df <- as.data.frame(conf_res$confint)
conf_intervals <- conf_df[, c("lwr", "upr")]

# Extracting condition names from the pairwise comparisons
pairs <- names(sum_res$test$coefficients)

# Compute Cohen's d for each pairwise comparison
cohen_d_results <- list()

for(pair in pairs) {

  conditions <- unlist(strsplit(pair, ' - '))
  cond1 <- conditions[1]
  cond2 <- conditions[2]

  d <- cohen.d(cor_vpt_df$AverageAccuracy[cor_vpt_df$Group == cond1], cor_vpt_df$AverageAccuracy[cor_vpt_df$Group == cond2],
               conf.level = 0.95)
  cohen_d_results[[pair]] <- d
}

cohens_df <- data.frame(estimate=numeric(), magnitude=character(), lwr=numeric(), upr=numeric(), stringsAsFactors=FALSE)

for (lst in cohen_d_results) {
  # Extract the statistics
  estimate <- lst$estimate
  magnitude <- lst$magnitude
  lwr <- lst$conf.int[1]
  upr <- lst$conf.int[2]

  # Append to dataframe
  cohens_df <- rbind(cohens_df, data.frame(estimate=estimate, magnitude=magnitude, lwr=lwr, upr=upr, stringsAsFactors=FALSE))
}

write.csv(combined_df <- data.frame(
  Estimate = sum_res$test$coefficients,
  TValue = sum_res$test$tstat,
  df = sum_res$df,
  p.value = sum_res$test$pvalues,
  Significance = get_significance(sum_res$test$pvalues),
  LowerCI = conf_df$lwr,
  UpperCI = conf_df$upr,
  CohensD = cohens_df$estimate,
  DMag. = cohens_df$magnitude,
  DLwrCI = cohens_df$lwr,
  DUprCI = cohens_df$upr
), 'Experiment2/2.5.5 Corsi x VPT Bonferroni Post Hocs.csv')
combined_df

print('# ============================= 2.5.6 Corsi x VPT Estimated Marginal Means Plot =============================')
library(emmeans)
library(ggpubr)

cor_vpt_df <- cor_vpt_df %>%
  mutate(Type = case_when(
    Group == 'Corsi Experimental' ~ 'Corsi',
    Group == 'Corsi Control' ~ 'Corsi',
    Group == 'VPT Experimental' ~ 'VPT',
    Group == 'VPT Control' ~ 'VPT'
  ))

cor_vpt_df <- cor_vpt_df %>%
  mutate(Condition = case_when(
    Group == 'Corsi Experimental' ~ 'Experimental',
    Group == 'Corsi Control' ~ 'Control',
    Group == 'VPT Experimental' ~ 'Experimental',
    Group == 'VPT Control' ~ 'Control'
  ))

cor_vpt_df

emm_model <- lm(AverageAccuracy ~ Type*Condition, data = cor_vpt_df)

emm_df <- as.data.frame(emm <- emmeans(emm_model, ~ Type | Condition))

cor_vpt_emm_plot <- ggplot(emm_df, aes(x=Type, y = emmean, group = Condition)) +
  geom_jitter(data=cor_vpt_df, aes(y = AverageAccuracy, color = Type), width = 0.2, height = 0) +
  geom_point(aes(color = Type), size = 3) +
  geom_errorbar(aes(ymin = emmean - SE, ymax = emmean + SE, color = Type), width = 0.2) +
  labs(y = "Estimated Marginal Means", x = "", color = "Condition") +
  facet_grid(~ Condition, scales = "free_x", space = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_text(size = 14, face = 'bold'))

cor_vpt_emm_plot

ggsave("Experiment2/2.5.6 Corsi x VPT Estimated Marginal Means.png", plot = cor_vpt_emm_plot, width = 8, height = 4, dpi = 300)

print('# ============================= 2.5.7 Control Procedure Time Analysis =============================')

data <- read.csv('Study1Results.csv', header = FALSE)

corsi_time <- data[data$V8 == 'Corsi Control', ]
vpt_time <- data[data$V8 == 'VPT Control', ]
all_time <- data[data$V8 %in% c('Corsi Control', 'VPT Control'), ]

library(car)
leveneTest(V71 ~ V8, data = all_time)

all_cor_vpt <- data[data$V8 %in% c('Corsi Control', 'VPT Control'), ]

cor_vpt_time_df <- data.frame(Group = all_cor_vpt$V8, TotalTime = all_cor_vpt$V71)

vpt_time_hist <- ggplot(data = vpt_time, aes(x = V71)) +
  geom_histogram()
shapiro.test(vpt_time$V71)
vpt_time_hist

corsi_time_hist <- ggplot(data = corsi_time, aes(x = V71)) +
  geom_histogram()
shapiro.test(corsi_time$V71)
corsi_time_hist

combined_time_qq <- ggplot(all_time, aes(sample=V71, colour=factor(V8))) +
  stat_qq() +
  stat_qq_line()
combined_time_qq

boxplot <- ggplot(all_time, , aes(sample=V71, colour=factor(V8))) +
  geom_boxplot(aes(x = V8, y = V71))
boxplot

library(pastecs)
stat.desc(all_time$V71, norm=T)

vpt_outlier <- 254

data_without_outlier <- all_time$V71[all_time$V71 != vpt_outlier]
next_closest_value <- min(abs(data_without_outlier - vpt_outlier))
next_closest_actual_value <- data_without_outlier[which.min(abs(data_without_outlier - vpt_outlier))]
all_time$V71[all_time$V71 == vpt_outlier] <- next_closest_actual_value + 1

boxplot <- ggplot(all_time, , aes(sample=V71, colour=factor(V8))) +
  geom_boxplot(aes(x = V8, y = V71))
boxplot

shapiro.test(vpt_time$V71)

t.test(V71 ~ V8, data = all_time, var.equal = T)
cohen.d(V71 ~ V8, data = all_time, conf.level = 0.95)

library(pastecs)
stat.desc(all_time$V71, norm=T)

leveneTest(V71 ~ V8, data = all_time)
