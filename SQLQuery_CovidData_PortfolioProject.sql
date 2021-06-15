SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

/* 
 Let's start!
*/

-- Selct Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you caught by Covid 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage 
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Thailand%'
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

SELECT location, date, Population, total_cases, (total_deaths/Population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Thailand%'
ORDER BY 1, 2

-- Looking at Countries with Higest Infection Rate compared to Population 

SELECT location, Population, 
MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Thailand%'
Group BY Population, location
ORDER BY PercentPopulationInfected desc

-- Showing Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotolDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent is NOT NULL
Group BY location
ORDER BY TotolDeathCount desc

-- Break down by Continent
-- Continent with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotolDeathCount
FROM [PortfolioProject].dbo.CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent is NOT NULL
Group BY continent
ORDER BY TotolDeathCount desc


-- Global numbers

SELECT SUM(new_cases) as ToatalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent is NOT NULL
--Group BY date 
ORDER BY 1,2


-- Total Population  VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- USE CTE 

WITH PopsVSVacs (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) as RollingPeopleVaccinated 
	FROM PortfolioProject.dbo.CovidDeaths as dea
	JOIN PortfolioProject..CovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	)
SELECT*, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopsVSVacs

-- TEMP TABLE 

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--INSERT INTO #PercentPopulationVaccinated
--	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--		SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) as RollingPeopleVaccinated 
--	FROM PortfolioProject.dbo.CovidDeaths as dea
--	JOIN PortfolioProject..CovidVaccinations as vac
--		ON dea.location = vac.location
--		AND dea.date = vac.date
--	WHERE dea.continent is NOT NULL

--SELECT*, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
--FROM #PercentPopulationVaccinated

--Creating View to store data for later Viz

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) as RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated
