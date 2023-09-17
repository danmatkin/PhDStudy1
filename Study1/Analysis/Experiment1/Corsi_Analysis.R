# Load a dataset from a file
data <- read.csv('Study1Results.csv', header = FALSE)

# Function to convert statistical p-values to significance levels
get_significance <- function(p_vals) {
  sapply(p_vals, function(p_val) {
    if (p_val < 0.001) return("***")
    else if (p_val < 0.01) return("**")
    else if (p_val < 0.05) return("*")
    else return("NS")
  })
}

# Display a section header for Experiment 1
print('# ============================= 1. Experiment 1 =============================')

# Prepare and categorize the data based on conditions
library(dplyr)
citation("dplyr")
corsi_data <- data[data$V8 == 'Corsi Experimental', ]             # Extract only 'Corsi Experimental' data
corsi_control_data <- data[data$V8 == 'Corsi Control', ]          # Extract only 'Corsi Control' data
all_corsi_data <- data[data$V8 %in% c('Corsi Experimental', 'Corsi Control'), ] # Combine both datasets

corsi_df <- data.frame(Group = all_corsi_data$V8, AverageAccuracy = all_corsi_data$V52)

# Checking the distribution of data to see if it follows a normal distribution
print('# ============================= 1.2 Corsi Assumptions =============================')
print('# ============================= 1.2.1 Corsi Normality =============================')
library(car)
corsi_normality_sw <- shapiro.test(corsi_data$V52)                # Check normality for 'Corsi Experimental'
corsi_control_normality_sw <- shapiro.test(corsi_control_data$V52) # Check normality for 'Corsi Control'

# Summarize the normality check results
corsi_normality_df <- data.frame(
  Variable = c('Corsi Experimental', 'Corsi Control'),
  W = c(corsi_normality_sw$statistic, corsi_control_normality_sw$statistic),
  p.value = c(corsi_normality_sw$p.value, corsi_control_normality_sw$p.value),
  Significance = c(get_significance(corsi_normality_sw$p.value),
                   get_significance(corsi_control_normality_sw$p.value))
)
corsi_normality_df

# Save the results to a CSV file
write.csv(corsi_normality_df, "Experiment1/1.2.1 Corsi Data Normality.csv")

# Create a visual plot to assess data normality
library(ggplot2)
corsi_combined_qq <- ggplot(all_corsi_data, aes(sample = V52, colour = factor(V8))) +
  stat_qq() +
  stat_qq_line()

# Save the visual plot as an image
ggsave("Experiment1/1.2.1 Corsi QQ-Plot.png", plot = corsi_combined_qq, width = 8, height = 4, dpi = 300)

# Check if data variances are equal across groups
print('# ============================= 1.2.2 Corsi Homoscedasticity =============================')
write.csv(corsi_homoscedasticity <- as.data.frame(leveneTest(V52 ~ V8, data=all_corsi_data)),
          "Experiment1/1.2.2 Corsi Data Homoscedasticity.csv")
corsi_homoscedasticity

# Compute basic statistics for the data
print('# ============================= 1.3 Corsi Descriptives =============================')
library(psych)
write.csv(as.data.frame(corsi_descriptives <- corsi_df %>% group_by(Group) %>%
  summarise(n = n(),
            mean = mean(AverageAccuracy, na.rm=TRUE),
            sd = sd(AverageAccuracy),
            min = min(AverageAccuracy),
            max = max(AverageAccuracy),
            skew = skew(AverageAccuracy)
  )), "Experiment1/1.3 Corsi Data Descriptives.csv")
corsi_descriptives

# Compare the two groups using a statistical test
print('# ============================= 1.4 Corsi Inferentials =============================')
print('# ============================= 1.4.1 Corsi Block T Test =============================')
corsi_t_test <- t.test(V52 ~ V8, var.equal = TRUE, data = all_corsi_data)

# R Squared
t_value <- corsi_t_test$statistic
df <- corsi_t_test$parameter

t_R_squared <- t_value^2 / (t_value^2 + df)
print(t_R_squared)

group1 <- corsi_data$V52
group2 <- corsi_control_data$V52

# Assuming group1 and group2 data
RSS_group1 <- sum((group1 - mean(group1))^2)
RSS_group2 <- sum((group2 - mean(group2))^2)

t_test_RSS <- RSS_group1 + RSS_group2

# Measure the size of the difference between the groups
print('# ============================= 1.4.2 Corsi Effect size =============================')
library(effsize)
corsi_effect <- cohen.d(corsi_data$V52, corsi_control_data$V52, conf.level = 0.95)

# Summarize and save the results of the comparison
print('# ============================= 1.4.3 DataSaving =============================')
write.csv(corsi_t_test_df <- data.frame(
  Variable = 'Experimental - Control',
  t = corsi_t_test$statistic,
  df = corsi_t_test$parameter,
  p.value = corsi_t_test$p.value,
  Significance = get_significance(corsi_t_test$p.value),
  LowerCI = corsi_t_test$conf.int[1],
  UpperCI = corsi_t_test$conf.int[2],
  MeanDifference = corsi_t_test$estimate[1] - corsi_t_test$estimate[2],
  CohensD = corsi_effect$estimate,
  DMag. = corsi_effect$magnitude,
  DLwrCI = corsi_effect$conf.int[1],
  DUprCI = corsi_effect$conf.int[2]
), "Experiment1/1.4.1 Corsi Data T-Test.csv")
corsi_t_test_df

citation()
version$version.string
