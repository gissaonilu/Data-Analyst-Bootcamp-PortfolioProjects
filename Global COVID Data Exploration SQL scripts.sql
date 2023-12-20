--SQL DATA EXPLORATION BY GANIYAT ISSA-ONILU
-- Datasets used: Covid Deaths, Covid Vaccinations (imported and loaded as SQL tables)

-- Select the data for exploration
select location, date, total_cases, new_cases, total_deaths, population 
from [Covid-Deaths]
where continent is not null
order by 1,2

--- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if contracted COVID19
select location, date, total_cases,total_deaths, (convert(decimal,total_deaths)/convert(decimal,total_cases))*100.0 as DeathPercentage
from [Covid-Deaths]
where location = 'Nigeria' and  continent is not null

order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got COVID19
select location, date, population, total_cases, (convert(decimal,total_cases)/convert(decimal,population))*100 as PercentPopInfected
from [Covid-Deaths]
where location = 'Nigeria'
order by 1,2

-- Looking at countries with highest infection rate

select location, population, max(total_cases) as HighestInfectionCount, max((convert(decimal,total_cases)/convert(decimal,population)))*100 as PercentPopInfected
from [Covid-Deaths]
where continent is not null
group by location, population
order by 4 desc

-- Showing countries with highest death counts per population
select location, max(total_deaths) as HighestDeathCount
from [Covid-Deaths]
where continent is not null
group by location
order by 2 desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent , max(total_deaths) as HighestDeathCount
from [Covid-Deaths]
where continent is not null
group by continent
order by 2 desc

-- GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(convert(decimal,new_deaths))/NULLIF(sum(convert(decimal,new_cases)),0)) *100 as DeathsPercent
from [Covid-Deaths]
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(convert(decimal,new_deaths))/NULLIF(sum(convert(decimal,new_cases)),0)) *100 as DeathsPercent
from [Covid-Deaths]
where continent is not null
--group by date
order by 1,2

--- Load Covid Vaccinations

Select * from [Covid-Vaccinations]

-- Join the two tables together
-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid-Deaths] dea
join [Covid-Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 
With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid-Deaths] dea
join [Covid-Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select *, (convert(decimal,RollingPeopleVaccinated)/convert(decimal,Population))*100 from PopsVac

-- USING TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date date, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid-Deaths] dea
join [Covid-Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (convert(decimal,RollingPeopleVaccinated)/convert(decimal,Population))*100 from #PercentPopulationVaccinated

---CREATE VIEW to store data for later visualization

Create View DeathCountPerContinent as 
select continent , max(total_deaths) as HighestDeathCount
from [Covid-Deaths]
where continent is not null
group by continent

Create View PeopleVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Covid-Deaths] dea
join [Covid-Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from DeathCountPerContinent