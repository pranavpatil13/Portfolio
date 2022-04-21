UPDATE Project_Portfolio..Covid_Deaths 
SET continent = NULL 
WHERE continent = ''

UPDATE Project_Portfolio..Covid_Vaccinations 
SET new_vaccinations = NULL 
WHERE new_vaccinations = ''

update Project_Portfolio..Covid_Deaths
set date = convert(datetime, date, 103)
update Project_Portfolio..Covid_Vaccinations
set date = convert(datetime, date, 103)

--Total Cases vs Deaths
SELECT Location, date, total_cases, total_deaths, cast(total_deaths as float)/ nullif(cast(total_cases as float),0)*100
as Death_Percentage
from Project_Portfolio..Covid_Deaths
where location like '%India%'
order by 1,2


--Total Cases vs Population
SELECT Location, date, total_cases, population, cast(total_cases as float)/ nullif(cast(population as float),0)*100
as Case_Percentage
from Project_Portfolio..Covid_Deaths
where location like '%India%'
order by 1,2

--Countries with highest positivity rates compared to Population
SELECT Location, max(total_cases) as Highest_Postive_count, population, max(cast(total_cases as float)/ nullif(cast(population as float),0)*100)
as Infected_population_percentage
from Project_Portfolio..Covid_Deaths
group by location, population
order by Infected_population_percentage desc

--Countries with highest death count per population
Select Location, max(cast(Total_deaths as int)) as Death_Count_Total
from Project_Portfolio..Covid_Deaths
where continent is not null
group by Location
order by Death_Count_Total desc

--Global Numbers
select date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, sum(cast(new_deaths as float))/ sum(nullif(cast(new_cases as float),0))*100
as Death_Percentage
from Project_Portfolio..Covid_Deaths
where continent is not null
group by date
order by 1, 2

--Joining death and Vaccination tables
--Total population vs vaccinations



select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
from Project_Portfolio..Covid_Deaths death
join Project_Portfolio..Covid_Vaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2,3 

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations as float)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
from Project_Portfolio..Covid_Deaths death
join Project_Portfolio..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
from Project_Portfolio..Covid_Deaths death
join Project_Portfolio..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/nullif(cast(population as float),0))*100
From PopvsVac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as float)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
from Project_Portfolio..Covid_Deaths death
join Project_Portfolio..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
	
	
Select *, (RollingPeopleVaccinated/nullif(cast(population as float),0))*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
from Project_Portfolio..Covid_Deaths death
join Project_Portfolio..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 

select *
from PercentPopulationVaccinated









