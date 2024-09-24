Select * 
From [portfolio project]..CovidDeaths
where continent is not null
order by 3,4
--select *
--From [portfolio project]..CovidVaccinations
--order by 3,4

--select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
from [portfolio project]..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [portfolio project]..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking by total cases vs population
--shows what percentage of population got covid

Select location,date,total_cases,new_cases,population,(total_deaths/population)*100 as deathpercentage
from [portfolio project]..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select location,population,max(total_cases) as highestinfectioncount,max(total_cases/population)*100 as percentpopulationinfected
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by percentpopulationinfected desc

--showing countries with highest death count per population

Select location,max(cast(total_cases as int)) as totaldeathcount
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--let's break things by continent
--showing continents with highest deathcount per population

Select continent,max(cast(total_cases as int)) as totaldeathcount
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac(continent,date,location,population,new_vaccinations,rollingpeoplevaccinated) as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select* ,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualisation

create view percentpeoplevaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpeoplevaccinated

