--Select * 
--From PortfolioProject..CovidDeaths 
--order by 3,4


--Select * 
--From PortfolioProject..CovidVaccinations 
--order by 3,4

Select Location,Date,total_cases,new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Death
Select Location,Date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2


Select Location,sum(total_cases)
from PortfolioProject..CovidDeaths
group by location
order by 1;

-- Looking at Total Cases vs Population
Select Location,Date, population, total_cases, (total_cases/population)*100 as PercentageByPop
from PortfolioProject..CovidDeaths
Where location like '%korea%'
order by 1,2



--Looking at countries with the Highest Infection Rate compared to Population
Select Location, population, max(total_cases) as TopInfection, (max(total_cases)/population)*100 as PercentageByPop
from PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentageByPop desc

--Looking at countries with the Highest Death Rate compared to Population
Select Location, population, max(cast(total_deaths as int)) as TopDeath, (max(cast(total_deaths as int))/population)*100 as PercentageByPop
from PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentageByPop desc


--Looking at Continent with the highest death rate
Select location, Max(population) as Population, sum(cast(new_deaths as int)) as TopDeath,
sum(new_cases) as TotalCases, sum(cast(new_deaths as int))/Max(population) as DeathRate
from PortfolioProject..CovidDeaths
Where continent is null and (location = 'North America' or location = 'South America' or location = 'Asia' or location = 'Europe' or
location = 'Africa' or location = 'Oceania')
group by location
order by TopDeath desc


--Global Number by date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global Total number
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select *
from PortfolioProject..CovidVaccinations
where location like '%states%'
order by location,date

--Joining two table
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

--Looking at Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as AggVaccine
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
order by 2,3


With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,AggVaccine)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as AggVaccine 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *,(AggVaccine/population)*100 from PopvsVac

--Creating Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AggVaccine numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as AggVaccine 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null


--Creating a view
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as AggVaccine 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null