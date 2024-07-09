-- modifica dei datatype delle colonne che mi serviranno per i calcoli 

-- cambio il datatype della colonna 'electricity_from_renewables_twh' in numeric per utilizzare ORDER BY correttamente
ALTER TABLE sustainabledata
ALTER COLUMN electricity_from_renewables_twh 
TYPE NUMERIC USING electricity_from_renewables_twh::numeric;

-- cambio il tipo della colonna 'population' in numeric per poterla utilizzare nelle operazioni matematiche
-- rimuovo il punto all'interno della colonna, così da poter cambiare il datatype in numeric
UPDATE worlddata2023 
SET population = REPLACE(population, '.', '');

-- cambio il datatype della colonna in numeric
ALTER TABLE worlddata2023
ALTER COLUMN population 
TYPE NUMERIC USING population::numeric;

-- controllo l'esattezza direttamente dalla tabella
SELECT population FROM worlddata2023;