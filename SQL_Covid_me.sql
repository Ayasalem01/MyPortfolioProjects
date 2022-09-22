-- This is a project I am working on for purpose of more practice on the skills learned as part of my BBA
-- I took the Dataset that shows COVID informations from the website : https://ourworldindata.org/covid-deaths

Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3,4
-- I don't want the country statistics to be included in my model to get accurate results when I compare between different locations.

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select the Data that I am going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2


--looking at total cases VS total Deaths:
--Shows likelihood of dying if you get COVID by your location (in this case I filtered by Tunisia)
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Tunis%'
Where continent is not NULL
order by 1,2


--looking at Total cases vs the total Population
--here I used the query to show what percentage of the population got infected by covid
Select Location, date, total_cases, population,(total_cases/population)*100 as infectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Tunis%'
AND continent is not NULL
order by 1,2

--countries with the highest infection rate compared to pop
Select Location, population, MAX(total_cases) as HighestinfectionNumb,MAX((total_cases/population))*100 as infectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Tunis%'
Where continent is not NULL
Group by population,location
order by infectedPercentage desc

-- >according to  the result I go, we can say that our most infected location is Andorra with 17.13% rate!
 

 -- this query will show the locations with highest death numbers.
 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Tunis%'
Where continent is not NULL
Group by location
order by TotalDeathCount desc
-- > according to the results I got I have United States as the country with max death with 576'232 dead person.

--Now I will show statitcs according to each continent
 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location is not NULL
Group by continent
order by TotalDeathCount desc



--Global numbers:

Select  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Tunis%'
where continent is not NULL
--group by date
order by 1,2
-- X Problem on this query


-- I will join my two tables of death and vaccination together
Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location --the rel
	and dea.date = vac.date



-- I will compare Total population vs vaccination
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as  NbOfPeopleVaccinated-- because I want the counter to start over at each location.
-- I can use cast OR CONVERT(int, vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location --the rel
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


	--use a city


with popVsVac (continent, location, date, population, NbOfPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as  NbOfPeopleVaccinated-- because I want the counter to start over at each location.
-- I can use cast OR CONVERT(int, vac.new_vaccinations)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location =vac.location --the rel
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, --(NbOfPeopleVaccinated/population)*100
	From popVsVac