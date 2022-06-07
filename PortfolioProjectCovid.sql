--Memilih data yang ingin digunakan
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortofolioProject..Coviddeaths$
ORDER BY 1,2 ;

--Memeriksa jumlah total kasus dan total kasus kematian di Australia
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..Coviddeaths$
WHERE location = 'Australia'
ORDER BY 1,2;


--Menampilkan persentase  populasi penduduk Australia yang tertular Covid
SELECT Location,date,total_cases,Population, (total_cases/population)*100 as DeathPercentage
FROM PortofolioProject..Coviddeaths$
WHERE location ='Australia'
ORDER BY 1,2;


--Melihat Negara dengan infeksi tertinggi  
SELECT Location,Population,Max(total_cases) as LowestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortofolioProject..Coviddeaths$
WHERE continent IS NOT NULL
GROUP BY Location,Population
ORDER BY PercentPopulationInfected desc

--Melihat Negara dengan kematian tertinggi berdasarkan jumlah kematian per populasi 
SELECT Location,Max(total_deaths) as TotalDeathCount
FROM PortofolioProject..Coviddeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


--Menampilkan Continent mana yang memiliki kematian tertinggi
SELECT continent,Max(total_deaths) as TotalDeathCount
FROM PortofolioProject..Coviddeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Melakukan join table dari table coviddeath dan covidvacination

SELECT * FROM PortofolioProject..Coviddeaths$ Death
JOIN PortofolioProject..CovidVacination$ Vacination
ON Death.location = Vacination.location
and Death.date = Vacination.date

With PopulationVsVacin(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
--menampilkan total populasi dan vaksinasi
SELECT Death.continent,Death.location,Death.date,Death.population,Vacination.new_vaccinations
,SUM(CONVERT(float,Vacination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location,
Death.Date) as RollingPeopleVaccinated
FROM PortofolioProject..Coviddeaths$ Death
JOIN PortofolioProject..CovidVacination$ Vacination
ON Death.location = Vacination.location
and Death.date = Vacination.date
WHERE Death.continent IS NOT NULL AND
Vacination.new_vaccinations IS NOT NULL
--ORDER BY Death.continent
)

CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO PercentPopulationVaccinated
SELECT Death.continent,Death.location,Death.date,Death.population,Vacination.new_vaccinations
,SUM(CONVERT(float,Vacination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location,
Death.Date) as RollingPeopleVaccinated
FROM PortofolioProject..Coviddeaths$ Death
JOIN PortofolioProject..CovidVacination$ Vacination
ON Death.location = Vacination.location
and Death.date = Vacination.date
WHERE Death.continent IS NOT NULL AND
Vacination.new_vaccinations IS NOT NULL
--ORDER BY Death.continent


SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

--Membuat view untuk divisualisasikan
Create View PercentPopulationVaccinated1 as 
SELECT Death.continent,Death.location,Death.date,Death.population,Vacination.new_vaccinations
,SUM(CONVERT(float,Vacination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location,
Death.Date) as RollingPeopleVaccinated
FROM PortofolioProject..Coviddeaths$ Death
JOIN PortofolioProject..CovidVacination$ Vacination
ON Death.location = Vacination.location
and Death.date = Vacination.date
WHERE Death.continent IS NOT NULL AND
Vacination.new_vaccinations IS NOT NULL
--ORDER BY Death.continent

SELECT * FROM PercentPopulationVaccinated1