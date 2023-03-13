--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [iso_code]
--      ,[continent]
--      ,[location]
--      ,[date]
--      ,[new_tests]
--      ,[total_tests]
--      ,[total_tests_per_thousand]
--      ,[new_tests_per_thousand]
--      ,[new_tests_smoothed]
--      ,[new_tests_smoothed_per_thousand]
--      ,[positive_rate]
--      ,[tests_per_case]
--      ,[tests_units]
--      ,[total_vaccinations]
--      ,[people_vaccinated]
--      ,[people_fully_vaccinated]
--      ,[new_vaccinations]
--      ,[new_vaccinations_smoothed]
--      ,[total_vaccinations_per_hundred]
--      ,[people_vaccinated_per_hundred]
--      ,[people_fully_vaccinated_per_hundred]
--      ,[new_vaccinations_smoothed_per_million]
--      ,[stringency_index]
--      ,[population_density]
--      ,[median_age]
--      ,[aged_65_older]
--      ,[aged_70_older]
--      ,[gdp_per_capita]
--      ,[extreme_poverty]
--      ,[cardiovasc_death_rate]
--      ,[diabetes_prevalence]
--      ,[female_smokers]
--      ,[male_smokers]
--      ,[handwashing_facilities]
--      ,[hospital_beds_per_thousand]
--      ,[life_expectancy]
--      ,[human_development_index]
--  FROM [PortfolioProject].[dbo].[CovidVaccinations]

-- Data for Portfolio


Select Location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject]..CovidDeaths
where continent is not null
order by 1, 2

---Total Cases VS Total Deaths

Select Location, date, total_cases, total_deaths,( total_deaths/total_cases)* 100 as DeathPercentage
from [PortfolioProject]..CovidDeaths
where location like '%states%' and  continent is not null
order by 1, 2


----- Total Cases vs Population

Select Location, date, total_cases, population,( total_cases/population)* 100 as PopulationCases
from [PortfolioProject]..CovidDeaths
where location like '%states%' and  continent is not null
order by 1, 2


--- Countries WITH High Rate Infection vs Population

Select Location, Max (total_cases) as Infection_Count, population,Max ( Total_cases/population)* 100 as PopulationInfected
from [PortfolioProject]..CovidDeaths
--where location like '%states%' and
where continent is not null
Group by population, Location
order by 1, 2

-- Countries with High Death Count vs Population
Select Location, Max(Cast(total_deaths as Int))as TotalDeath_Count
from [PortfolioProject]..CovidDeaths
--where location like '%states%'
 where continent is not null
Group by  Location
order by TotalDeath_Count desc


-- Location
Select location, Max(Cast(total_deaths as Int))as TotalDeath_CountbyLocation
from [PortfolioProject]..CovidDeaths
 where continent is null
Group by  location
order by TotalDeath_CountbyLocation desc

--continent
Select continent, Max(Cast(total_deaths as Int))as TotalDeath_Countbycontinent
from [PortfolioProject]..CovidDeaths
 where continent is not null
Group by  continent
order by TotalDeath_Countbycontinent desc

--Continents with High Death Count VS Population
Select continent,population, Max(Cast(total_deaths as Int))as TotalDeath_Countbycontinent
from [PortfolioProject]..CovidDeaths
 where continent is not null
Group by  continent, population
order by TotalDeath_Countbycontinent desc

--Global Deaths and Cases
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/
sum(new_cases)*100 as WorldDeathPercentage
from [PortfolioProject]..CovidDeaths
 where continent is not null
 group by date
order by 1,2

--Global Deaths and Cases 22
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_daeths, sum(cast(new_deaths as int))/
sum(new_cases)*100 as WorldDeathPercentage
from [PortfolioProject]..CovidDeaths
where continent is not null
--group by date

--vaccination
select *
from[dbo].[CovidVaccinations]

--Join tables
select *
from [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location)
from [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Total Population vs Vaccinations 22
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedpercentage
from PopVsVac


