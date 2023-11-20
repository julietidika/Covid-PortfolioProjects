


USE PortfolioProject


SELECT * FROM 
PortfolioProject..CovidDeaths

WHERE total_cases= 'NULL'


SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

---- Looking at Total Cases vs Total Deaths percentage

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
order by 1,2


select (total_cases/total_cases)
from PortfolioProject..CovidDeaths


--Looking at Total Cases vs Total Deaths percentage
--shows likelihood of dying if you contract covid in america
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)
FROM  PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, new_cases, total_deaths, (total_deaths/population)*100
as Deathpercentage
FROM  PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
SELECT Location, population, MAX(total_cases) as Highestinfectioncount, Max((total_deaths/population))*100
as Percentpopulationinfected
FROM  PortfolioProject..CovidDeaths
Group by location, population 
--where location like '%states%'
order by Percentpopulationinfected desc

--Showing the countries with Highest death count per popualtion

SELECT Location, population, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
Group by location, population 
--where continent is not null
order by Totaldeathcount, population desc

-- Breaking Things Down By Continent

SELECT Location , MAX(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like '%state%'
Group by location
order by Totaldeathcount desc

--Global Numbers

Create view Globalcovidcases as
SELECT date, SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as total_Deaths,
sum(cast(new_deaths as int))/SUM(New_cases)*100 as Deathpercentage
FROM  PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
--order by 1,2

---Joining the covidDeaths and CovidVaccinations Table together
Select * From
PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at Total population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,dea.date)
As RollingpeopleVaccinated
--, (Rollingpeople Vaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

DROP Table if exists #percentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

insert into #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location,dea.date)
As RollingpeopleVaccinated
-- (Rollingpeople Vaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
order by 2,3
select *, (RollingpeopleVaccinated/population)*100
from #percentpopulationVaccinated


--CREATE VIEW TO STORE DATA FOR LATER VISUALISATION

