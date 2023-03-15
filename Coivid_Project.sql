Select *
From PortfolioProject..Coviddeath$
where continent is not null
order by 3,4



--Select Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths,Population
from PortfolioProject..Coviddeath$
order by 1,2

--Looking at Total case vs Total Deaths
--Shows likehood of dying in you contract covid in your country

SELECT 
    Location, 
    Date, 
    Total_cases, 
    Total_deaths, 
    CAST(Total_deaths AS decimal) / CAST(Total_cases AS decimal) * 100 AS DeathPercentage
FROM 
    PortfolioProject..Coviddeath$
WHERE 
    Location LIKE '%states%'   
ORDER BY  1,2



--Looking at Total cases vs Population 
--Shows the percentage of population get covid

SELECT 
    Location, 
    Date, 
    Total_cases, 
    Population, 
   (total_cases/Population)*100 as Percent_Population_infected
FROM 
    PortfolioProject..Coviddeath$
WHERE 
    Location ='United states'   
ORDER BY  1,2




--Looking  at countries with highest infection rate compared to population

  SELECT 
    Location, 
   Population, 
    max(Total_cases) as Highest_Infection_count, 
   max(total_cases/Population)*100 as Percent_Population_infected
FROM 
    PortfolioProject..Coviddeath$
--WHERE  Location ='United states' 
group by Location,Population
ORDER BY   Percent_Population_infected desc 


--Showing Countries with Highset Death count per Population

SELECT 
    Location,  
    max(cast(total_deaths as int)) as total_death_count
FROM 
    PortfolioProject..Coviddeath$
--WHERE  Location ='United states' 
where continent is not null
group by Location
ORDER BY   total_death_count desc  


--Analyze by continent
SELECT 
    continent,  
    max(cast(total_deaths as int)) as total_death_count
FROM 
    PortfolioProject..Coviddeath$
where continent is not null
group by continent
ORDER BY   total_death_count desc

-- Continents with the highest death count

SELECT 
    continent,  
    max(cast(total_deaths as int)) as highest_Deathcounts_of_population
FROM 
    PortfolioProject..Coviddeath$
where continent is not null
group by continent
ORDER BY   highest_Deathcounts_of_population desc

--Global Numbers

SELECT  
    SUM(new_cases)as total_cases,
    SUM(CAST(new_deaths AS int)) as total_death,
    SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage 
FROM 
    PortfolioProject..Coviddeath$
--GROUP BY 
   -- Date
ORDER BY  1,2



--Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as decimal)) over (Partition by dea.location order by dea.location,dea.Date) as Rolling_People_vaccinated
from PortfolioProject..Coviddeath$ dea
join PortfolioProject..Covidvaccination$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

--Use CTE
with PopvsVac(Continent,location,Date,population,new_vaccinations,Rolling_People_vaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as decimal)) over (Partition by dea.location order by dea.location,dea.Date) as Rolling_People_vaccinated
from PortfolioProject..Coviddeath$ dea
join PortfolioProject..Covidvaccination$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
	 )
	 select*,(Rolling_People_vaccinated/Population)*100
	 from PopvsVac
	   
--Temp Table

Create Table Percent_Population__Vaccinated
(
Continent nvarchar(255),
Locatioon nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_vaccinated numeric
)

Insert into Percent_Population__Vaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as decimal)) over (Partition by dea.location order by dea.location,dea.Date) as Rolling_People_vaccinated
from PortfolioProject..Coviddeath$ dea
join PortfolioProject..Covidvaccination$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 --where dea.continent is not null
	 --order by 2,3
	 
	 select*,(Rolling_People_vaccinated/Population)*100
	 from Percent_Population__Vaccinated;

--Create View to store data for visualization
Create view Percent_Population_Vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as decimal)) over (Partition by dea.location order by dea.location,dea.Date) as Rolling_People_vaccinated
from PortfolioProject..Coviddeath$ dea
join PortfolioProject..Covidvaccination$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 --where dea.continent is not null
	 --order by 2,3

select*
from Percent_Population_Vaccinated