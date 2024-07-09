-- Quali sono i Paesi meglio o peggio piazzati in termini di energia rinnovabile, sanità ed educazione, come queste metriche si sono mosse nel tempo 
-- e se esiste una correlazione tra alcune delle variabili. 


-- POSIZIONE DEI PAESI IN FATTO DI ENERGIA RINNOVABILE

-- guardo quali sono i paesi con la maggiore produzione di energia rinnovabile nel 2020
SELECT entity, electricity_from_renewables_twh
	FROM sustainabledata
	WHERE year = '2020'
ORDER BY electricity_from_renewables_twh DESC;

-- controllo la produzione pro-capite di energia rinnovabile, 
-- così da avere un indicatore pesato sulla popolazione totale che rispecchi maggiormente la posizione dei paesi
SELECT s.entity, s.year, s.electricity_from_renewables_twh,  
	   w.population, ROUND((s.electricity_from_renewables_twh/w.population),10) AS renewable_electricity_pro_capite_twh
	FROM SustainableData s
JOIN worldData2023 w
	ON s.entity = w.Country
WHERE s.year = '2020'
ORDER BY renewable_electricity_pro_capite_twh DESC;





