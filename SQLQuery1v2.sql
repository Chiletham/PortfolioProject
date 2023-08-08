SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

-- Select Data from the Table for cleaning 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--- Total Cases vs total Deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2

-- Total cases vs Population
-- SHOWS THE POPULATION THAT GOT COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%Nigeria%'
ORDER BY 1,2


-- COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population,MAX(total_cases) as HighestInfectionCount,MAX ((total_cases/population))*100
as PercentageOfPopulationInfected 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected desc


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX (CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- BY CONTINENT
SELECT continent, MAX (CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


SELECT population, location,  MAX (CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
--WHERE continent is null
GROUP BY location, population
ORDER BY TotalDeathCount desc


----- Global Numbers 
SELECT date,SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage   
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Evalute
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage   
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


--- Total Vacination vs Population 

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,  
SUM(CONVERT(INT,Vac.new_Vaccinations )) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths$ Vac
	ON dea.location = Vac.location
	and dea.date =  Vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

-- USING COUNT 
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,  
SUM(CAST(Vac.new_Vaccinations AS int )) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths$ Vac
	ON dea.location = Vac.location
	and dea.date =  Vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

-- CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations ,rollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,  
SUM(CONVERT(INT,Vac.new_Vaccinations )) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths$ Vac
	ON dea.location = Vac.location
	and dea.date =  Vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3
)
SELECT *, (rollingPeopleVaccinated/Population)*100
FROM PopvsVac





-- USING TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated 
CREATE table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime ,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,  
SUM(CONVERT(INT,Vac.new_Vaccinations )) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths$ Vac
	ON dea.location = Vac.location
	and dea.date =  Vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

SELECT *, (rollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated








---creating view to store data
create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,  
SUM(CONVERT(INT,Vac.new_Vaccinations )) OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidDeaths$ Vac
	ON dea.location = Vac.location
	and dea.date =  Vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

select * 
from PercentPopulationVaccinated