Select *
From ProjectPortfolio..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
Where continent is not null
Order by 1,2


 -- Looking at Total Cases VS Total Deaths
 -- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Break down by Continent (correct formulation)

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Break down by Continent (practice formulation)
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Showing the Continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CT

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac





--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store Data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3



Select * 
From PercentPopulationVaccinated