
SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at total Cases vs Total Deaths

SELECT Location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
 and continent is not null
order by 1,2

--Looking at Total Cases vs Popluation
--Shows what percentage of populaiton got Covid

SELECT Location,date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
order by 1,2

 -- Looking at Countries with Highest Infection Rate compared to Population

 SELECT Location, population, MAX(total_cases) as HighestInfection, Max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '$states$'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Breaking things down by Continent

--Showing the continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '$states$'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(New_cases) as DeathPercentage --, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
 where continent is not null
-- Group by date
order by 1,2

--Looking at Total Populaiton vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_cases, 
SUM(CONVERT(int,vac.new_cases)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleNewCases
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsNewCases (Continent, Location, Date, Population, New_Cases, RollingPeopleNewCases)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_cases, 
SUM(CONVERT(int,vac.new_cases)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleNewCases
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleNewCases/Population)*100
From PopvsNewCases


--TEMP TABLE


Create Table #PercentPopulationNewCases
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_cases numeric,
RollingPeopleNewcases numeric
)

Insert into #PercentPopulationNewCases
Select dea.continent, dea.location, dea.date, dea.population, vac.new_cases, 
SUM(CONVERT(int,vac.new_cases)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleNewCases
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleNewCases/Population)*100
From #PercentPopulationNewCases


--Creating View to store data for later visualizations

Create View PercentPopulationNewCases as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_cases, 
SUM(CONVERT(int,vac.new_cases)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleNewCases
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From #PercentPopulationNewCases