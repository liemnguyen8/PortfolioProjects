SELECT * 
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4 

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--SELECT DATA WE WILL BE Using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order by 1,2


--Looking at Total Cases vs Total Deaths 
--Shows likely hood of dying if you contracted covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2 

--Looking at Total Cases Vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentofpopulationinfected
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2 


--Looking at countries with the highest infection rate compared to population
SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as Percentagepopulationinfected
FROM PortfolioProject..CovidDeaths$
Group by Location, population
Order by percentagepopulationinfected desc 




-- Showing Countries with Highest Death Count per Population 
SELECT location, MAX(cast(Total_deaths as bigint)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathCount desc 

--Showing the continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as bigint)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc 

-- Global Numbers per day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
GROUP BY date
order by 1,2 

--Global Numbers 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
order by 1,2 

-- Looking at Total Population vs Vaccinaton

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.Location ORDER by dea.location,dea.date) AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
and dea.continent is not null
Order by 2,3 

--USE CTE 

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.Location ORDER by dea.location,dea.date) AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
and dea.continent is not null

)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(225),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.Location ORDER by dea.location,dea.date) AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
and dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.Location ORDER by dea.location,dea.date) AS RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
and dea.continent is not null

