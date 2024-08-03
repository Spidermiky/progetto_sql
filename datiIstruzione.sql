-- ANALISI DATI SULL'ISTRUZIONE

-- Filtro i dati relativi all'istruzione

CREATE MATERIALIZED VIEW education_data AS
SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc, 
	   unemployment_rate, minimum_wage_in_dollars, labor_force_participation_perc 
	FROM worlddata2023
ORDER BY country ASC;

SELECT * FROM education_data;

SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc
	FROM education_data
WHERE gross_primary_education_enrollment_perc IS NOT NULL AND gross_tertiary_education_enrollment_perc IS NOT NULL 
ORDER BY gross_tertiary_education_enrollment_perc DESC;

SELECT CORR(gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc) FROM education_data;

/* Si nota subito come nella maggior parte degli stati l'iscrizione alla 'primary education' non si rispecchi poi 
un alto tasso di iscrzione alla 'tertiary education' */

SELECT country, gross_primary_education_enrollment_perc
	 FROM education_data 
WHERE gross_primary_education_enrollment_perc IS NOT NULL
ORDER BY gross_primary_education_enrollment_perc DESC;

SELECT CORR(gross_primary_education_enrollment_perc, minimum_wage_in_dollars) FROM education_data;

/* Molti, ma non tutti, paesi del terzo mondo hanno dei numeri molto alti nel 'primary education enrollment' probabilmente inflazionati dalle stime che avvengono
senza tener conto dell'inizio in anticipo di alcuni bambini, di eventuali ripetenti o iscrizioni in età tardiva; 
oppure più semplicemente quando le iscrizioni effettive negli istituti scolastici eccedono i numeri stimati di bambini in età scolastica 'giusta' */
	
SELECT country, gross_tertiary_education_enrollment_perc, minimum_wage_in_dollars
	 FROM education_data 
WHERE gross_tertiary_education_enrollment_perc IS NOT NULL
ORDER BY gross_tertiary_education_enrollment_perc DESC;

/* Controllo la correlazione tra un alto livello di istruzione terziaria e lo stipendio medio della nazione, 
purtoppo questi dati non srisultano completi essendoci molti dati mancanti nella colonna 'minimum_wage_in_dollars' */

SELECT CORR(gross_tertiary_education_enrollment_perc, minimum_wage_in_dollars) FROM education_data;

-- Controllo il valore massimo, il minimo e il valore medio della colonna 'minimum_wage_in_dollars'

SELECT MIN(gross_tertiary_education_enrollment_perc) FROM worlddata2023;
SELECT MAX(gross_tertiary_education_enrollment_perc) FROM worlddata2023;
SELECT AVG(gross_tertiary_education_enrollment_perc) FROM worlddata2023;

/* Creo una vista che contiene una colonna che indica se la nazione ha un livello di istruzione alto, medio o basso. Scaglioni ricavati da una partizione
della distribuzione avvenuta attraverso i valori precedentemente ricavati */
	
CREATE VIEW education_level_by_nation AS
SELECT country, gross_tertiary_education_enrollment_perc,
	CASE
 		WHEN gross_tertiary_education_enrollment_perc >= 75 THEN 'Alto livello di istruzione'
		WHEN gross_tertiary_education_enrollment_perc >= 25 THEN 'Medio livello di istruzione'
		ELSE 'Basso livello di istruzione'
	END AS National_educational_level
FROM education_data
WHERE gross_tertiary_education_enrollment_perc IS NOT NULL  
ORDER BY gross_tertiary_education_enrollment_perc DESC;

-- Controllo la numerosità dei 3 scaglioni

SELECT National_educational_level, COUNT(National_educational_level) 
	FROM education_level_by_nation
GROUP BY National_educational_level;

-- Guardo se c'è correlazione tra il livello di istruzione e la produzione pro-capite di energia rinnovabile

CREATE VIEW education_and_renewable_energy_production AS
SELECT e.country, e.gross_tertiary_education_enrollment_perc, r.renewable_electricity_pro_capite_twh
	FROM education_data e
JOIN renewable_energy_increment_and_production r
	ON e.country = r.entity;

SELECT * FROM education_and_renewable_energy_production;

SELECT CORR(gross_tertiary_education_enrollment_perc, renewable_electricity_pro_capite_twh) AS correlation_edLevel_and_renEnergyProd
	FROM education_and_renewable_energy_production;
