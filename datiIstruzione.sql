-- ANALISI DATI SULL'ISTRUZIONE

-- Filtro i dati relativi all'istruzione

CREATE MATERIALIZED VIEW education_data AS
SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc, 
	   unemployment_rate, minimum_wage_in_dollars, labor_force_participation_perc 
	FROM worlddata2023
ORDER BY country ASC;

SELECT * FROM education_data;

-- Guardo la posizione dei paesi relativa all' education enrollment

SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc
	FROM education_data
WHERE gross_primary_education_enrollment_perc IS NOT NULL AND gross_tertiary_education_enrollment_perc IS NOT NULL 
ORDER BY gross_tertiary_education_enrollment_perc DESC;

SELECT CORR(gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc) 
	FROM education_data;

/* Si nota subito come nella maggior parte degli stati l'iscrizione alla 'primary education' non si rispecchi poi 
un alto tasso di iscrzione alla 'tertiary education' 

Controllo i 10 paesi con maggior 'primary education enrollment' */

SELECT country, gross_primary_education_enrollment_perc
	 FROM education_data 
WHERE gross_primary_education_enrollment_perc IS NOT NULL
ORDER BY gross_primary_education_enrollment_perc DESC
LIMIT 10;

-- Controllo i primi 10 paesi con maggior 'tertiary education enrollment'

SELECT country, gross_tertiary_education_enrollment_perc
	 FROM education_data 
WHERE gross_tertiary_education_enrollment_perc IS NOT NULL
ORDER BY gross_tertiary_education_enrollment_perc DESC
LIMIT 10;

/* Si nota come le due graduatorie non contengano gli stessi paesi, nella prima sono presenti paesi principalemte poveri, nella sedonda invece paesi sviluppati

Molti, ma non tutti, paesi del terzo mondo hanno dei numeri molto alti nel 'primary education enrollment' probabilmente inflazionati dalle stime che avvengono
senza tener conto dell'inizio in anticipo di alcuni bambini, di eventuali ripetenti o iscrizioni in età tardiva; 
oppure più semplicemente quando le iscrizioni effettive negli istituti scolastici eccedono i numeri stimati di bambini in età scolastica 'giusta'

Le supposizioni precendenti vengono confermate dalla correlazione negativa tra il 'minimum_wage_in_dollars' e il 'gross_primary_education_enrollment_perc' */

SELECT CORR(gross_primary_education_enrollment_perc, minimum_wage_in_dollars)
	FROM education_data;

/* Controllo la correlazione tra un alto livello di istruzione terziaria e lo stipendio medio della nazione, 
purtoppo questi dati non srisultano completi essendoci molti dati mancanti nella colonna 'minimum_wage_in_dollars' */

SELECT country, gross_tertiary_education_enrollment_perc, minimum_wage_in_dollars
	 FROM education_data 
WHERE gross_tertiary_education_enrollment_perc IS NOT NULL
ORDER BY gross_tertiary_education_enrollment_perc DESC;

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
	END AS national_educational_level
FROM education_data
WHERE gross_tertiary_education_enrollment_perc IS NOT NULL  
ORDER BY gross_tertiary_education_enrollment_perc DESC;

SELECT country, national_educational_level 
	FROM education_level_by_nation;

-- Controllo la numerosità dei 3 scaglioni

SELECT national_educational_level, COUNT(national_educational_level) 
	FROM education_level_by_nation
GROUP BY national_educational_level;

-- Controllo la relazione tra i livelli di istruzione e forza lavoro del paese

SELECT country, gross_primary_education_enrollment_perc, gross_tertiary_education_enrollment_perc, labor_force_participation_perc 
	FROM education_data
WHERE labor_force_participation_perc IS NOT NULL AND gross_primary_education_enrollment_perc IS NOT NULL
ORDER BY labor_force_participation_perc DESC;

/* Si nota subito come i paesi meno sviluppati, con un 'gross_primary_education_enrollment_perc' alto, 
abbiamo molto alto anche il 'labor_force_participation_perc' */
