# Read in the data
df <- read.csv("daily_data.csv")

install.packages("ggplot2")
library(ggplot2)

# Step 2: Create the scatter plot and line chart
g1 <- ggplot(df, aes(x = Year,group=1)) +
  geom_point(aes(y = daily_discharges_deaths, color = "Daily Discharges/Deaths"), size = 1.5) +
  geom_point(aes(y = daily_inpatients, color = "Daily Inpatients"), size = 1.5) +
  geom_point(aes(y = daily_patient_num, color = "Daily Patient Number"), size = 1.5) +
  geom_line(aes(x = Year, y = daily_discharges_deaths, color = "Daily Discharges/Deaths"), size = 0.8) +
  geom_line(aes(x = Year, y = daily_inpatients, color = "Daily Inpatients"), size = 0.8) +
  geom_line(aes(x = Year, y = daily_patient_num, color = "Daily Patient Number"), size = 0.8) +
  scale_color_manual(values = c("skyblue4", "lightsalmon3", "skyblue3")) +
  labs(x = "Year", y = " ", color = "Variable") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  guides(color = guide_legend(title = "", position = "right")) +
  ggtitle("Average Daily Demand for Medical Service, \n2008-09 to 2021-22")

g1

