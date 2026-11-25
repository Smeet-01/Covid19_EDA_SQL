# Covid19_EDA_SQL

Exploratory Data Analysis (EDA) of global COVID-19 deaths and vaccinations data using **SQL Server (T-SQL)**, paired with a Power BI dashboard.

## Files
- `Covid19-EDA.sql`: T-SQL queries covering case fatality rates, infection rates by population, global daily totals, rolling vaccination counts (window functions, CTEs, temp tables, and views).
- `Datasets/`: Excel source datasets (`CovidDeaths.xlsx`, `CovidVaccinations.xlsx`).
- `Data_Visuals_Covid19.pbix`: Power BI report visualizing the findings.

## Usage
1. Import `Datasets/CovidDeaths.xlsx` and `Datasets/CovidVaccinations.xlsx` into SQL Server as tables `Coviddeaths` and `Covidvaccinations`.
2. Execute queries in `Covid19-EDA.sql` in SQL Server Management Studio (SSMS) or Azure Data Studio.
