SET sql_mode = '';

#modificando a tabela 
SELECT * FROM fish_detail;
ALTER TABLE fish_detail ADD COLUMN Behaviour VARCHAR(255);
UPDATE fish_detail 
SET Behaviour = SUBSTRING_INDEX(DifficultyBehavior, ' ', -1);

ALTER TABLE fish_detail ADD COLUMN Difficulty INTEGER;
UPDATE fish_detail 
SET Difficulty = SUBSTRING_INDEX(DifficultyBehavior,' ',1);

ALTER TABLE fish_detail DROP COLUMN DifficultyBehavior;

#adicionando primary key
ALTER TABLE fish_detail ADD COLUMN id INTEGER AUTO_INCREMENT,
ADD PRIMARY KEY (id);

#analisando os dados

SELECT Weather, COUNT(Weather) AS CountWeather FROM fish_detail 
GROUP BY Weather
ORDER BY CountWeather DESC;

SELECT Behaviour, COUNT(Behaviour) AS CountBehaviour FROM fish_detail 
GROUP BY Behaviour
ORDER BY CountBehaviour DESC;

SELECT 
  ((SUBSTRING_INDEX(Size, "-", 1) + SUBSTRING_INDEX(Size, "-", -1)) / 2) AS MeanSize,
  CASE 
    WHEN ((SUBSTRING_INDEX(Size, "-", 1) + SUBSTRING_INDEX(Size, "-", -1)) / 2) < 10 
         THEN ROUND(AVG(XP),2)
    WHEN ((SUBSTRING_INDEX(Size, "-", 1) + SUBSTRING_INDEX(Size, "-", -1)) / 2) BETWEEN 10 AND 19
         THEN ROUND(AVG(XP),2)
    WHEN ((SUBSTRING_INDEX(Size, "-", 1) + SUBSTRING_INDEX(Size, "-", -1)) / 2) BETWEEN 20 AND 29
         THEN ROUND(AVG(XP),2)
    WHEN ((SUBSTRING_INDEX(Size, "-", 1) + SUBSTRING_INDEX(Size, "-", -1)) / 2) >= 30
         THEN ROUND(AVG(XP),2)
  END AS MeanXP
FROM fish_detail
GROUP BY MeanSize
ORDER BY MeanSize;

SELECT a.Recipes, b.Quests, c.Love_Gifts FROM
(SELECT id, COUNT(UsedIn) AS Recipes 
FROM fish_detail
WHERE UsedIn NOT IN ("No Uses")) a 
JOIN 
(SELECT id, COUNT(UsedIn) AS Quests
FROM fish_detail 
WHERE UsedIn LIKE "%Quest%") b 
ON a.id = b.id
JOIN
(SELECT id, COUNT(UsedIn) AS Love_Gifts 
FROM fish_detail
WHERE UsedIn LIKE "%Love%") c
ON b.id = c.id