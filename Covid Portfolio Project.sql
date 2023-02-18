Select * FROM PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4

--Select * FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using 

Select location,date,total_cases, new_cases,total_deaths,population 
from portfolioproject..CovidDeaths
Where continent is not NULL
Order by 1,2

--Lookimg at Total cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
Where location like '%Asia%' AND continent is not NULL
Order by 1,2


--Looking at Total_cases VS Population
--Shows what percentage of population got covid

Select location,date,population,total_cases, (total_cases/population)*100 as PercentagepopulationInfected
from portfolioproject..CovidDeaths
--Where location like '%Asia%'
Where continent is not NULL
Order by 1,2


--Looking at countries highest infection rate compared to population


Select location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagepopulationInfected
from portfolioproject..CovidDeaths
--Where location like '%Asia%'
Where continent is not NULL
GROUP BY location,population
Order by PercentagepopulationInfected DESC


--Showing countries with highest Death Count per Population

Select location, MAX(cast(total_deaths AS Int)) AS TotalDeathCount
from portfolioproject..CovidDeaths
--Where location like '%Asia%'
Where continent is not NULL
GROUP BY location
Order by TotalDeathCount DESC


--Lets break things by continents


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths AS Int)) AS TotalDeathCount
from portfolioproject..CovidDeaths
--Where location like '%Asia%'
Where continent is not NULL
GROUP BY continent
Order by TotalDeathCount DESC


--Global Numbers

Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--Where location like '%Asia%' 
Where continent is not NULL
--Group by date
Order by 1,2


---Looking at Total Population Vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated,
---(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
Where dea.continent is not NULL
Order By 2,3


--Use CTE

With PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
Where dea.continent is not NULL
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


---TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(	
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
--Where dea.continent is not NULL
--Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


---Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
Where dea.continent is not NULL
--Order By 2,3

Select * 
From PercentPopulationVaccinated