-- Retrieve all columns and explore data
SELECT *
FROM covid_db..covid_data;


-- Split data into 2 tables: CovidDeaths and CovidVaccinations
-- Create CovidDeaths table
SELECT
	iso_code,
	continent,
	location,
	date,
	population,
	total_cases,
	new_cases,
	new_cases_smoothed,
	total_deaths,
	new_deaths,
	new_deaths_smoothed,
	total_cases_per_million,
	new_cases_smoothed_per_million,
	total_deaths_per_million,
	new_deaths_per_million,
	new_deaths_smoothed_per_million,
	reproduction_rate,
	icu_patients,
	icu_patients_per_million,
	hosp_patients,
	hosp_patients_per_million,
	weekly_icu_admissions,
	weekly_icu_admissions_per_million,
	weekly_hosp_admissions,
	weekly_hosp_admissions_per_million
INTO CovidDeaths
FROM covid_db..covid_data;

SELECT *
FROM covid_db..CovidDeaths
ORDER BY 3, 4;

-- Create CovidVaccinations table
SELECT
	iso_code,
	continent,
	location,
	date,
	new_tests,
	total_tests,
	total_tests_per_thousand,
	new_tests_per_thousand,
	new_tests_smoothed,
	new_tests_smoothed_per_thousand,
	positive_rate,
	tests_per_case,
	tests_units,
	total_vaccinations,
	people_vaccinated,
	people_fully_vaccinated,
	total_boosters,
	new_vaccinations,
	new_vaccinations_smoothed,
	total_vaccinations_per_hundred,
	people_vaccinated_per_hundred,
	people_fully_vaccinated_per_hundred,
	total_boosters_per_hundred,
	new_vaccinations_smoothed_per_million,
	new_people_vaccinated_smoothed,
	new_people_vaccinated_smoothed_per_hundred,
	stringency_index,
	population,
	population_density,
	median_age,
	aged_65_older,
	aged_70_older,
	gdp_per_capita,
	extreme_poverty,
	cardiovasc_death_rate,
	diabetes_prevalence,
	female_smokers,
	male_smokers,
	handwashing_facilities,
	hospital_beds_per_thousand,
	life_expectancy,
	human_development_index,
	excess_mortality_cumulative_absolute,
	excess_mortality_cumulative,
	excess_mortality,
	excess_mortality_cumulative_per_million
INTO CovidVaccinations
FROM covid_db..covid_data;

SELECT *
FROM covid_db..CovidDeaths
ORDER BY 3, 4;


SELECT *
FROM covid_db..CovidVaccinations
ORDER BY 3, 4;

--Select only data we are gonna use
SELECT iso_code, continent, location, date, population, total_cases, total_deaths
FROM covid_db..CovidDeaths
ORDER BY location, date;

--Total cases vs total deaths for each country
SELECT iso_code, continent, location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM covid_db..CovidDeaths
ORDER BY location, date;

-- Update table to set every missing value in total_cases and total_deaths columns to NULL to avoid dividing by zero error
UPDATE covid_db..CovidDeaths
SET total_cases = NULL
WHERE total_cases = '';

UPDATE covid_db..CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = '';

-- Alter table to permenantly cast total_cases and total_deaths values as float to easily perform calculations
ALTER TABLE covid_db..CovidDeaths
ALTER COLUMN total_cases float;

ALTER TABLE covid_db..CovidDeaths
ALTER COLUMN total_deaths float;

--total_cases vs total_deaths for Egypt
SELECT iso_code, continent, location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM covid_db..CovidDeaths
WHERE location = 'Egypt'
ORDER BY location, date;

-- Update table to set every missing value in population column to NULL to avoid dividing by zero error
UPDATE covid_db..CovidDeaths
SET population = NULL
WHERE population = '';

--total_cases vs population for each country to show what percentage of population got infected
SELECT iso_code, continent, location, date, total_cases, population, (total_cases / population)*100 AS infection_percentage
FROM covid_db..CovidDeaths
ORDER BY location, date;

--total_cases vs population for Egypt to show what percentage of population got infected
SELECT iso_code, continent, location, date, total_cases, population, (total_cases / population)*100 AS infection_percentage
FROM covid_db..CovidDeaths
WHERE location = 'Egypt'
ORDER BY location, date;

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS total_cases_count, MAX((total_cases / population))*100 AS infection_rate_over_population
FROM covid_db..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate_over_population DESC;

-- Countries with highest death rate compared to population
SELECT location, population, MAX(total_deaths) AS total_deaths_count, MAX((total_deaths / population))*100 AS death_rate_over_population
FROM covid_db..CovidDeaths
GROUP BY location, population
ORDER BY death_rate_over_population DESC;


-- By exploring the whole data, we find that there are null continents and the continent is enterd in location column as a country which give us inaccurate calculation when trying to get total deaths per continent for example
-- Update table to set every missing value in continent column to NULL to easily retrieve if condition continent is null
UPDATE covid_db..CovidDeaths
SET continent = NULL
WHERE continent = '';

--SELECT *
--FROM covid_db..CovidDeaths
--WHERE continent IS NULL;
---- It looks great :)

-- Global Numbers
-- Now let's retrive total death counts per continent where continent is NOT NULL
SELECT continent, MAX(total_cases) AS total_cases_count, MAX(total_deaths) AS total_death_count
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases_count DESC;


ALTER TABLE covid_db..CovidDeaths
ALTER COLUMN new_cases float;

ALTER TABLE covid_db..CovidDeaths
ALTER COLUMN new_deaths float;

UPDATE covid_db..CovidDeaths
SET new_cases = NULL
WHERE new_cases = '';

UPDATE covid_db..CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = '';


-- Daily new_cases, new_deaths, and new_deaths per new_cases percentage over the world
SELECT
	date,
	SUM(new_cases) AS total_new_cases,
	SUM(new_deaths) AS total_new_deaths,
	(SUM(new_deaths) / SUM(new_cases))*100 AS deaths_percentage
FROM covid_db..CovidDeaths
GROUP BY date
ORDER BY date;


-- Join tables together
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_then
FROM covid_db..CovidDeaths dea
JOIN covid_db..CovidVaccinations vac
	ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
ORDER BY location, date;


UPDATE covid_db..CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

ALTER TABLE covid_db..CovidVaccinations
ALTER COLUMN new_vaccinations float;


-- Population vs vaccinations
WITH PopVac (continent, location, date, population, new_vaccinations, total_vaccinations_by_then) AS
	(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_then
FROM covid_db..CovidDeaths dea
JOIN covid_db..CovidVaccinations vac
	ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL)
SELECT *, (total_vaccinations_by_then/population)*100 AS total_vaccinations_over_population
FROM PopVac;

-- Create temp table of percent population vaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population float,
	new_vaccinations float,
	total_vaccinations_by_then float);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_then
FROM covid_db..CovidDeaths dea
JOIN covid_db..CovidVaccinations vac
	ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date];


-- Now return total_vaccinations_over_population calculated from temp table just created
SELECT *, (total_vaccinations_by_then/population)*100 AS total_vaccinations_over_population
FROM #PercentPopulationVaccinated
ORDER BY 2, 3;

-- Temp tables are available in one active session
-- We can create views instead to use them later for visualizations

CREATE VIEW PercentPopulationVaccinated AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_then
FROM covid_db..CovidDeaths dea
JOIN covid_db..CovidVaccinations vac
	ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL);

-- Return
SELECT *, (total_vaccinations_by_then/population)*100 AS total_vaccinations_over_population
FROM PercentPopulationVaccinated
ORDER BY 2, 3;


-- Or create another table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_by_then
INTO PercentPopVaccinated
FROM covid_db..CovidDeaths dea
JOIN covid_db..CovidVaccinations vac
	ON dea.[location] = vac.[location]
AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL;

-- Return
SELECT *, (total_vaccinations_by_then/population)*100 AS total_vaccinations_over_population
FROM PercentPopVaccinated
ORDER BY 2, 3;
