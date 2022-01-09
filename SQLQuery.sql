SELECT *
  FROM PortfolioProject..covid_deaths$


--SELECT *
--  FROM [PortfolioProject].[dbo].[covid_vaccinations$]


SELECT *
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
order by 3, 4;


-- SELECT *
-- FROM `moonlit-helper-329414.Covid.vaccines`
-- order by 3, 4

--Select Data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
order by 1,2;


-- Looking at total cases / total deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
order by 1,2;


-- Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percent
FROM PortfolioProject..covid_deaths$
WHERE location = 'Germany' AND continent is not null
order by 1,2;


-- Countries with highest Infection rate

SELECT location, population, max(total_cases) Max_Cases, ROUND(max(total_cases/population)*100,2) Cases_Percent
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
GROUP BY location, population
order by 4 desc;


-- Countries with highest Death rate / Population

SELECT location, population, max(CAST(total_deaths as INT)) Max_Deaths, ROUND(max(CAST(total_deaths as INT)/population)*100,5) Death_Percent
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
GROUP BY location, population
order by 3 desc;


-- Death by Continent (excluding incomes, EU)

SELECT location, population, max(CAST(total_deaths as INT)) Max_Deaths, ROUND(max(CAST(total_deaths as INT)/population)*100,5) Death_Percent
FROM PortfolioProject..covid_deaths$
WHERE continent is null AND location not like '%income%' AND location not like '%Union%'
GROUP BY location, population
order by 2 desc;


-- Global numbers (new cases, total cases, new deaths, total deaths) using CAST & CONVERT

SELECT 
    date, 
    sum(population) World_Population, 
    sum(new_cases) New_cases, 
    sum(total_cases) Total_cases,
    sum(CAST(new_deaths as INT)) New_Deaths,
    sum(CAST(total_deaths as INT)) Total_Deaths, 
    ROUND(sum(CAST(total_deaths as INT))/sum(total_cases)*100,5) Death_Percent
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
GROUP BY date
order by 1 desc;


-- Total Popularion / Vaccinations using JOIN & CONVERT

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, CONVERT(int, vaccines.new_vaccinations) new_vaccines
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vaccines
    ON deaths.location = vaccines.location 
    AND deaths.date = vaccines.date
order by 2,3;


-- Total Popularion / Vaccinations using PARTITION BY & OVER

SELECT
	deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
	sum(CONVERT(bigint,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, CONVERT(DATETIME,deaths.date)) Rolling_new_vaccines
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vaccines
    ON deaths.location = vaccines.location 
    AND deaths.date = vaccines.date
WHERE deaths.continent is not null 
order by 2,3;


-- Total Popularion / Vaccinations / % with CTE

WITH Pops_vaccinated (Continent, Location, Date, Population, New_Vaccinations, Rolling_new_vaccines)
AS
(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, SUM(CONVERT(bigint,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, CONVERT(DATETIME,deaths.date)) Rolling_new_vaccines
	FROM PortfolioProject..covid_deaths$ deaths
	JOIN PortfolioProject..covid_vaccinations$ vaccines
		ON deaths.location = vaccines.location 
		AND deaths.date = vaccines.date
	WHERE deaths.continent is not null AND deaths.location = 'Germany'
	--order by 2,3 
)
SELECT *, (Rolling_new_vaccines/population*100) Percent_Vaccinated
FROM Pops_vaccinated;


-- Total Popularion / Vaccinations / % with TempTable using DROP TBALE IF EXISTS

DROP TABLE IF EXISTS PortfolioProject..Percent_Pops_Vaccinated;
CREATE TABLE PortfolioProject..Percent_Pops_Vaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccines numeric,
    Rolling_new_vaccines numeric
);


INSERT INTO PortfolioProject..Percent_Pops_Vaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, SUM(CONVERT(bigint,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, CONVERT(DATETIME,deaths.date)) Rolling_new_vaccines
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vaccines
    ON deaths.location = vaccines.location 
    AND deaths.date = vaccines.date
WHERE deaths.continent is not null 
order by 2,3; 


SELECT *
FROM PortfolioProject..Percent_Pops_Vaccinated;


-- View for Data storage

CREATE VIEW Percent_Pops_Vaccinated2 AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, SUM(CONVERT(bigint,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, CONVERT(DATETIME,deaths.date)) Rolling_new_vaccines
FROM PortfolioProject..covid_deaths$ deaths
JOIN PortfolioProject..covid_vaccinations$ vaccines
    ON deaths.location = vaccines.location 
    AND deaths.date = vaccines.date
WHERE deaths.continent is not null 
--order by 2,3; 
