
-- VISUALIZANDO TODA A TABELA 
SELECT * FROM portifolio_anime.tb_anime;

-- ADICIONANDO ID NA TABELA
ALTER TABLE tb_anime 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;


-- CONTANDO QUANTOS ANIMES ESTAO CLASSIFICADOS NA TABELA
SELECT COUNT(Rating) AS NumberAnime FROM portifolio_anime.tb_anime;

-- CRIANDO UMA PROCEDURE PARA SEPARAR OS GENEROS DE CADA ANIME
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ExtractGens`()
BEGIN
    DECLARE maxGenres INT;
    DECLARE currentAnime VARCHAR(255);
    DECLARE currentGenre VARCHAR(255);
    DECLARE idTemp INT;
    DECLARE i INT;
	DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE row_cursor CURSOR FOR 
        SELECT MAX(id) AS id, Anime, Genre FROM tb_anime GROUP BY Anime, Genre;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    
    
    DROP TEMPORARY TABLE IF EXISTS tempGenres;

    -- CRIANDO UMA TABELA TEMPORARIA PARA ARMAZENAR OS GENEROS
    CREATE TEMPORARY TABLE tempGenres (
        idTemp INT,
        Anime VARCHAR(255),
        Genre VARCHAR(255)
    );

	-- ABRINDO O CURSOR PARA O LOOP
    OPEN row_cursor;

    row_loop: LOOP
        FETCH row_cursor INTO idTemp, currentAnime, currentGenre;

        IF done THEN
            LEAVE row_loop;
        END IF;

        -- PEGANDO O NUMERO MAXIMO DE GENEROS DE CADA ANIME
        -- PARA ISSO CALCULA-SE O NUMERO DE VIRGULAS + 1 QUE DÁ O TOTAL DE GENEROS
        SELECT MAX(LENGTH(Genre) - LENGTH(REPLACE(Genre, ',', '')) + 1) INTO maxGenres
        FROM tb_anime
        WHERE anime = currentAnime;
		

        SET i = 1;
		
        WHILE i <= maxGenres DO
            SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', i), ',', -1)) INTO currentGenre
            FROM tb_anime
            WHERE anime = currentAnime;
			
            
            
            -- INSERINDO ANIME E O GENERO ATUAL NA TABELA TEMPORARIA 
            INSERT INTO tempGenres (idTemp, Anime, Genre) VALUES (idTemp, currentAnime, currentGenre);
            SET i = i + 1;
        END WHILE;
	
    -- FECHA O LOOP
    
    END LOOP;

    CLOSE row_cursor;

END $$

DELIMITER ;

-- CHAMANDO A PROCEDURE PARA SEPARAR OS GENEROS
CALL ExtractGens();

-- CHAMANDO A TABELA TEMPORARIA PARA VER SE ESTA FUNCIONANDO
SELECT * FROM tempGenres;

-- CONTAGEM DOS GENEROS DE ANIME
SELECT Genre, COUNT(Genre) AS CountingGenres
FROM tempGenres 
WHERE Genre NOT IN ('Animation')
GROUP BY Genre 
ORDER BY CountingGenres DESC;

-- RATING POR GENERO
SELECT temp.Genre, CAST(AVG(anime.Rating) AS DECIMAL(5,2)) AS avgRating
FROM tempGenres temp
JOIN tb_anime anime ON temp.idTemp = anime.id
GROUP BY temp.Genre
ORDER BY avgRating DESC;

-- GENEROS NO ANIME TOP 10
SELECT Anime, Genre 
FROM tb_anime
ORDER BY Rating DESC
LIMIT 10;

-- SELECIONANDO O TOP 10 COM JOIN E OS GENEROS SEPARADOS
SELECT anime.Anime, temp.Genre, anime.Rating, anime.id 
FROM tempGenres temp 
JOIN tb_anime anime ON temp.idTemp = anime.id
JOIN (
	SELECT id
    FROM tb_anime
    ORDER BY Rating DESC
    LIMIT 10
) topAnime ON anime.id = topAnime.id
ORDER BY anime.Rating DESC;

-- CONTANDO OS GENEROS NO TOP 10
SELECT temp.Genre,COUNT(temp.Genre) 
FROM tempGenres temp 
JOIN tb_anime anime ON temp.idTemp = anime.id
JOIN (
	SELECT id
    FROM tb_anime
    ORDER BY Rating DESC
    LIMIT 10
) topAnime ON anime.id = topAnime.id
WHERE temp.Genre NOT IN ('Animation')
GROUP BY temp.Genre;

-- ANIME POR ANO
SELECT SUBSTR(TRIM(REGEXP_REPLACE(Release_date, '[^0-9]', '')), 1, 4) AS releaseDate,
COUNT(id) AS countAnime
FROM tb_anime
GROUP BY releaseDate
ORDER BY releaseDate DESC;

-- TOP 10 ANO COM MAIS ANIME
SELECT SUBSTR(TRIM(REGEXP_REPLACE(Release_date, '[^0-9]', '')), 1, 4) AS releaseDate,
COUNT(id) AS countAnime
FROM tb_anime
GROUP BY releaseDate
ORDER BY countAnime DESC
LIMIT 10;


-- CONTAGEM DE GENERO POR ANO 
SELECT SUBSTR(TRIM(REGEXP_REPLACE(anime.Release_date, '[^0-9]', '')), 1, 4) AS releaseDate,
temp.Genre,
COUNT(temp.Genre) AS countGenre
FROM tb_anime anime
JOIN tempGenres temp ON anime.id = temp.idTemp
GROUP BY releaseDate, temp.Genre
ORDER BY releaseDate DESC;

-- ANO EM QUE O GENERO TEVE SUA MAIOR QUANTIDADE
WITH genres AS (
    SELECT
	SUBSTR(TRIM(REGEXP_REPLACE(anime.Release_date, '[^0-9]', '')), 1, 4) AS releaseDate,
	temp.Genre,
	COUNT(temp.Genre) AS countGenre,
	-- CRIANDO O RANKING DOS GENEROS 
    ROW_NUMBER() OVER (PARTITION BY temp.Genre ORDER BY COUNT(temp.Genre) DESC) AS genreRank
    FROM tb_anime anime
    JOIN tempGenres temp ON anime.id = temp.idTemp
    GROUP BY releaseDate, temp.Genre
)
SELECT releaseDate, Genre, countGenre
FROM genres
WHERE genreRank = 1
ORDER BY countGenre DESC, Genre;


-- CRIANDO AS VIEWS DE ALGUMAS QUERIES PARA FACILITAR O SEU USO 

-- SELECIONANDO ANIME POR ANO
CREATE VIEW view_anime_por_ano AS (
	SELECT SUBSTR(TRIM(REGEXP_REPLACE(Release_date, '[^0-9]', '')), 1, 4) AS releaseDate,
	COUNT(id) AS countAnime
	FROM tb_anime
	GROUP BY releaseDate
	ORDER BY releaseDate DESC);
    
-- SELECIONANDO CONTAGEM DOS GENEROS DE ANIME S/TEMP TABLE
CREATE VIEW view_genero_anime AS (
	 WITH teste AS (
		SELECT id,
			SUM(CASE WHEN Genre LIKE '%Action%' THEN 1 ELSE 0 END) AS actionCount,
			SUM(CASE WHEN Genre LIKE '%Romance%' THEN 1 ELSE 0 END) AS romanceCount,
			SUM(CASE WHEN Genre LIKE '%Adventure%' THEN 1 ELSE 0 END) AS adventureCount,
			SUM(CASE WHEN Genre LIKE '%Comedy%' THEN 1 ELSE 0 END) AS comedyCount,
			SUM(CASE WHEN Genre LIKE '%Fantasy%' THEN 1 ELSE 0 END) AS fantasyCount,
			SUM(CASE WHEN Genre LIKE '%Crime%' THEN 1 ELSE 0 END) AS crimeCount,
			SUM(CASE WHEN Genre LIKE '%Mystery%' THEN 1 ELSE 0 END) AS mysteryCount,
			SUM(CASE WHEN Genre LIKE '%Short%' THEN 1 ELSE 0 END) AS shortCount,
			SUM(CASE WHEN Genre LIKE '%Horror%' THEN 1 ELSE 0 END) AS horrorCount
		FROM tb_anime
		GROUP BY id
	)
	SELECT 
		SUM(CASE WHEN actionCount > 0 THEN 1 ELSE 0 END) AS 'Action',
		SUM(CASE WHEN romanceCount > 0 THEN 1 ELSE 0 END) AS 'Romance',
		SUM(CASE WHEN adventureCount > 0 THEN 1 ELSE 0 END) AS 'Adventure',
		SUM(CASE WHEN comedyCount > 0 THEN 1 ELSE 0 END) AS 'Comedy',
		SUM(CASE WHEN fantasyCount > 0 THEN 1 ELSE 0 END) AS 'Fantasy',
		SUM(CASE WHEN crimeCount > 0 THEN 1 ELSE 0 END) AS 'Crime',
		SUM(CASE WHEN mysteryCount > 0 THEN 1 ELSE 0 END) AS 'Mystery',
		SUM(CASE WHEN horrorCount > 0 THEN 1 ELSE 0 END) AS 'Horror',
		SUM(CASE WHEN shortCount > 0 THEN 1 ELSE 0 END) AS 'Short',
		COUNT(id) AS 'Number Anime'
	FROM teste);

    
  
    


    
