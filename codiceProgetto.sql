/* Quali sono i Paesi meglio o peggio piazzati in termini di energia rinnovabile, sanità ed educazione, come queste metriche si sono mosse nel tempo 
e se esiste una correlazione tra alcune delle variabili. */


-- POSIZIONE DEI PAESI IN FATTO DI ENERGIA RINNOVABILE

/* Controllo quali sono i paesi con maggiori emissioni di Co2 
(numeri riferiti in tonnellate nel database, confronto a dati dell'internet, wikipedia, sono divisi per 1000) */

SELECT country, co2_emissions
	FROM worlddata2023
	WHERE co2_emissions IS NOT NULL
ORDER BY co2_emissions DESC;

-- Trovo la produzione, in tonnellate, di co2 pro capite

SELECT country, co2_emissions, round((co2_emissions/population)*1000, 5) AS co2_emissions_pro_capite
	FROM worlddata2023
	WHERE co2_emissions IS NOT NULL
ORDER BY co2_emissions_pro_capite DESC;
	
-- guardo quali sono i paesi con la maggiore produzione di energia rinnovabile nel 2020

SELECT entity, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = '2020' AND electricity_from_renewables_twh IS NOT NULL
ORDER BY electricity_from_renewables_twh DESC;

-- guardo quali sono i paesi che non hanno prodotto energia rinnovabile nel 2020

SELECT entity, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = '2020' AND electricity_from_renewables_twh = 0
ORDER BY electricity_from_renewables_twh ASC;

/* Controllo la correlazione tra produzione di energia rinnovabile e la popolazione, così facendo posso decidere di utilizzare 
come metro di misura più affidabile la produzione pro-capite di ogni stato */

SELECT CORR(s.electricity_from_renewables_twh, w.population)
	FROM sustainabledata s
JOIN worlddata2023 w
	ON w.country = s.entity;

-- Dato il valore di correlazione di 0.624 decido di utilizzare la produzione pro-capite per le valutazioni
	
/* controllo la produzione pro-capite di energia rinnovabile, 
così da avere un indicatore pesato sulla popolazione totale che rispecchi maggiormente la posizione dei paesi */

CREATE MATERIALIZED VIEW renewable_energy_production_rank AS
SELECT s.entity, s.year, s.electricity_from_renewables_twh,  
	   ROUND((s.electricity_from_renewables_twh/w.population),10) AS renewable_electricity_pro_capite_twh
	FROM SustainableData s
JOIN worldData2023 w
	ON s.entity = w.Country
	WHERE s.year = '2020' AND s.electricity_from_renewables_twh != 0
ORDER BY renewable_electricity_pro_capite_twh DESC
LIMIT 10;

-- Creo due VIEW con l'energia prodotta dai vari stati nel 2020 e nel 2015

CREATE VIEW renewable_energy_2015 AS
SELECT entity, year, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = 2015;

SELECT * FROM renewable_energy_2015;

CREATE VIEW renewable_energy_2020 AS
SELECT entity, year, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = 2020;

SELECT * FROM renewable_energy_2020;

-- Unisco le due viste create per avere un unica vista che comprenda sia i valori del 2015 che quelli del 2020

CREATE VIEW renewable_energy_production_comparison AS
SELECT r.entity, r.electricity_from_renewables_twh AS production_2015, rr.electricity_from_renewables_twh AS production_2020	   
	FROM renewable_energy_2015 r
JOIN renewable_energy_2020 rr
	ON r.entity = rr.entity;

/* Creo una MATERIALIZED VIEW che comprende la differenza di produzione di energia rinnovabile tra il 2015 e il 2020, dividendola per la popolazione totale (dati del 2023)
così da avere dati più attendibili e non inflazionati dalla grandezza degli stati */
	
CREATE MATERIALIZED VIEW renewable_energy_production_increment AS
SELECT p.entity, ROUND(((p.production_2020 - p.production_2015)/w.population), 10) AS production_increment_pro_capite
	FROM renewable_energy_production_comparison p
JOIN worlddata2023 w
	ON p.entity = w.Country	
ORDER BY production_increment_pro_capite DESC;

-- Seleziono le 10 nazioni che hanno incrementato di più la produzione di energia rinnovabile tra il 2015 e il 2020

SELECT * FROM renewable_energy_production_increment
WHERE production_increment_pro_capite IS NOT NULL 
LIMIT 10;

/* Creo una materialized view con all'interno gli stati con la maggior produzione e la rispettiva variazione
di produzione negli ultimi 5 anni di energia rinnovabile */

CREATE MATERIALIZED VIEW renewable_energy_increment_and_production AS
SELECT r.entity, r.renewable_electricity_pro_capite_twh, i.production_increment_pro_capite
	FROM renewable_energy_production_rank r
JOIN renewable_energy_production_increment i
	ON r.entity = i.entity
WHERE production_increment_pro_capite != 0
ORDER BY renewable_electricity_pro_capite_twh DESC; 

SELECT * FROM renewable_energy_increment_and_production;


-- ANALISI DEI DATI SANITARI

-- Estrapolo dal dataset "sustainabledata" i dati riguardanti la sanità e li inserisco in una MATERIALIZED VIEW

CREATE MATERIALIZED VIEW sanity_data AS
SELECT country, population, fertility_rate, birth_rate, infant_mortality, life_expectancy, 
	   maternal_mortality_ratio, out_of_pocket_health_expenditure, physicians_per_thousand
FROM worlddata2023;

SELECT * FROM sanity_data;

-- Controllo i paesi con la maggior aspettativa di vita

SELECT country, life_expectancy, ROUND((out_of_pocket_health_expenditure/100), 4) AS out_of_pocket_health_expenditure
	FROM sanity_data
WHERE out_of_pocket_health_expenditure IS NOT NULL AND life_expectancy IS NOT NULL
ORDER BY life_expectancy DESC;

-- Controllo la correlazione tra out_of_pocket_health_expenditure e life expectancy

SELECT CORR(out_of_pocket_health_expenditure, life_expectancy) 
	FROM sanity_data;

/* La correlazione negativa di queste due variaili sottolinea come gli stati che presentano una sanità pubblica,
quindi quelli in cui la variabile out_of_pocket_health_expenditure è minore, sono anche quelli in cui l'aspettativa
di vita è maggiore */

-- Controllo quali sono i paesi con il maggior fertility rate

SELECT country, fertility_rate
	FROM sanity_data
WHERE fertility_rate IS NOT NULL 
ORDER BY fertility_rate DESC;

/* Si nota ch ei paesi che hanno un maggior fertility rate sono rincipalmente paesi africani, adesso aggiungo il tasso di mortalità infantile, 
per avere una tabella conetente i due dati per ogni stato */

SELECT country, fertility_rate, ROUND((infant_mortality/100), 2) AS infant_mortality
	FROM sanity_data
WHERE fertility_rate IS NOT NULL
ORDER BY fertility_rate DESC;

-- Controllo la correlazione tra il tasso di fertilità e il tasso di mortalità infantile

SELECT CORR(fertility_rate, infant_mortality) AS corr_fertility_rate_and_infant_mortality
	FROM sanity_data;

-- Un tasso di correlazione di 0.85265 mi conferma che il tasso di fertilità e il tasso di mortalità infantile sono molto correlati 

-- Controllo quali sono le nazioni con il tasso di mortalità durante il parto

SELECT country, maternal_mortality_ratio, birth_rate
		FROM sanity_data
WHERE maternal_mortality_ratio IS NOT NULL
ORDER BY maternal_mortality_ratio DESC;

-- Controllo la correlazione tra le variabili di maternal_mortality_ratio e birth_rate

SELECT CORR(maternal_mortality_ratio, birth_rate)
	FROM sanity_data;

-- Concludo potendo affermare che con una correlazione che supera lo 0.768 che le due variabili sono fortemente correlate

-- Controllo quanto influisce la presenza di psicologi sull'aspettativa di vita

SELECT country, physicians_per_thousand 
	FROM sanity_data
	WHERE physicians_per_thousand 
	
SELECT country, life_expectancy, physicians_per_thousand
	FROM sanity_data
WHERE life_expectancy IS NOT NULL AND physicians_per_thousand IS NOT NULL
ORDER BY country;

SELECT CORR(life_expectancy, physicians_per_thousand) FROM sanity_data


/* Controllo la correlazione tra la quantità di froze armate del paese e l'aspettativa di vita per vedere se 
può essere un dato rilevante per l'analisi */

SELECT CORR(life_expectancy, armed_forces_size) AS corr_life_exp_and_armed_forces_size
	FROM worlddata2023;

/* La correlazione è molto vicina allo 0, quindi il dato non risulta rilevante ai fini dell'analisi */


-- Filtro i dati relativi all'istruzione

SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc, 
	   unemployment_rate, minimum_wage, labor_force_participation_perc 
	FROM worlddata2023;