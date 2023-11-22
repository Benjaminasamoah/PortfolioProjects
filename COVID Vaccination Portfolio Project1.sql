Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From  PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2

-- Cases vs Total deaths
-- Shows the likelihood of dying if you contract COVID-19 in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentMortality
From  PortfolioProject1..CovidDeaths
Where location in ('United States','Ghana','Nigeria')
and continent is not null
Order by 1,2

Create view Cases_vs_TotalDeaths as
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentMortality
From  PortfolioProject1..CovidDeaths
--Where location in ('United States','Ghana','Nigeria')
Where continent is not null


--Total cases vs Population
--Shows what percentage of population got COVID-9
Select location,date,total_cases,population,(total_cases/population)*100 as PercentCases 
From  PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at countries with Highest Infection compared  to population
Select location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as MaxPercentCases
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by location,population
Order by MaxPercentCases desc

Create view MaxPercentCases as
Select location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as MaxPercentCases
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by location,population

--Showing location with the highest Death Count per Population
Select location,MAX(total_deaths) as TotalDeathCount
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Breaking things down by continent
-- Determining death counts by continent
Select continent,MAX(total_deaths) as TotalDeathCount
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

Create view Death_Counts_By_Continent as
Select continent,MAX(total_deaths) as TotalDeathCount
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent

--GLOBAL NUMBERS
Select date,SUM(new_cases) Total_cases_per_day,SUM(new_deaths) Total_deaths_per_day,(SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DailyDeathPercentage
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 

Create view DailyDeathPercentage as
Select date,SUM(new_cases) Total_cases_per_day,SUM(new_deaths) Total_deaths_per_day,(SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DailyDeathPercentage
From  PortfolioProject1..CovidDeaths
Where continent is not null
Group by date

--Overall death percentage across the world
Select SUM(new_cases) Total_cases,SUM(new_deaths) Total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From  PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2 


--JOINING COVID VACCINATIONS TABLE AND COVID DEATHS TABLE
--looking at total population per day vs new vaccinations per day
Select dea.continent,dea.location,dea.population,vac.new_vaccinations
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Determining rolling vaccinations per location
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations_per_location
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Create view RollingVaccinations as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations_per_location
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--Determining the percentage of the population vaccinated
--USE CTE
With PopvsVac (continent,location,population,new_vaccinations,RollingVaccinations_per_location)
as
(
Select dea.continent,dea.location,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations_per_location
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingVaccinations_per_location/population)*100 as Population_percentage_vaccinated
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingVaccinations_per_location numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations_per_location
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *,(RollingVaccinations_per_location/population)*100 as Population_percentage_vaccinated
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations_per_location
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null