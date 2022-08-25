select * from [Portfolio-Project].dbo.[CovidDeaths]
order by 3,4

-- select * from [Portfolio-Project].dbo.[CovidVaccinations]
-- order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from [Portfolio-Project].dbo.[CovidDeaths]
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows likelyhood of dying if you contract in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio-Project].dbo.[CovidDeaths]
where location like '%Mongol%'
order by 1,2

-- Looking at Total Cases VS Population

Select Location, Date, total_cases, population, (total_cases/population)*100 as CasePercentage
from [Portfolio-Project].dbo.[CovidDeaths]
where location like '%mongol%'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio-Project].dbo.[CovidDeaths]
where continent is not null
--- where location like '%mongol%'
group by location, population
order by PercentPopulationInfected DESC

-- This is Shows Countries with Highest Death Count of Population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio-Project].dbo.[CovidDeaths]
where continent is not null
--- where location like '%mongol%'
group by location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio-Project].dbo.[CovidDeaths]
where location not like '%income%'
and continent is null
group by location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio-Project].dbo.[CovidDeaths]
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population VS Vaccineation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project].dbo.[CovidDeaths] dea
join [Portfolio-Project].dbo.[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project].dbo.[CovidDeaths] dea
join [Portfolio-Project].dbo.[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project].dbo.[CovidDeaths] dea
join [Portfolio-Project].dbo.[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization 

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project].dbo.[CovidDeaths] dea
join [Portfolio-Project].dbo.[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null