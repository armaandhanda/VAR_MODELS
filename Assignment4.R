###########################################################################################
# VAR Models
# Armaan Dhanda, UCLA

###########################################################################################

setwd("/Users/vishwasdhanda/Desktop/heltcare_project/forecasting/Data and Script 6")
library(quantmod) 
library(tseries)
library(forecast)
library(readxl) 
library(fpp2)
library(vars)
library(lmtest)

library(vars)

# Step 1: Import the data via quantmod
getSymbols("DCOILWTICO", src = "FRED")  # Oil price
getSymbols("NASDAQCOM", src = "FRED")   # NASDAQ stock price
getSymbols("PAYEMS", src = "FRED")      # Nonfarm payroll jobs
getSymbols("CPILFESL", src = "FRED")    # Core Consumer Price Index
getSymbols("DFF", src = "FRED")         # Federal Fund Rate

# Step 2: Set the full sample period and convert the series to monthly frequency
start_date <- "1986-02-01"
end_date <- "2024-08-31"

# Subset the data using date range and convert to monthly frequency using apply.monthly
oil <- apply.monthly(DCOILWTICO[paste0(start_date, "/", end_date)], 
                     FUN = function(x) mean(x, na.rm = TRUE))
stock <- apply.monthly(NASDAQCOM[paste0(start_date, "/", end_date)], 
                       FUN = function(x) mean(x, na.rm = TRUE))
job <- apply.monthly(PAYEMS[paste0(start_date, "/", end_date)], 
                     FUN = function(x) mean(x, na.rm = TRUE))
cpi <- apply.monthly(CPILFESL[paste0(start_date, "/", end_date)], 
                     FUN = function(x) mean(x, na.rm = TRUE))
frr <- apply.monthly(DFF[paste0(start_date, "/", end_date)], 
                     FUN = function(x) mean(x, na.rm = TRUE))

# Step 3: Plot the time series and convert them into ts objects
oil_ts <- ts(oil, start = c(1986, 2), frequency = 12)
stock_ts <- ts(stock, start = c(1986, 2), frequency = 12)
job_ts <- ts(job, start = c(1986, 2), frequency = 12)
cpi_ts <- ts(cpi, start = c(1986, 2), frequency = 12)
frr_ts <- ts(frr, start = c(1986, 2), frequency = 12)



# Step 4: Create the time series data frame with growth rates
# Continuously compounded growth rates (diff(log(series)))
oil_g <- diff(log(oil_ts))     # Growth rate for oil
stock_g <- diff(log(stock_ts)) # Growth rate for NASDAQ
job_g <- diff(log(job_ts))     # Growth rate for jobs
cpi_g <- diff(log(cpi_ts))     # Growth rate for CPI

# Keep the federal fund rate as it is (no growth transformation)
#frr_g <- frr_ts
frr_g <- diff(frr_ts)
# Combine the series into data frames
data0 <- cbind(oil_ts, stock_ts, job_ts, cpi_ts, frr_ts)  # Original data
data1 <- cbind(oil_g, stock_g, job_g, cpi_g, frr_g)       # Growth rate data

# Step 5: Create the train sets using the window function
data00 <- window(data0, start = c(1986, 3), end = c(2024, 6))
data11 <- window(data1, start = c(1986, 3), end = c(2024, 6))

# Display the first few rows to verify
head(data00)
head(data11)



# Plot the series
par(mfrow = c(3, 2))
plot(oil_ts, main = "Oil Price", col = "blue")
plot(stock_ts, main = "NASDAQ", col = "red")
plot(job_ts, main = "Nonfarm Payroll Jobs", col = "green")
plot(cpi_ts, main = "CPI", col = "purple")
plot(frr_ts, main = "Federal Fund Rate")
# Plot the growth rates
par(mfrow = c(3, 2))
plot(oil_g, main = "Oil Growth Rate", col = "blue")
plot(stock_g, main = "NASDAQ Growth Rate", col = "red")
plot(job_g, main = "Jobs Growth Rate", col = "green")
plot(cpi_g, main = "CPI Growth Rate", col = "purple")
plot(frr_g, main = "Federal Fund Rate")
# Select the lag of VAR model
VARselect(data00, lag=50,type="const")
lag_length <- 12

# Run the VAR model on the level data (data00) with both constant and trend
var_level <- VAR(data00, p = lag_length, type = "both")

# Run the VAR model on the growth rate data (data11) with constant only
var_growth <- VAR(data11, p = lag_length, type = "const")

# Display summaries of both models
summary(var_level)
summary(var_growth)

# Forecast the level model (data00) for the next 12 months
forecast_level <- predict(var_level, n.ahead = 12)

# Forecast the growth model (data11) for the next 12 months
forecast_growth <- predict(var_growth, n.ahead = 12)

# Plot forecasts for both models
par(mfrow = c(2, 2)) # Set up plot grid

# Plot forecasts for the level model
plot(forecast_level, main = "Forecast for Level Model (data00)", names = colnames(data00))

# Plot forecasts for the growth model
plot(forecast_growth, main = "Forecast for Growth Model (data11)", names = colnames(data11))

# Create ARIMA models for each variable and forecast for the next 12 months
oil_arima <- auto.arima(data00[, "oil_ts"])
stock_arima <- auto.arima(data00[, "stock_ts"])
job_arima <- auto.arima(data00[, "job_ts"])
cpi_arima <- auto.arima(data00[, "cpi_ts"])
frr_arima <- auto.arima(data00[, "frr_ts"])

# Generate forecasts using ARIMA models
oil_forecast <- forecast(oil_arima, h = 12)
stock_forecast <- forecast(stock_arima, h = 12)
job_forecast <- forecast(job_arima, h = 12)
cpi_forecast <- forecast(cpi_arima, h = 12)
frr_forecast <- forecast(frr_arima, h = 12)

# Plot ARIMA forecasts
par(mfrow = c(3, 2)) # Set up plot grid

plot(oil_forecast, main = "Oil ARIMA Forecast")
plot(stock_forecast, main = "NASDAQ ARIMA Forecast")
plot(job_forecast, main = "Job ARIMA Forecast")
plot(cpi_forecast, main = "CPI ARIMA Forecast")
plot(frr_forecast, main = "Federal Fund Rate ARIMA Forecast")

# Impulse Response for the Growth Model
imp01 <- irf(var_growth, impulse = "oil_g", response = "cpi_g", n.ahead = 36, ortho = FALSE, runs = 1000)
imp02 <- irf(var_growth, impulse = "cpi_g", response = "frr_g", n.ahead = 36, ortho = FALSE, runs = 1000)
imp03 <- irf(var_growth, impulse = "frr_g", response = "job_g", n.ahead = 36, ortho = FALSE, runs = 1000)
imp04 <- irf(var_growth, impulse = "frr_g", response = "stock_g", n.ahead = 36, ortho = FALSE, runs = 1000)

# Plot the impulse response functions
par(mfrow = c(2, 2))

plot(imp01, main = "IRF: Oil Growth -> CPI Growth")
plot(imp02, main = "IRF: CPI Growth -> Federal Fund Rate")
plot(imp03, main = "IRF: Federal Fund Rate -> Jobs Growth")
plot(imp04, main = "IRF: Federal Fund Rate -> Stock Growth")

# Repeat for the Level Model
imp01_level <- irf(var_level, impulse = "oil_ts", response = "cpi_ts", n.ahead = 36, ortho = FALSE, runs = 1000)
imp02_level <- irf(var_level, impulse = "cpi_ts", response = "frr_ts", n.ahead = 36, ortho = FALSE, runs = 1000)
imp03_level <- irf(var_level, impulse = "frr_ts", response = "job_ts", n.ahead = 36, ortho = FALSE, runs = 1000)
imp04_level <- irf(var_level, impulse = "frr_ts", response = "stock_ts", n.ahead = 36, ortho = FALSE, runs = 1000)

# Plot the impulse response functions for the level model
par(mfrow = c(2, 2))

plot(imp01_level, main = "IRF: Oil Level -> CPI Level")
plot(imp02_level, main = "IRF: CPI Level -> Federal Fund Rate")
plot(imp03_level, main = "IRF: Federal Fund Rate -> Jobs Level")
plot(imp04_level, main = "IRF: Federal Fund Rate -> Stock Level")

# Set the test period for out-of-sample data (July 2024 to August 2024)
test_start <- c(2024, 7)
test_end <- c(2024, 8)

# Extract the actual values from the full dataset for the test period
test_data00 <- window(data0, start = test_start, end = test_end)

# Forecast for the next 2 months (July 2024 to August 2024) using the VAR models
forecast_level_test <- predict(var_level, n.ahead = 2)
forecast_growth_test <- predict(var_growth, n.ahead = 2)

# Convert the forecasted growth rates back to levels using exp for log differences and direct sum for FFR
forecast_growth_level <- list()
for(i in 1:length(forecast_growth_test$fcst)){
  if (i == 5) {
    # FFR was differenced, so use cumsum without exp
    last_value <- as.numeric(tail(data00[,i], 1))  # Last known value in levels
    growth_forecast <- forecast_growth_test$fcst[[i]][, 1]  # Extract the forecasted differences for FFR
    forecast_growth_level[[i]] <- last_value + cumsum(growth_forecast)  # Simple cumulative sum for FFR
  } else {
    # Log-differenced variables, so use exp(cumsum(growth))
    last_value <- as.numeric(tail(data00[,i], 1))  # Last known value in levels
    growth_forecast <- forecast_growth_test$fcst[[i]][, 1]  # Extract the forecasted log-differenced growth rate
    forecast_growth_level[[i]] <- exp(cumsum(growth_forecast) + log(last_value))  # Convert back using exp(cumsum)
  }
}
names(forecast_growth_level) <- colnames(data00)

# Extract the actual values for the test period
actual_test <- test_data00

# Function to calculate MSLE
calculate_msle <- function(forecast, actual){
  return(mean((log(forecast + 1e-6) - log(actual + 1e-6))^2, na.rm = TRUE))  # Small constant to avoid log(0)
}

# Calculate MSLE for the VAR Level model
msle_var_level <- 0
for(i in 1:ncol(test_data00)){
  msle_var_level <- msle_var_level + calculate_msle(forecast_level_test$fcst[[i]][,1], actual_test[,i])
}
msle_var_level <- msle_var_level / ncol(test_data00)

# Calculate MSLE for the VAR Growth model (converted to level)
msle_var_growth <- 0
for(i in 1:length(forecast_growth_level)){
  msle_var_growth <- msle_var_growth + calculate_msle(forecast_growth_level[[i]], actual_test[,i])
}
msle_var_growth <- msle_var_growth / length(forecast_growth_level)

# Calculate MSLE for the ARIMA models
msle_arima <- 0
arima_forecasts <- list(oil_forecast, stock_forecast, job_forecast, cpi_forecast, frr_forecast)
for(i in 1:length(arima_forecasts)){
  msle_arima <- msle_arima + calculate_msle(arima_forecasts[[i]]$mean[1:2], actual_test[,i])
}
msle_arima <- msle_arima / length(arima_forecasts)

# Output the MSLE results
cat("MSLE for VAR Level model: ", msle_var_level, "\n")
cat("MSLE for VAR Growth model: ", msle_var_growth, "\n")
cat("MSLE for ARIMA model: ", msle_arima, "\n")

# Compare the results and select the best model
if(msle_var_level < msle_var_growth && msle_var_level < msle_arima){
  cat("VAR Level model has the lowest MSLE and is the best model.\n")
} else if(msle_var_growth < msle_var_level && msle_var_growth < msle_arima){
  cat("VAR Growth model has the lowest MSLE and is the best model.\n")
} else {
  cat("ARIMA model has the lowest MSLE and is the best model.\n")
}
