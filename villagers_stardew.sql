SELECT * FROM villagers;

SELECT Gender,COUNT(Gender) AS "Qtd" 
FROM villagers
GROUP BY Gender;

SELECT Villager, Gender 
FROM villagers 
WHERE Gender = "N/A";

SELECT Gender, COUNT(MarriageCandidate) AS "Candidatos a casamento" 
FROM villagers
WHERE MarriageCandidate = "Yes"
GROUP BY Gender;

SELECT COUNT(Giftable) AS "NPCs fora da Vila" 
FROM villagers 
WHERE Giftable = "No" ;
SElECT (SUM(HeartEvents)/NULLIF(COUNT(CASE WHEN HeartEvents <> 0 THEN 1 END), 0)) AS AVGHeartEvent
FROM villagers;

SELECT * FROM birthdays;

CREATE TEMPORARY TABLE tempMonth AS(
										WITH b AS (
											SELECT Villager, SUBSTR(Birthday, 4) AS mnth
											FROM birthdays
											WHERE Birthday <> "Unknown") 
										SELECT a.Villager, b.mnth  
										FROM villagers a
										JOIN b ON a.Villager = b.Villager);

SELECT Villager,
CASE mnth  
	WHEN "jan" THEN "capricornio"
	WHEN "fev" THEN "aquário"
	WHEN "mar" THEN "peixes"
	WHEN "abr" THEN "áries"
	WHEN "mai" THEN "touro"
	WHEN "jun" THEN "gêmeos"
	WHEN "jul" THEN "câncer"
	WHEN "ago" THEN "leão"
	WHEN "set" THEN "virgem"
	WHEN "out" THEN "libra"
	WHEN "nov" THEN "escorpião"
	WHEN "dez" THEN "sagitário"
END AS signo
FROM tempMonth;

SELECT 
CASE tempMonth.mnth  
		WHEN 'jan' THEN 'capricornio'
		WHEN 'fev' THEN 'aquário'
		WHEN 'mar' THEN 'peixes'
		WHEN 'abr' THEN 'áries'
		WHEN 'mai' THEN 'touro'
		WHEN 'jun' THEN 'gêmeos'
		WHEN 'jul' THEN 'câncer'
		WHEN 'ago' THEN 'leão'
		WHEN 'set' THEN 'virgem'
		WHEN 'out' THEN 'libra'
		WHEN 'nov' THEN 'escorpião'
		WHEN 'dez' THEN 'sagitário'
END AS signo,
AVG(villagers.HeartEvents) AS "Média de Corações"
FROM tempMonth
JOIN villagers ON villagers.Villager = tempMonth.Villager
GROUP BY signo
ORDER BY AVG(villagers.HeartEvents) DESC

