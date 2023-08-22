Select *
From PortfolioProject ..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject ..CovidVaccinations
--order by 3,4

-- select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject ..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
--Shows the Probability of Dying if you contract Covid in Nigeria
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS MortalityPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%nigeria%'
ORDER BY 1, 2


--Total Cases vs Population
-- Shows what percentage of the population got Covid
SELECT location, date, population, total_cases, (CONVERT(float, total_cases) / population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%nigeria%'
ORDER BY 1, 2

--Countries with High Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (CONVERT(float, MAX(total_cases)) / population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Group by location, population
ORDER BY PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc

--Showing Statistics by Continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is null
Group by location
ORDER BY TotalDeathCount desc

--GLOBAL Daily COUNT
SELECT date, SUM(new_cases) AS GlobalDailyCases, SUM(new_deaths) AS GlobalDailyDeaths
FROM PortfolioProject..CovidDeaths
--Where location like '%nigeria%'
where continent is not null
Group by date
ORDER BY 1, 2


--Comparing Total Population vs Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   order by 2,3

	--Use CTE
	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
	as
	(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   --order by 2,3
   )
 	Select *, (CONVERT(float, (RollingVaccinationCount))/Population) *100 as VaccinatedPercentage
	From PopvsVac


--TEMP TABLE
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric,
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (CONVERT(float, (RollingVaccinationCount))/Population) *100 as VaccinatedPercentage
	From #PercentagePopulationVaccinated

	--Creating View to store data for later
Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
PercentagePopulationVaccinated
