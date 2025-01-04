SELECT
	*
FROM
	SpotifyProject..Spotify

-- 1. Selecciona todas las canciones que tengan a partir de un millon de reproducciones.
SELECT
	artist,
	track,
	Stream
FROM
	SpotifyProject..Spotify
WHERE
	Stream IS NOT NULL AND Stream >= 1000000
ORDER BY
	Stream DESC


-- 2. List all albums along with their respective artists.
SELECT 
    DISTINCT album, 
    artist
FROM 
    SpotifyProject..Spotify
ORDER BY 
    artist, album

-- 3. Contar todos los comentarios de las canciones con licencia TRUE
SELECT
	SUM(ISNULL(comments, 0)) AS Total_Comments_Licensed_True
FROM
	SpotifyProject..Spotify
WHERE
	Licensed = 'TRUE'


-- 4. Mostrar todas las canciones que sean SINGLES
SELECT
	Artist,
	Track
FROM
	SpotifyProject..Spotify
WHERE
	Album_type = 'single'

-- 5. Contar la cantidad de canciones por artista
SELECT
	Artist,
	COUNT(*) AS Total_Tracks
FROM
	SpotifyProject..Spotify
GROUP BY
	Artist
ORDER BY
	Artist DESC;

-- Otra alternativa
SELECT
	Artist,
	COUNT(*) OVER(PARTITION BY Artist) AS Total_Tracks
FROM
	SpotifyProject..Spotify
ORDER BY
	Artist ASC


-- 6. Calcular el promedio de 'bailabilidad' de los tracks de cada album.
SELECT
	Artist,
	Album,
	AVG(CAST(Danceability as float)) as AVG_Danceability
FROM
	SpotifyProject..Spotify
Group BY
	Artist, Album
ORDER BY
	AVG_Danceability DESC
	

-- 7. Mostrar el TOP 5 de canciones con mayor ENERGIA
SELECT
	Artist,
	Track,
	CAST(Energy as FLOAT) as Energy
FROM
	SpotifyProject..Spotify
ORDER BY
	CAST(Energy as FLOAT) DESC


-- 8. Mostrar las canciones con sus vistas y likes donde su oficial video sea TRUE
SELECT
	Track,
	Views,
	Likes
FROM
	SpotifyProject..Spotify
WHERE	
	official_video = 'TRUE'


-- 9. Por cada album, sumar las views de cada track.
SELECT
	Album,
	SUM(Views) AS Views
FROM
	SpotifyProject..Spotify
GROUP BY
	Album
ORDER BY
	SUM(Views) DESC

-- 10. Muestra las canciones que se reprodujeron más en Spotify que en Youtube
SELECT
	Track
FROM
	SpotifyProject..Spotify
WHERE	
	most_playedon = 'Spotify'


-- Advanced Level
-- 11. Muestra el TOP 3 de las canciones más escuchadas por Artista usando Window Functions
SELECT
    Artist,
    Track,
    Views
FROM (
    SELECT
        Artist,
        Track,
        Views,
        ROW_NUMBER() OVER (PARTITION BY Artist ORDER BY Views DESC) AS row_num
    FROM
        SpotifyProject..Spotify
) AS ranked_tracks
WHERE
    row_num <= 3
ORDER BY
    Artist,
    row_num;


-- 12. Escribe una query para encontrar las canciones donde el Liveness sea mayor al promedio
WITH Average_Liveness AS (
	SELECT
		AVG(CAST(Liveness as float)) as AVG_Liveness
	FROM
		SpotifyProject..Spotify
),
Tracks AS (
	SELECT	
		Track,
		Liveness
	FROM
		SpotifyProject..Spotify
)
SELECT
	tr.Track,
	tr.Liveness,
	al.AVG_Liveness
FROM
	Tracks tr
CROSS JOIN
	Average_Liveness al
WHERE
	tr.Liveness > al.AVG_Liveness
ORDER BY
	tr.Liveness

-- Otra alternativa
WITH Average_Liveness AS (
    SELECT
        AVG(CAST(Liveness AS float)) AS AVG_Liveness
    FROM
        SpotifyProject..Spotify
)
SELECT
    Track,
    Liveness
FROM
    SpotifyProject..Spotify
WHERE
    Liveness > (SELECT AVG_Liveness FROM Average_Liveness)
ORDER BY
    Liveness DESC;

-- 13. Usando WITH calcula la diferencia entre la Energía mayor y menor de los tracks de cada album.
WITH Energy_Stats AS (
    SELECT
        Album,
        MAX(Energy) AS Max_Energy,
        MIN(Energy) AS Min_Energy
    FROM
        SpotifyProject..Spotify
    GROUP BY
        Album
)
SELECT
    es.Album,
    es.Max_Energy - es.Min_Energy AS Energy_Difference
FROM
    Energy_Stats es
ORDER BY
    Energy_Difference DESC;