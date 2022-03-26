select *
from PortfolioProject01..CovidDeaths
order by 3,4

--select *
--from PortfolioProject01..CovidVacc
--order by 3,4

-- Select Data that i am going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject01..CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths in morocco
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths
where location like '%morocco%'
order by 1,2

-- looking at Total Cases Vs Population
select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfect
from PortfolioProject01..CovidDeaths
where location like '%morocco%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, MAX(total_cases) as HighestInfectionCount , population, MAX((total_cases/population))*100 as PercentPopulationInfect
from PortfolioProject01..CovidDeaths
--where location like '%morocco%'
Group by location, population
order by PercentPopulationInfect desc

-- Showing countries with highest death count per population

select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject01..CovidDeaths
--where location like '%morocco%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject01..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths
where continent is not null
--group by date
order by 1,2

-------------------------------------------------------
-------------------------------------------------------

-- Looking at Total Population VS Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths dea
join PortfolioProject01..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---- Use CTE
with popVSvac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths dea
join PortfolioProject01..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popVSvac

--------------------------------------------------------

-- TEMP TABLE
DROP table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths dea
join PortfolioProject01..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #percentPopulationVaccinated


-- creating view to store data for later visualization

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
from PortfolioProject01..CovidDeaths dea
join PortfolioProject01..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null