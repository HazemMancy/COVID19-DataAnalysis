/*

Queries used for Tableau Project

We are gonna create a view of every single query and export it to Tableau Desktop to perform Data Visualization

*/



-- 1. Total cases, deaths, and deaths percentage of the world till 09/03/2022

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
WHERE continent is not null 
--Group BY date
ORDER BY 1,2;


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
WHERE location = 'World'
--Group BY date
ORDER BY 1,2;


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
Group BY location
ORDER BY TotalDeathCount DESC;


--DROP VIEW IF EXISTS Total_Cases_and_Deaths
CREATE VIEW Total_Cases_and_Deaths AS (
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM covid_db..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
Group BY location);


-- 3. Infection count per population till 09/03/2022

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
Group BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--DROP VIEW IF EXISTS PercentPopulationInfected
CREATE VIEW PercentPopulationInfected AS (
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_db..CovidDeaths
Group BY Location, Population);

-- 4. Daily infection count and percentage per population for all countries

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
Group BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;


--DROP VIEW IF EXISTS DailyPercentPopulationInfected
CREATE VIEW DailyPercentPopulationInfected AS (
SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_db..CovidDeaths
Group BY Location, Population, date);


-- 5. Death count per population till 09/03/2022

SELECT Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
Group BY Location, Population
ORDER BY PercentPopulationDeath DESC;

--DROP VIEW IF EXISTS PercentPopulationDeath
CREATE VIEW PercentPopulationDeath AS (
SELECT Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM covid_db..CovidDeaths
Group BY Location, Population);

-- 6. Daily death count and percentage per population for all countries

SELECT Location, Population,date, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM covid_db..CovidDeaths
--WHERE location like '%Egypt%'
Group BY Location, Population, date
ORDER BY PercentPopulationDeath DESC;


--DROP VIEW IF EXISTS DailyPercentPopulationDeath
CREATE VIEW DailyPercentPopulationDeath AS (
SELECT Location, Population,date, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeath
FROM covid_db..CovidDeaths
Group BY Location, Population, date);


-- 7. Rolling People Vaccinated by date for all countries

SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(CAST(vac.total_vaccinations AS float)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_db..CovidDeaths dea
Join covid_db..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
group BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3;

DROP VIEW IF EXISTS RollingPeopleVaccinated
CREATE VIEW RollingPeopleVaccinated AS (
SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(CAST(vac.total_vaccinations AS float)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_db..CovidDeaths dea
Join covid_db..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
group BY dea.continent, dea.location, dea.date, dea.population);


-- 8. Total vaccinations by 09/03/2022

SELECT dea.continent, dea.location, dea.population
, SUM(CAST(vac.new_vaccinations AS float)) as TotalVaccinations
--, (RollingPeopleVaccinated/population)*100
FROM covid_db..CovidDeaths dea
Join covid_db..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
group BY dea.continent, dea.location, dea.population
ORDER BY 1, 2, 3 DESC;


--DROP VIEW IF EXISTS TotalVaccinations
CREATE VIEW TotalVaccinations AS (
SELECT dea.continent, dea.location, dea.population
, SUM(CAST(vac.new_vaccinations AS float)) as TotalVaccinations
--, (RollingPeopleVaccinated/population)*100
FROM covid_db..CovidDeaths dea
Join covid_db..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
group BY dea.continent, dea.location, dea.population);

-- Now we can connect these views to Tableau and start Visualization