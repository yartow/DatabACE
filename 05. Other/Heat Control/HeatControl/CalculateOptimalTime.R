# Required libraries
library(dplyr)

# Input parameters
P_day <- 0.30  # Daytime kWh price
P_night <- 0.20  # Nighttime kWh price
target_time <- as.POSIXct("2024-12-13 08:30:00")  # Target time to reach temperature
T_target <- 21  # Target temperature (°C)
T_start <- 15  # Initial room temperature (°C)
heater_power <- 2.0  # Heater power in kW

# Load empirical data
# Assumes you have a data frame `empirical_data` with columns:
# - time: POSIXct, hourly timestamps
# - T_out: Outside temperature (°C)
# - T_in: Inside temperature (°C)
# - energy_used: Energy used (kWh)

# Example empirical data
set.seed(42)
empirical_data <- data.frame(
  time = seq.POSIXt(from = as.POSIXct("2024-12-12 00:00:00"), 
                    to = as.POSIXct("2024-12-13 23:00:00"), by = "hour"),
  T_out = 5 + rnorm(48, sd = 2),
  T_in = 15 + rnorm(48, sd = 1),
  energy_used = runif(48, 0.5, 2.0)
)

# Calculate R_heat (heating rate per degree)
empirical_data <- empirical_data %>%
  mutate(delta_T = T_in - T_out,
         R_heat = ifelse(delta_T > 0, energy_used / delta_T, NA))

# Fit a model for R_heat as a function of delta_T
model <- lm(R_heat ~ delta_T, data = empirical_data, na.action = na.exclude)

# Function to calculate heating time
calculate_start_time <- function(T_start, T_target, T_out, target_time, model, heater_power) {
  # Predict R_heat based on delta_T
  delta_T <- T_target - T_out
  R_heat <- predict(model, newdata = data.frame(delta_T = delta_T))
  
  # Calculate time needed to heat (minutes)
  time_to_heat <- (T_target - T_start) * R_heat * 60
  
  # Calculate start time
  start_time <- target_time - as.difftime(time_to_heat, units = "mins")
  return(start_time)
}

# Find optimal start time for each hour
optimal_times <- empirical_data %>%
  mutate(start_time = calculate_start_time(T_start, T_target, T_out, target_time, model, heater_power),
         cost_day = energy_used * P_day,
         cost_night = energy_used * P_night)

# Print optimal start time
optimal_start <- optimal_times %>%
  filter(time <= target_time) %>%
  filter(start_time == max(start_time))

cat("Optimal Start Time:", optimal_start$start_time, "\n")
