/* 
Covid 19 Data Exploration

Skills used: Join's, CTE's, Temp Tables, Window Functions, Creating View, Converting Data Types, Aggregate Functions

*/


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4




-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2




-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
-- Analysis: As of the latest date, the death percentage in the Philippines is calculated to be approximately 1.61%, indicating a relatively lower percentage compared to earlier periods, such as 2020 when the percentage was notably higher.

SELECT location, date, total_cases, total_deaths, CAST((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DECIMAL(10, 3)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ph%' 
AND continent IS NOT NULL
ORDER BY 1, 2 DESC;




-- Total Cases vs Population
-- Calculates the percentage of population infected with Covid
-- Analysis: As of 2023-05-24, approximately 3.57% of the population in the Philippines(in millions) has been infected with Covid.

SELECT location, date, total_cases, population, CAST((CAST(total_cases AS FLOAT) / population) * 100 AS DECIMAL(10, 7)) AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ph%' 
AND continent IS NOT NULL
ORDER BY 1, 2 DESC;




-- Countries with Highest Infection Rate compared to Population
-- Analysis: The country with the highest infection rate by percentage is Cyprus, with about 73.75% of its population infected. This high infection rate is not surprising considering the size of the population.

SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / population))*100 AS CountryInfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population
ORDER BY CountryInfectedPopulationPercentage DESC;




-- Countries with Highest Death Count per Population
-- Analysis: The top 5 countries with the highest death count per populations are United States, Brazel, India, Russia, and Mexico. This analysis provides a list of countries with their respective death counts. It allows for a comparison of the severity of the COVID-19 impact across different nations.

SELECT location, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;




-- Breaking things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;




-- Global Numbers
-- Analysis: Gives an overview of the overall COVID-19 situation globally, providing the total number of cases and deaths, as well as the death percentage.

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(NULLIF(new_deaths, 0)) / SUM(NULLIF(new_cases, 0)) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1, 2;




-- Daily COVID-19 Trends
-- Analysis: Examines the daily trends of COVID-19 cases and deaths worldwide. It provides insights into the total cases, total deaths, and the death percentage on each date.

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(NULLIF(new_deaths, 0)) / SUM(NULLIF(new_cases, 0)) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;




-- Total Population vs Vaccinations
-- Join 2 Tables

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Analysis: Observe the cumulative number of new vaccinations over time for each location. It provides insights into the progress of COVID-19 vaccination efforts in different regions.

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Another way of Converting Data Types
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;




-- Using CTE to perform Calculation on Partition By in previous query
-- Analysis: This information can be valuable in tracking the progress of vaccination efforts and assessing the impact of vaccinations on different locations.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
( 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentage
FROM PopvsVac


-- Using Temp Tables to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentage
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

-- View Total Cases vs Total Deaths
CREATE VIEW TotalCasesvsTotalDeaths AS
SELECT location, date, total_cases, total_deaths, CAST((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DECIMAL(10, 3)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ph%' 
AND continent IS NOT NULL
--ORDER BY 1, 2 DESC;

SELECT *
FROM TotalCasesvsTotalDeaths


-- View Total Cases vs Population
CREATE VIEW TotalCasesvsPopulation AS
SELECT location, date, total_cases, population, CAST((CAST(total_cases AS FLOAT) / population) * 100 AS DECIMAL(10, 7)) AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ph%' 
AND continent IS NOT NULL
--ORDER BY 1, 2 DESC;

SELECT *
FROM TotalCasesvsPopulation


-- View Countries with Highest Infection Rate compared to Population
CREATE VIEW CountriesHIR AS
SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / population))*100 AS CountryInfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population
--ORDER BY CountryInfectedPopulationPercentage DESC;

SELECT *
FROM CountriesHIR


-- View Countries with Highest Death Count per Population
CREATE VIEW CountriesHDC AS
SELECT location, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC;

SELECT *
FROM CountriesHDC


-- View Showing contintents with the highest death count per population
CREATE VIEW ContinentHDC AS
SELECT continent, MAX(Cast(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC;

SELECT *
FROM ContinentHDC


-- View Total Population vs Vaccinations
CREATE VIEW TotalPopulationvsVaccinations AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;

SELECT *
FROM TotalPopulationvsVaccinations


-- View for PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
