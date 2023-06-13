 SELECT * 
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM [Data Exploration]..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL

ORDER BY 1,2

-- Looking at total_cases vs total_deaths 
-- Shows percentage of death in INDIA
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM [Data Exploration]..CovidDeaths
WHERE location LIKE '%India%'
and continent IS NOT NULL
ORDER BY 1,2

-- Looking at total_cases vs population
-- Shows percentage of people who got covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at highest infection rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with highest Death Count
SELECT location,population,MAX(CAST(total_deaths AS int)) as HighestDeathCount
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeathCount DESC

-- Looking at Continents with highest Death Count
SELECT continent,MAX(CAST(total_deaths AS int)) as HighestDeathCount
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Looking at numbers globally
SELECT date,SUM(new_cases) AS total_cases,
			SUM(CAST(new_deaths AS INT)) as total_deaths, 
			SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases vs total deaths overall(Overall death percentage due to covid from Feb 2020 to April 2021)
SELECT SUM(new_cases) AS total_cases,
			SUM(CAST(new_deaths AS INT)) as total_deaths, 
			SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM [Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Joining both tables for further analysis
SELECT * 
FROM [Data Exploration]..CovidDeaths AS D
JOIN [Data Exploration]..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date

-- Looking at total number of people vaccinated
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations
FROM [Data Exploration]..CovidDeaths AS D
JOIN [Data Exploration]..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

-- Total vaccincation using Rolling sum
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS Total_vaccinations
FROM [Data Exploration]..CovidDeaths AS D
JOIN [Data Exploration]..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE
WITH PopVSVacc (continent,location,date,population,new_vaccinations, Total_vaccinations)
AS  
(
	SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
	SUM(CONVERT(int,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS Total_vaccinations
	FROM [Data Exploration]..CovidDeaths AS D
	JOIN [Data Exploration]..CovidVaccinations AS V
		ON D.location = V.location
		AND D.date = V.date
	WHERE D.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *, (Total_vaccinations/population)*100 AS PercentVaccinated
FROM PopVSVacc


-- Creating another table for people vaccinated


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS Total_vaccinations
FROM [Data Exploration]..CovidDeaths AS D
JOIN [Data Exploration]..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Total_Vaccinations/Population)*100 as PercentVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store Data for Visualization later

CREATE VIEW PercentPeopleVaccinated AS
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT(int,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS Total_vaccinations
FROM [Data Exploration]..CovidDeaths AS D
JOIN [Data Exploration]..CovidVaccinations AS V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPeopleVaccinated
