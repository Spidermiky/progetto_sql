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

-- Controllo quali sono i paesi con il maggior numero di dottori ogni 1000 abitanti

SELECT country, physicians_per_thousand 
	FROM sanity_data
WHERE physicians_per_thousand IS NOT NULL
ORDER BY physicians_per_thousand DESC; 

-- Controllo quanto influisce la presenza di dottori sull'aspettativa di vita

SELECT country, life_expectancy, physicians_per_thousand
	FROM sanity_data
WHERE life_expectancy IS NOT NULL AND physicians_per_thousand IS NOT NULL
ORDER BY country;

SELECT CORR(life_expectancy, physicians_per_thousand) FROM sanity_data;

-- Ovviamente la maggior presenza di dottori favorisce una maggiore aspettaiva di vita, ne è la conferma una correlazione pari a 0.7037

/* Controllo la correlazione tra la quantità di froze armate del paese e l'aspettativa di vita per vedere se 
può essere un dato rilevante per l'analisi */

SELECT CORR(life_expectancy, armed_forces_size) AS corr_life_exp_and_armed_forces_size
	FROM worlddata2023;

/* La correlazione è molto vicina allo 0, quindi il dato non risulta rilevante ai fini dell'analisi */