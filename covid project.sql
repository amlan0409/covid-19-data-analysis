use portfolio_project;  

Select * 
From CovidDeaths
where continent is not null
order by 3,4;  

Select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2;  

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid
Select location,date,total_cases,new_cases,population,(total_deaths/population)*100 as deathpercentage
from CovidDeaths
order by 1,2;  

-- looking at countries with highest infection rate compared to population
Select location,population,max(cast(total_cases as unsigned)) as highestinfectioncount,max(total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
where continent is not null
group by location,population
order by percentpopulationinfected desc; 

-- showing countries with highest death count per population
Select location,max(cast(total_cases as unsigned)) as totaldeathcount
from CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc ;  

-- let's break things by continent
-- showing continents with highest deathcount per population
Select continent,max(cast(total_cases as unsigned)) as totaldeathcount
from CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;  

-- global numbers
SELECT 
    SUM(CAST(NULLIF(new_cases, '') AS DECIMAL(15,2))) AS total_cases,
    SUM(CAST(NULLIF(new_deaths, '') AS DECIMAL(15,2))) AS total_deaths,
    (SUM(CAST(NULLIF(new_deaths, '') AS DECIMAL(15,2))) /
     NULLIF(SUM(CAST(NULLIF(new_cases, '') AS DECIMAL(15,2))), 0)) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL;   

-- looking at total population vs vaccination 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from CovidDeaths dea
join CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3  ; 


-- using cte to perform Calculation on Partition By in previous query
WITH popvsvac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    *,
    (rollingpeoplevaccinated / population) * 100 AS rollingpeoplevaccinatedpercentage
FROM popvsvac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TEMPORARY TABLE IF EXISTS percentpopulationvaccinated; 
CREATE TEMPORARY TABLE percentpopulationvaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population DECIMAL(20,2),
    new_vaccinations DECIMAL(20,2),
    rollingpeoplevaccinated DECIMAL(20,2)
); 
INSERT INTO percentpopulationvaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select from temp table with rolling percentage
SELECT 
    *,
    (rollingpeoplevaccinated / population) * 100 AS rollingpeoplevaccinatedpercentage
FROM percentpopulationvaccinated; 

-- creating view to store data for later visualisation  
CREATE OR REPLACE VIEW percentpopulationivaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Query the view
SELECT *
FROM percentpopulationivaccinated;