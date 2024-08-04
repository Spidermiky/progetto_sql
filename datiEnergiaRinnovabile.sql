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

SELECT country, co2_emissions, ROUND((co2_emissions/population)*1000, 5) AS co2_emissions_pro_capite
	FROM worlddata2023
	WHERE co2_emissions IS NOT NULL
ORDER BY co2_emissions_pro_capite DESC;

/* Guardo quali sono i paesi con la maggiore produzione totale e pro capite di energia da combustibili fossili nel 2020, 
decidendo quale dei due dati vedere a schermo cambiando il nome della colonna attraverso l'ORDER BY */

SELECT s.entity, s.electricity_from_fossil_fuels_twh, 
	   ROUND((s.electricity_from_fossil_fuels_twh/w.population), 5) AS electricity_from_fossil_fuels_twh_pro_cap
	FROM sustainabledata s
JOIN worlddata2023 w
	ON s.entity = w.country
WHERE year = '2020' AND electricity_from_fossil_fuels_twh IS NOT NULL
ORDER BY electricity_from_fossil_fuels_twh DESC;

/* Guardo quali sono i paesi con la maggiore produzione totale e pro capite di energia dal nucleare nel 2020 
Non utilizzo la clausola IS NOT NULL, ma il '=! 0' perchè noto che ci sono solo poche nazioni che producono energia nucleare*/

SELECT s.entity, s.electricity_from_nuclear_twh, 
	   ROUND((s.electricity_from_nuclear_twh/w.population), 10) AS electricity_from_nuclear_twh_pro_cap
	FROM sustainabledata s
JOIN worlddata2023 w
	ON s.entity = w.country
WHERE year = '2020' AND electricity_from_nuclear_twh != 0
ORDER BY electricity_from_nuclear_twh DESC;

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
ORDER BY renewable_electricity_pro_capite_twh DESC;

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

/* Creo una VIEW che comprende la differenza di produzione di energia rinnovabile tra il 2015 e il 2020, sia totale che pro-capite (dati del 2023)
così da avere anche dati più attendibili e non inflazionati dalla differenza demografica degli stati */
	
CREATE VIEW renewable_energy_production_increment AS
SELECT p.entity, ROUND((p.production_2020 - p.production_2015), 10) AS total_production_increment, ROUND(((p.production_2020 - p.production_2015)/w.population), 10) AS production_increment_pro_capite
	FROM renewable_energy_production_comparison p
JOIN worlddata2023 w
	ON p.entity = w.Country	
ORDER BY production_increment_pro_capite DESC;

-- Seleziono le 10 nazioni che hanno incrementato di più la produzione totale di energia rinnovabile tra il 2015 e il 2020

SELECT entity, total_production_increment 
	FROM renewable_energy_production_increment
WHERE total_production_increment IS NOT NULL 
LIMIT 10;

-- Seleziono le 10 nazioni che hanno incrementato di più la produzione pro-capite di energia rinnovabile tra il 2015 e il 2020

SELECT entity, production_increment_pro_capite 
	FROM renewable_energy_production_increment
WHERE production_increment_pro_capite IS NOT NULL 
LIMIT 10;

/* Creo una materialized view con all'interno gli stati con la maggior produzione e la rispettiva variazione
di produzione negli ultimi 5 anni di energia rinnovabile */

CREATE MATERIALIZED VIEW renewable_energy_increment_and_production AS
SELECT r.entity, r.renewable_electricity_pro_capite_twh, i.production_increment_pro_capite
	FROM renewable_energy_production_rank r
JOIN renewable_energy_production_increment i
	ON r.entity = i.entity
ORDER BY renewable_electricity_pro_capite_twh DESC; 

SELECT * FROM renewable_energy_increment_and_production
	LIMIT 10;
