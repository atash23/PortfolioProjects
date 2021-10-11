SELECT *
FROM [Portfolio Project]..CovidDeaths
order by 3, 4

--Selecting data that we will use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_cases FLOAT
GO

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_deaths FLOAT
GO

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_per_cases
FROM [Portfolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what precentage of population get Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentInfected
FROM [Portfolio Project]..CovidDeaths
Where Location like '%states%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentInfected
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%states%'
Group by Location, population
order by PercentInfected DESC


--Showing Countries with Highest Death Count
SELECT Location, MAX(total_deaths) AS Total_deaths
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
Group by Location
order by Total_deaths DESC

--Showing Continents with Highest Death Count
SELECT location, MAX(total_deaths) AS Total_deaths
FROM [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
order by Total_deaths DESC


-- GLOBAL NUMBERS
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN new_cases FLOAT
GO

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN new_deaths FLOAT
GO


SELECT date, SUM(new_cases) as Day_total_cases, SUM(new_deaths) as Day_total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Day_DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccination

ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN new_vaccinations INT
GO


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by
	dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CT

With PopvssVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by
	dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (cast(RollingPeopleVaccinated as float)/cast(population as float))*100
From PopvssVac

-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by
	dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (cast(RollingPeopleVaccinated as float)/cast(population as float))*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by
	dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated1
