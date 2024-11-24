# VAR Models for Economic and Financial Forecasting

## Project Description
This project uses Vector Autoregression (VAR) and ARIMA models to analyze and forecast key economic and financial time series data. The analysis includes forecasting, impulse response analysis, and model performance evaluation. The models are built using data sourced from the FRED database.

---

## Objective
1. Develop and compare VAR models on raw level data and growth rate data.
2. Forecast key economic indicators, including:
   - Oil prices
   - NASDAQ stock prices
   - Nonfarm payroll jobs
   - Core Consumer Price Index (CPI)
   - Federal fund rate
3. Conduct impulse response analysis to evaluate variable interrelationships.
4. Compare the performance of VAR models against ARIMA models using Mean Squared Logarithmic Error (MSLE).

---

## Tools and Libraries
- **R Libraries**:
  - `quantmod`: Fetches time series data from FRED.
  - `vars`: Builds VAR models and conducts impulse response analysis.
  - `tseries` and `forecast`: Supports ARIMA modeling and evaluation.
  - `fpp2`: Helps with time series visualization.
  - `lmtest`: Performs hypothesis testing in regression models.
  - `readxl`: Reads Excel data.

---

## Data Sources
Data is sourced from the FRED database using the `quantmod` package:
1. **DCOILWTICO**: Oil price.
2. **NASDAQCOM**: NASDAQ stock price.
3. **PAYEMS**: Nonfarm payroll jobs.
4. **CPILFESL**: Core Consumer Price Index.
5. **DFF**: Federal fund rate.

---

## Key Steps

### 1. Data Preparation
- Subset data from February 1986 to August 2024.
- Convert daily data to monthly averages using `apply.monthly`.
- Create time series (`ts`) objects for each variable.
- Calculate growth rates for all variables except the federal fund rate:
  \[
  \text{Growth Rate} = \log\left(\frac{\text{Current Value}}{\text{Previous Value}}\right)
  \]

### 2. VAR Modeling
- Two datasets were prepared:
  - **Level Data**: Original time series values.
  - **Growth Data**: Log differences (growth rates) of the time series.
- VAR models were built for both datasets:
  - `VAR(data00)`: VAR on level data with constant and trend.
  - `VAR(data11)`: VAR on growth data with constant only.

### 3. Forecasting
- Forecasted for 12 months ahead for both level and growth models.
- Converted growth rate forecasts back to levels using:
  \[
  \text{Forecast Level} = \exp\left(\text{Cumulative Sum of Growth Rates}\right) \times \text{Last Known Value}
  \]

### 4. ARIMA Modeling
- ARIMA models were fit for each variable.
- Forecasts were generated for 12 months ahead.

### 5. Impulse Response Analysis
- Explored the dynamic relationship between variables using Impulse Response Functions (IRF).
- Analyzed responses to shocks in:
  - Oil prices on CPI.
  - CPI on federal fund rate.
  - Federal fund rate on jobs and NASDAQ growth.

### 6. Performance Evaluation
- Performance metrics were calculated using Mean Squared Logarithmic Error (MSLE):
  \[
  \text{MSLE} = \frac{1}{n} \sum \left(\log(\text{Forecast} + \epsilon) - \log(\text{Actual} + \epsilon)\right)^2
  \]
  - Compared MSLE across:
    - VAR Level Model.
    - VAR Growth Model.
    - ARIMA Models.

---

## Results
- **Forecast Accuracy**:
  - MSLE values for each model were calculated and compared.
- **Best Model**:
  - The model with the lowest MSLE was selected as the best forecasting model.

---

## Files and Scripts
- **R Script**: `var_models_forecasting.R` (this file contains the full implementation of the project).
- **Data Sources**: Automatically fetched from FRED using `quantmod`.

---

## How to Run
1. Clone this repository:
   ```bash
   git clone https://github.com/<username>/<repo_name>.git
   cd <repo_name>
