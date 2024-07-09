-- Quali sono i Paesi meglio o peggio piazzati in termini di energia rinnovabile, sanità ed educazione, come queste metriche si sono mosse nel tempo 
-- e se esiste una correlazione tra alcune delle variabili. 

SELECT * FROM sustainabledata;

-- cambio il tipo della colonna 'electricity_from_renewables_twh' in numeric per utilizzare ORDER BY correttamente
ALTER TABLE sustainabledata
ALTER COLUMN electricity_from_renewables_twh 
TYPE NUMERIC USING electricity_from_renewables_twh::numeric;

SELECT s.entity, s.electricity_from_renewables_twh, s.year, 
	   w.gross_primary_education_enrollment_perc, w.gross_tertiary_education_enrollment_perc
	FROM SustainableData s
JOIN worldData2023 w
	ON s.entity = w.Country
WHERE s.year = '2020'
ORDER BY s.electricity_from_renewables_twh DESC;
