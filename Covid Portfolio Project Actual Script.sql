Select * from Portfolio_Project..Covid_Deaths
order by 3,4

--Select * from Portfolio_Project..Covid_Vaccinations
--order by 3,4 

Select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..Covid_Deaths
order by 1,2

--Total cases vs Total deaths

Select location,date,total_cases,total_deaths,(total_deaths/NullIF(total_cases,0))*100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
where location like '%states%'
order by 1,2

-- Total Cases vs Population
Select location,date,total_cases,population,(total_cases/population) *100 as Percent_PopupulationInfected
from Portfolio_Project..Covid_Deaths
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to popularion
Select location,population,MAX(total_cases) as HighestInfectionCount ,Max((total_cases/population)*100) as Percent_PopupulationInfected
from Portfolio_Project..Covid_Deaths
group by location,population
order by Percent_PopupulationInfected desc

Select location,MAX(total_deaths) as Total_Death_Count
from Portfolio_Project..Covid_Deaths
where continent is not Null
group by location
order by Total_Death_Count desc

--by continent
Select continent,MAX(total_deaths) as Total_Death_Count
from Portfolio_Project..Covid_Deaths
where continent is not Null
group by continent
order by Total_Death_Count desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths ,SUM(new_deaths)/SUM(NullIF(new_cases,0))*100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Join teo tables
Select * from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date

--Looking at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by 
dea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date 
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
        AS RollingPeopleVaccinated
FROM
    Portfolio_Project..Covid_Deaths dea 
JOIN
    Portfolio_Project..Covid_Vaccinations vac 
ON
    dea.location = vac.location 
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, dea.date;



--CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as 
RollingPeopleVaccinated
from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
)
Select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table
Drop table if exists #PercentPopVacc
Create table #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccination BIGINT,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopVacc
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as 
RollingPeopleVaccinated
from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 2,3

Select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopVacc


--Create view to store data for later visualozation
--Drop view if exists PercentPopolationVaccinated;
Create view PercentPopolationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) as 
RollingPeopleVaccinated
from
Portfolio_Project..Covid_Deaths dea join
Portfolio_Project..Covid_Vaccinations vac on
dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 2,3

Select * from 
PercentPopolationVaccinated
