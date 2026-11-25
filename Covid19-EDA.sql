---- Basic Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


---- Total Cases vs Total Deaths in India
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS Death_Percentage
FROM Coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1, 2;


---- Total Cases vs Population in India
SELECT
    location,
    date,
    total_cases,
    population,
    (CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS Infected_Population_Percent
FROM Coviddeaths
WHERE continent IS NOT NULL
  AND location LIKE '%India%'
ORDER BY 1, 2;


---- Countries with the highest Infected Population to General Population Ratio
SELECT
    location,
    population,
    MAX(total_cases) AS Infected_Population,
    MAX(CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS Infected_Population_Percent
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_Population_Percent DESC;


---- Countries with Highest Death Count
SELECT
    location,
    population,
    MAX(CAST(total_deaths AS BIGINT)) AS Total_Death_Count
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count DESC;


---- Countries with Highest Death Percentage (relative to cases)
SELECT
    location,
    MAX(total_cases) AS Total_Cases,
    MAX(CAST(total_deaths AS BIGINT)) AS Total_Death_Count,
    (CAST(MAX(CAST(total_deaths AS BIGINT)) AS FLOAT) / NULLIF(MAX(total_cases), 0)) * 100 AS Death_Percentage
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_Percentage DESC;


---- Total Deaths vs Population
SELECT
    location,
    population,
    MAX(CAST(total_deaths AS BIGINT)) AS Total_Death_Count,
    MAX(CAST(total_deaths AS FLOAT) / NULLIF(population, 0)) * 100 AS Death_Rate
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_Rate DESC;


---- Global Numbers
SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
    (CAST(SUM(CAST(new_deaths AS BIGINT)) AS FLOAT) / NULLIF(SUM(new_cases), 0)) * 100 AS Death_Percentage
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


---- Comparing Cases and Vaccinations
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    D.new_cases,
    V.new_vaccinations
FROM Coviddeaths AS D
JOIN Covidvaccinations AS V
    ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY D.location, D.date;


---- Vaccine Distribution in countries
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    D.new_cases,
    V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location ORDER BY D.date
    ) AS Rolling_Vaccinations_distributed
FROM Coviddeaths AS D
JOIN Covidvaccinations AS V
    ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY D.location, D.date;


---- CTE
WITH PopVsVac (continent, location, date, population, new_cases, new_vaccinations, Rolling_Vaccinations_distributed) AS (
    SELECT
        D.continent,
        D.location,
        D.date,
        D.population,
        D.new_cases,
        V.new_vaccinations,
        SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY D.location ORDER BY D.date
        ) AS Rolling_Vaccinations_distributed
    FROM Coviddeaths AS D
    JOIN Covidvaccinations AS V
        ON D.location = V.location AND D.date = V.date
    WHERE D.continent IS NOT NULL
)
SELECT
    *,
    (CAST(Rolling_Vaccinations_distributed AS FLOAT) / NULLIF(population, 0)) * 100 AS Vax_distributed_per_100_pops
FROM PopVsVac;


---- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccination NUMERIC,
    Rolling_Vaccinations_distributed NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location ORDER BY D.date
    ) AS Rolling_Vaccinations_distributed
FROM Coviddeaths AS D
JOIN Covidvaccinations AS V
    ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL;

SELECT
    *,
    (CAST(Rolling_Vaccinations_distributed AS FLOAT) / NULLIF(population, 0)) * 100 AS Vax_distributed_per_100_pops
FROM #PercentPopulationVaccinated;


---- Creating a view
CREATE VIEW Vax_distributed_per_100_pops AS
SELECT
    D.continent,
    D.location,
    D.date,
    D.population,
    V.new_vaccinations,
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location ORDER BY D.date
    ) AS Rolling_Vaccinations_distributed
FROM Coviddeaths AS D
JOIN Covidvaccinations AS V
    ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL;
