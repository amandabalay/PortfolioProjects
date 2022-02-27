SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs population
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS case_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at what countries have highest cases compared to population
SELECT Location, MAX(total_cases) AS highest_case_count, population, MAX((total_cases/population)) * 100 AS highest_case_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY highest_case_percentage DESC

-- Showing the countries with the highest death count per population
-- Need to cast total_deaths as an integer due to data type issue
-- Need to specify where continent is not null to get rid of locations that are not countries
SELECT Location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY highest_death_count DESC

-- Breaking things down by continent, use WHERE continent is null
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count DESC

-- Breaking things down globally
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Joining covid deaths dataset with vaccinations dataset
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at how vaccinations affected total cases and deaths
SELECT dea.date, dea.continent, dea.location, dea.total_cases, dea.total_deaths, vac.people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
	AND dea.continent = vac.continent
--WHERE vac.new_vaccinations is not NULL
WHERE dea.continent is not NULL
ORDER BY 3,1

-- Looking at how vaccinations affected hospitalizations in the US
SELECT dea.date, dea.location, vac.people_vaccinated, vac.people_fully_vaccinated 
, FORMAT((vac.people_vaccinated/dea.population)*100, 'N3') AS percent_population_vaccinated
, FORMAT((vac.people_fully_vaccinated/dea.population)*100, 'N3') AS percent_population_fully_vaccinated
, FORMAT((dea.total_cases/dea.population)*100, 'N3') AS percent_population_infected
, dea.hosp_patients, dea.icu_patients
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.hosp_patients is not NULL
AND dea.continent is not NULL
AND dea.location = 'United States'

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE to incorporate aggregate on rolling vaccinations
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_vaccinations/population)*100 AS percent_vaccinated
FROM PopvsVac

-- Temp table, use drop table to avoid errors when making alterations
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/dea.population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (rolling_vaccinations/population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated

-- Creating views to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW HighestCases AS
SELECT Location, MAX(total_cases) AS highest_case_count, population, MAX((total_cases/population)) * 100 AS highest_case_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population

CREATE VIEW USDeathPercentage AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'

CREATE VIEW VaccinationsEffect2 AS
SELECT dea.date, dea.location, dea.continent, dea.total_cases, dea.total_deaths, vac.people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
	AND dea.continent = vac.continent
WHERE dea.continent is not NULL

CREATE VIEW VaccinationEffectUnitedStates AS
SELECT dea.date, dea.location, vac.people_vaccinated, vac.people_fully_vaccinated 
, FORMAT((vac.people_vaccinated/dea.population)*100, 'N3') AS percent_population_vaccinated
, FORMAT((vac.people_fully_vaccinated/dea.population)*100, 'N3') AS percent_population_fully_vaccinated
, FORMAT((dea.total_cases/dea.population)*100, 'N3') AS percent_population_infected
, dea.hosp_patients, dea.icu_patients
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.hosp_patients is not NULL
AND dea.continent is not NULL
AND dea.location = 'United States'