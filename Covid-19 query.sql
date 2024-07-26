select location,date,total_cases,new_cases,total_deaths,population from COVID..[CovidDeaths( edited for project11)]
select * from COVID..[CovidDeaths( edited for project11)]

--Morality Rate in INDIA 

select location,total_cases,new_cases,total_deaths, (total_deaths/ NULLIF(total_cases,0)*100) as morality_rate 
from COVID..[CovidDeaths( edited for project11)]
where location Like 'India'

--Morality Rate

select location,total_cases,new_cases,total_deaths, (total_deaths/ NULLIF(total_cases,0)*100) as morality_rate 
from COVID..[CovidDeaths( edited for project11)]


-- Looking at the total cases vs population

select location,date,total_cases,new_cases,total_deaths,population, (total_cases/ NULLIF(population,0)*100) as percentage_of_cases 
from COVID..[CovidDeaths( edited for project11)]


-- Countries with Highest Infection Rate

select location,Max(total_cases)as Total_Cases,population,MAX((total_cases/ NULLIF(population,0))*100) as Infection_rate 
from COVID..[CovidDeaths( edited for project11)] 
group by location,population
order by Infection_rate desc


-- Countries with highest Death counts

select location,Max(total_deaths)as Death_count,population
from COVID..[CovidDeaths( edited for project11)]
Where location NOT IN ('World','Europe','North America','South America','Oceania','Africa','Asia')
group by location,population
order by Death_count desc

--Continents with highest death counts

select continent,Max(total_deaths)as Death_count
from COVID..[CovidDeaths( edited for project11)]
Where continent IS NOT NULL
group by continent
order by Death_count desc



-- Global Numbers

select date,SUM(new_cases)as New_cases, SUM(new_deaths) as New_deaths, (SUM(new_deaths)/ NULLIF (SUM(new_cases),0)*100) as Death_percentage
from COVID..[CovidDeaths( edited for project11)]
Where continent IS NOT NULL
group by date


Select * from COVID..CovidVaccinations11

-- Joining two tables on the basis of location and date

Select * 
from COVID..[CovidDeaths( edited for project11)] dea
JOIN COVID..CovidVaccinations11 vac
ON dea.location = vac.location
AND dea.date = vac.date


-- Total vaccinations & Total tests done date wise
select dea.continent, dea.location,dea.date,dea.total_cases,dea.total_deaths,dea.population, vac.total_tests,vac.total_vaccinations,vac.new_vaccinations
from COVID..[CovidDeaths( edited for project11)] dea
JOIN COVID..CovidVaccinations11 vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent IS NOT NULL


-- Maximum vaccinations

Select dea.location,SUM(dea.total_cases)as Total_cases,SUM(dea.total_deaths)as Total_deaths,SUM(vac.total_vaccinations) as Total_vaccination
from COVID..[CovidDeaths( edited for project11)] dea
JOIN COVID..CovidVaccinations11 vac
ON dea.location = vac.location
AND dea.date = vac.date
Group by dea.location 
Order by 1,2,3

--Year having the maximum deaths

SELECT TOP 1
    YEAR(CONVERT(date, date, 105)) AS Year,
    SUM(total_deaths) AS TotalDeaths
FROM
    COVID..[CovidDeaths( edited for project11)]
Where TRY_CONVERT(date, date,105) IS NOT NULL
GROUP BY
    YEAR(CONVERT(date, date, 105))
ORDER BY
    TotalDeaths DESC

-- Year having the maximum new cases

SELECT TOP 1
    YEAR(CONVERT(date, date, 105)) AS Year,
    SUM(new_cases) AS Totalnewcases
FROM
    COVID..[CovidDeaths( edited for project11)]
Where TRY_CONVERT(date, date,105) IS NOT NULL
GROUP BY
    YEAR(CONVERT(date, date, 105))
ORDER BY
    Totalnewcases DESC

-- Cumulative deaths over time for India

SELECT 
    CONVERT(date, date, 105) AS ConvertedDate,
    location,
    SUM(total_deaths) OVER (PARTITION BY location ORDER BY CONVERT(date, date, 105)) AS CumulativeDeaths
FROM COVID..[CovidDeaths( edited for project11)]
WHERE 
    TRY_CONVERT(date, date, 105) IS NOT NULL 
    AND location = 'India'
ORDER BY 
    location,
    CONVERT(date, date, 105)


-- Looking at total population vs vaccinations

With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from COVID..[CovidDeaths( edited for project11)] dea
JOIN COVID..CovidVaccinations11 vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
)
Select *,(RollingPeopleVaccinated/NULLIF(population,0))*100 as percentage_vaccinated
from PopvsVac
