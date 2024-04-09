select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

select * 
from dbo.CovidVaccinations
where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths
where continent is not null
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

select location,population,MAX(total_cases) as highestInfectionCount,MAX((total_cases/population))*100 as percentageOfPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by percentageOfPopulationInfected desc

select continent,MAX(cast(total_deaths as int)) as highestDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc


select SUM(new_cases) as newTotalCases,SUM(cast(new_deaths as int)) as newTotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 as 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 
--where dea.location ='Canada'
where dea.continent is not null
order by 2,3





--USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 as 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 
--where dea.location ='Canada'
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopVsVac




--temp table

--DROP Table if exists #percentagePopulationVaccinated
create table #percentagePopulationGotVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentagePopulationGotVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 as 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 
--where dea.location ='Canada'
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #percentagePopulationGotVaccinated



--creating view to store data for later visualisations
create view PercentagePopulationGotVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100 as 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 
--where dea.location ='Canada'
where dea.continent is not null
--order by 2,3

