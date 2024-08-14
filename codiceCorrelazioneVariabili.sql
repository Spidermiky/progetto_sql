-- Guardo se c'è correlazione tra il livello di istruzione e la produzione pro-capite di energia rinnovabile

SELECT e.country, e.gross_tertiary_education_enrollment_perc, r.renewable_electricity_pro_capite_twh
	FROM education_data e
JOIN renewable_energy_increment_and_production r
	ON e.country = r.entity
ORDER BY r.renewable_electricity_pro_capite_twh DESC;

SELECT CORR(e.gross_tertiary_education_enrollment_perc, r.renewable_electricity_pro_capite_twh)
	FROM education_data e
JOIN renewable_energy_increment_and_production r
	ON e.country = r.entity;

-- Guardo se c'è correlazione tra il livello di istruzione e l'incremento di produzione pro-capite di energia rinnovabile

SELECT e.country, e.gross_tertiary_education_enrollment_perc, i.production_increment_pro_capite
	FROM education_data e
JOIN renewable_energy_production_increment i
	ON e.country = i.entity
WHERE i.production_increment_pro_capite IS NOT NULL
ORDER BY i.production_increment_pro_capite DESC;

SELECT CORR(e.gross_tertiary_education_enrollment_perc, i.production_increment_pro_capite)
	FROM education_data e
JOIN renewable_energy_production_increment i
	ON e.country = i.entity;

-- Guardo se c'è correlazione tra il livello di istruzione e l'apettativa di vita del paese

SELECT e.country, e.gross_tertiary_education_enrollment_perc, s.life_expectancy
	FROM education_data e
JOIN sanity_data s
	USING (country)
WHERE e.gross_tertiary_education_enrollment_perc IS NOT NULL
ORDER BY s.life_expectancy;

SELECT CORR(e.gross_tertiary_education_enrollment_perc, s.life_expectancy)
	FROM education_data e
JOIN sanity_data s
	USING (country);

-- Guardo se c'è correlazione tra il salario minimo e la out of pocket expenditure

SELECT s.country, s.out_of_pocket_health_expenditure, e.minimum_wage_in_dollars
	FROM sanity_data s
JOIN education_data e
	USING (country)
WHERE e.minimum_wage_in_dollars IS NOT NULL AND s.out_of_pocket_health_expenditure IS NOT NULL
ORDER BY s.out_of_pocket_health_expenditure DESC;

-- Da un primo sguardo ai risultati si presume una correlazione negativa tra le due variabili, riflessa nell'output della query che segue

SELECT CORR(s.out_of_pocket_health_expenditure, e.minimum_wage_in_dollars)
	FROM sanity_data s
JOIN education_data e
	USING (country);

