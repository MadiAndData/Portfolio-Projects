-- Selecting to ensure that both tables imported correctly
SELECT *
FROM 
	ProjectPortfolio..CovidDeaths
WHERE 
	continent IS NOT NULL;

SELECT *
FROM 
	ProjectPortfolio..CovidVaccinations;


-- Selecting data that we are working with
SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases VS. Total Deaths
-- Shows likelihood of dying from contracting COVID-19 in a specific country
SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM 
	ProjectPortfolio..CovidDeaths
WHERE
	Location like '%United States%'
	and continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases VS. Population
-- Shows what percentage of the population contracted COVID-19
SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS Population_Infected
FROM 
	ProjectPortfolio..CovidDeaths
ORDER BY 1,2;


-- Countries with the highest Infection Rate compared to Population
SELECT
	location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected
FROM 
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	Location, population
ORDER BY 
	Population_Infected DESC;

SELECT
	location, population, date, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected
FROM 
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	Location, population, date
ORDER BY 
	Population_Infected DESC;

	
-- Countries with highest Death Count per Population
SELECT
	Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent is not null 
GROUP BY
	Location
ORDER BY Total_Death_Count DESC;


-- CONTINENTS
-- Contintents with the highest Death Count per Population
SELECT
	continent, MAX(total_deaths) AS Total_Death_Count
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	Total_Death_Count DESC;


-- GLOBAL NUMBERS
SELECT
	date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY 
	date
ORDER BY 1,2;

--
SELECT
	SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 1,2;

--
SELECT
	location, SUM(new_deaths) as Total_Death_Count
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NULL 
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY 
	Total_Death_Count DESC;


-- Total Population VS. Total Vaccinations
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE
	death.continent IS NOT NULL
ORDER BY 2,3;


--- CREATE CTE
WITH PopVSVacc (continent, location, date, population, new_vaccinations, Rolling_Vaccinations)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE
	death.continent IS NOT NULL
)
SELECT 
	*, ((Rolling_Vaccinations)/(CAST(population AS FLOAT)))*100
FROM PopVSVacc;


-- TEMP TABLE
DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE
	death.continent IS NOT NULL;

SELECT 
	*, ((Rolling_Vaccinations)/(CAST(population AS FLOAT)))*100
FROM #Percent_Population_Vaccinated;


-- Creating View for Visulatizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
	, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinations
FROM ProjectPortfolio..CovidDeaths death
JOIN ProjectPortfolio..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE
	death.continent IS NOT NULL;

CREATE VIEW Countries_Death_Count AS
SELECT
	Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent is not null 
GROUP BY
	Location;

CREATE VIEW Continents_Death_Count AS
SELECT
	continent, MAX(total_deaths) AS Total_Death_Count
FROM
	ProjectPortfolio..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY 
	continent;
