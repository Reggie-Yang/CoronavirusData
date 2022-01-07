SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population, ROUND(total_deaths/total_cases, 4)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%china%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT LOCATION, Population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population)),4)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%china%'
Group by Location, Population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT LOCATION, Population, MAX(cast(total_deaths as int)) as HighestDeathCount, ROUND(MAX((total_deaths/population)),4)*100 as PercentPopulationDeath
From PortfolioProject..CovidDeath
Where continent is not null
--Where location like '%china%'
Group by Location, Population
ORDER BY HighestDeathCount desc

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount, ROUND(MAX((total_deaths/population)),4)*100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeath
Where continent is not null
Group by continent

--Global numbers


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 1,2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 1,2,3
)
Select *, MAX(RollingPeopleVaccinated/population)*100
from PopvsVac
Group by Location

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 1,2,3 

Select * from PercentPopulationVaccinated