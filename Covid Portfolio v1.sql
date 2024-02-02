SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (cast(total_deaths as decimal)/cast(total_cases as decimal))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (cast(total_cases as decimal)/cast(population as decimal))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
WHERE continent is not null
ORDER by 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfeccftonCount, MAX((cast(total_cases as decimal)/cast(population as decimal)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%state%'
GROUP BY location, population
ORDER by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%state%'
GROUP BY location
ORDER by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the hightest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%state%'
GROUP BY continent
ORDER by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--GROUP BY date
ORDER by 1,2


-- Looking at Total population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2, 3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE 
DROP TABLE if exists ##PercentPopulationVaccinated
create table ##PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into ##PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM ##PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated