-- modifica dei datatype delle colonne che mi serviranno per i calcoli 

-- cambio il datatype della colonna 'electricity_from_renewables_twh' in numeric per utilizzare ORDER BY correttamente
ALTER TABLE sustainabledata
ALTER COLUMN electricity_from_renewables_twh 
TYPE NUMERIC USING electricity_from_renewables_twh::numeric;

-- cambio il tipo della colonna 'population' in numeric per poterla utilizzare nelle operazioni matematiche
-- rimuovo il punto all'interno della colonna, così da poter cambiare il datatype in numeric
UPDATE worlddata2023 
SET population = REPLACE(population, '.', '');

-- cambio il datatype della colonna "population" in numeric
ALTER TABLE worlddata2023
ALTER COLUMN population 
TYPE NUMERIC USING population::numeric;

-- cambio il datatype della colonna "year" in numeric
ALTER TABLE sustainabledata
ALTER COLUMN year
TYPE NUMERIC USING year::numeric;

-- cambio il datatype della colonna "renewable_electricity_generating_capacity_per_capita " in numeric
ALTER TABLE sustainabledata
ALTER COLUMN renewable_electricity_generating_capacity_per_capita 
TYPE NUMERIC USING renewable_electricity_generating_capacity_per_capita::numeric;

-- controllo l'esattezza direttamente dalla tabella
SELECT population FROM worlddata2023;

-- cambio il datatype dei dati sulla sanità in numeric
ALTER TABLE worlddata2023
ALTER COLUMN life_expectancy
TYPE NUMERIC USING life_expectancy::numeric;

ALTER TABLE worlddata2023
ALTER COLUMN infant_mortality
TYPE NUMERIC USING infant_mortality::numeric;

ALTER TABLE worlddata2023
ALTER COLUMN fertility_rate
TYPE NUMERIC USING fertility_rate::numeric;

ALTER TABLE worlddata2023
ALTER COLUMN maternal_mortality_ratio
TYPE NUMERIC USING maternal_mortality_ratio::numeric;

ALTER TABLE worlddata2023
ALTER COLUMN physicians_per_thousand
TYPE NUMERIC USING physicians_per_thousand::numeric;

ALTER TABLE worlddata2023
ALTER COLUMN birth_rate
TYPE NUMERIC USING birth_rate::numeric;


UPDATE worlddata2023 
SET armed_forces_size = REPLACE(armed_forces_size, ',', '');

ALTER TABLE worlddata2023 
ALTER COLUMN armed_forces_size
TYPE NUMERIC USING armed_forces_size::numeric;

-- 

UPDATE worlddata2023 
SET out_of_pocket_health_expenditure = REPLACE(out_of_pocket_health_expenditure, '%', '');
	
ALTER TABLE worlddata2023
ALTER COLUMN out_of_pocket_health_expenditure 
TYPE NUMERIC USING out_of_pocket_health_expenditure::NUMERIC;

--

UPDATE worlddata2023 
SET co2_emissions  = REPLACE(co2_emissions, ',', '');

ALTER TABLE worlddata2023 
ALTER COLUMN co2_emissions 
TYPE NUMERIC USING co2_emissions ::numeric;

--
BEGIN
UPDATE worlddata2023 
SET minimum_wage = REPLACE(minimum_wage, '$', '');

ALTER TABLE worlddata2023
ALTER COLUMN minimum_wage
TYPE NUMERIC USING minimum_wage::NUMERIC;

SELECT country, minimum_wage FROM worlddata2023;
commit