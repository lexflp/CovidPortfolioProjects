SELECT * FROM PortfolioProjectCovid..['covid  deaths$']
where continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProjectCovid ..['covid vaccination$']
--order by 3,4

--Select Data that we are going to be using

Select  
location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid .. ['covid  deaths$']
where continent is not null
order by 1,2;


--Looking at Total cases vs Total deaths
--Shows likelyhood of dying if you contract covid in your country
Select  
location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid .. ['covid  deaths$']
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
Select  
location, date, total_cases, population, ( total_cases/population)*100 as PerecentPopulationInfected
From PortfolioProjectCovid .. ['covid  deaths$']
Where location like '%states%'
order by 1,2


--What countries have the highest infection compared to population?
Select  
location, population, MAX(total_cases) as HighestInfectionCount,  MAX(( total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProjectCovid .. ['covid  deaths$']
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with the Highest Death Count per population
Select  
location, MAX(total_deaths) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is not null
Group by location 
order by TotalDeathCount desc


--Showing Countries with Highest Death Count per Population

Select  
location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is not null
Group by location 
order by TotalDeathCount desc

--Lets Break things Down by Continent
Select  
continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc
--not perfect because North America seems to be missing Canada, want to include continent 

--Now try query with location
Select  
location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is  null
Group by location
order by TotalDeathCount desc
--THIS IS MORE ACCURATE^^--But purpose of video going to stick to first query

--Lets Break things Down by Continent(CONTINUED)
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT per population
Select  
continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--IF you want anything global for the above queries just add GROUP BY Continent-- Drilling down is making the layer smaller


--GLOBAL NUMBERS
Select  
 SUM(new_cases) as TotalCases ,SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as 
DeathPercentage
From PortfolioProjectCovid .. ['covid  deaths$']
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--^^^ this shows total deaths worldwide in percentage

--Looking at total Population vs Total Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..['covid  deaths$'] dea
Join PortfolioProjectCovid..['covid vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..['covid  deaths$'] dea
Join PortfolioProjectCovid..['covid vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 3,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE( with alterations add "Drop table if" ) It would look good infront of an employer and shows THAT YOU KNOW WHt you are doing

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..['covid  deaths$'] dea
Join PortfolioProjectCovid..['covid vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated

--Creating  view to store data for later visuAlizations 
Create View PercentPopulationVaccinatted as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location,
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..['covid  deaths$'] dea
Join PortfolioProjectCovid..['covid vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

SELECT * 
From PercentPopulationVaccinatted


--More Views
Create View ContinentsDeathCounts as 

Select  
continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..['covid  deaths$']
--Where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount desc


SELECT * FROM ContinentsDeathCounts


Create View CountriesInfectionRate as 
Select  
location, population, MAX(total_cases) as HighestInfectionCount,  MAX(( total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProjectCovid .. ['covid  deaths$']
--Where location like '%states%'
Group by location, population
--order by PercentPopulationInfected desc

SELECT * FROM CountriesInfectionRate


CREATE view TotalCasesvsTotaldeaths as
Select  
location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid .. ['covid  deaths$']
Where location like '%states%'
--order by 1,2

SELECT * FROM TotalCasesvsTotaldeaths