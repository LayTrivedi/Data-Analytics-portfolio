select *
from portfolioprojects..CovidDeaths
order by 3,4

select * 
from portfolioprojects..CovidVaccination
order by 3,4

--select data that we are going to be using
select location, date, total_cases,new_cases, total_deaths, population
from portfolioprojects..CovidDeaths
order by 1,2

-- looking at the total cases vs total deaths
-- shows the liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioprojects..CovidDeaths
where location like '%india%'
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid

select location, date, population, total_cases,  (total_cases/population)*100 as CasesPercentage
from portfolioprojects..CovidDeaths
where location like '%india%'
order by 1,2

-- what country has the highest infection rate

select location, population, MAX(total_cases) as highestinfectioncount,  MAX((total_cases/population))*100 as Percentpopulationinfected
from portfolioprojects..CovidDeaths
--where location like '%india%'
group by location, population
order by Percentpopulationinfected desc

-- Countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as deathcount
from portfolioprojects..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by deathcount desc

-- Break things down based on continent
--Showing the continents with the highest death count

select continent, MAX(cast(total_deaths as int)) as deathcount_continent
from portfolioprojects..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by deathcount_continent desc


-- Global numbers


select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioprojects..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--looking for total vaccinations vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevac/population)*100
from popvsvac

-- Using TEMP table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevac numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rollingpeoplevac/population)*100
from #percentpopulationvaccinated

-- creating view to store data for later visualisations


create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated