/*
Data Source:
	https://www.kaggle.com/datasets/sadeghjalalian/nba-player-stats-19982022/versions/1?resource=download
*/
USE nba;
-- Change the name of the table and check if nba table is successfully imported
ALTER TABLE nba_player_stats
RENAME AS nba_table;
SELECT * FROM nba_table LIMIT 10;

-- Check the data column types
SELECT
	COLUMN_NAME,
    DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE
	table_schema = 'nba' and table_name ='nba_table';

-- Check if there is any null value in certain cols
SELECT
    SUM(CASE WHEN Player IS NULL OR Player = 'N/A' THEN 1 ELSE 0 END) AS player_null
  , SUM(CASE WHEN Pos IS NULL OR Pos = 'N/A' THEN 1 ELSE 0 END) AS pos_null
  , SUM(CASE WHEN Tm IS NULL OR Tm = 'N/A' THEN 1 ELSE 0 END) AS team_null 
  , SUM(CASE WHEN Age IS NULL OR Age = 'N/A' THEN 1 ELSE 0 END) AS age_null
  , SUM(CASE WHEN G IS NULL OR G = 'N/A' THEN 1 ELSE 0 END) AS game_null
  , SUM(CASE WHEN MP IS NULL OR MP = 'N/A' THEN 1 ELSE 0 END) AS minute_null
  , SUM(CASE WHEN Year IS NULL OR Year = 'N/A' THEN 1 ELSE 0 END) AS year_null
  , SUM(CASE WHEN PTS IS NULL OR PTS = 'N/A' THEN 1 ELSE 0 END) AS points_null
FROM nba_table;

-- Check what caused a missing value or NULL
SELECT *
FROM nba_table
WHERE PTS IS NULL OR PTS ='N/A';

SELECT *
FROM nba_table
WHERE MP IS NULL OR MP ='N/A';
/*
Players do not have any points due to their limited playing time of less than 20 minutes in total in the NBA league.
As their statistics could potentially skew our analysis, we will exclude them from our study to ensure accurate results.
Furthermore, we will opt to exclude players who have participated in fewer than 82 games. (82 being the total number of NBA games in a single season per team.)
*/
-- Creating a new table with only players who played more than 82 games
CREATE TABLE nba_table_clean AS (
	SELECT
		t1.*
	FROM nba_table t1
	INNER JOIN (
		SELECT Player
		FROM nba_table 
		GROUP BY Player
		HAVING SUM(G) > 20 AND SUM(MP) > 24
	) t2 ON t1.Player = t2.Player
);
/*
Certain players have had limited opportunities to showcase their skills due to insufficient playing time.
Consequently, their statistical performance may not accurately reflect their abilities.
Taking this into account, it is prudent to exclude players who have participated in fewer than 20 games or
played less than 24 minutes in three seasons from our analysis.
*/

/*
DATA ANALYSIS

1. Player Identification:
	1-1. Who are the leading scorers, assisters, shot blockers, three-point scorers, steal leaders, and rebounders?
	1-2. Who is the youngest and oldest player in the league?
    1-3. Which players have participated in the highest number of games?

2. Common Traits Among Elite Players:
	2-1. Giannis Antetokounmpo, Stephen Curry, Nikola Jokic, and LeBron James are among the renowned stars who epitomize the league's excellence.

3. Team Performance Assessment:
	3-1. Which team holds the highest potential for success based on its players?
*/
CREATE  TABLE nba_by_player AS(
	SELECT
		Player
	  , Tm
	  , MAX(POS) as position
	  , ROUND(AVG(G),0) AS avg_game
      , ROUND(AVG(MP),1) AS minute
      , ROUND(AVG(FG),1) AS field_goal
      , ROUND(AVG(FT),1) AS freethrow
      , ROUND(AVG(2p),2) AS two_point
      , ROUND(AVG(3p),2) AS three_point
      , ROUND(AVG(TRB),1) AS rebound
      , ROUND(AVG(AST),1) AS assist
      , ROUND(AVG(STL),1) AS steal
      , ROUND(AVG(BLK),1) AS block_stat
      , ROUND(AVG(TOV),1) AS turnover
      , ROUND(AVG(PTS),1) AS point
      , COUNT(Year) AS season
	FROM nba_table_clean
	GROUP BY Player, Tm
);
SELECT * FROM nba_table_clean where Player ="Lebron James";

-- 1.1 Who are the leading scorers, assisters, shot blockers, three-point scorers, steal leaders, and rebounders?
-- scorer
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , field_goal
      , ROUND( (two_point * avg_game * season)+(three_point * avg_game * season),0) AS total_field_goal
      , season
	FROM nba_by_player)
SELECT
	Player
  , ROUND( AVG(field_goal),2) AS avg_field_goal_per_game
  , SUM(total_field_goal) AS total_field_goal
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_field_goal DESC
LIMIT 5;
-- assister
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , assist
      , ROUND( (assist * avg_game * season),0) AS total
      , season
	FROM nba_by_player)
SELECT
	Player
  , SUM(total) AS total_assist
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_assist DESC
LIMIT 5;

-- blocker
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , block_stat
      , ROUND( (block_stat * avg_game * season),0) AS total
      , season
	FROM nba_by_player)
SELECT
	Player
  , SUM(total) AS total_block
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_block DESC
LIMIT 5;

-- three point scorer
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , three_point
      , ROUND( (three_point * avg_game * season),0) AS total
      , season
	FROM nba_by_player)
SELECT
	Player
  , SUM(total) AS total_three_point
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_three_point DESC
LIMIT 5;

-- Stealer
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , steal
      , ROUND( (steal * avg_game * season),0) AS total
      , season
	FROM nba_by_player)
SELECT
	Player
  , SUM(total) AS total_steal
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_steal DESC
LIMIT 5;

-- Rebounder    
WITH total_goal AS (
	SELECT
		Player
      , avg_game
	  , rebound
      , ROUND( (rebound * avg_game * season),0) AS total
      , season
	FROM nba_by_player)
SELECT
	Player
  , SUM(total) AS total_rebound
  , SUM(season) AS season_played
FROM total_goal
GROUP BY Player
ORDER BY total_rebound DESC
LIMIT 5;

/*
Players who consistently score the most points or deliver standout performances are often referred to as league superstars.
In the timeframe covered by our dataset, several players have earned this designation,
including iconic figures such as Michael Jordan, Kobe Bryant, LeBron James, Giannis Antetokounmpo, and Stephen Curry.
LeBron James stands out as the leading scorer, averaging an impressive 9.9 goals per game over a remarkable 19-season career,aligning with this expectation.

Notably, guards, who typically handle the ball and facilitate their teammates' play, tend to have higher assist statistics than players in other positions.
Jason Kidd, a point guard, has a record of 11080 assists over his illustrious 18-year career, also aligning with this expectation.

Tim Duncan distinguished himself by blocking with 3051 blocks in 19 seasons.

It is Ray Allen who still has a crown of the most three-point made player with 3052 three-pointers in 19 season.
Stephen Curry's ability to sink multiple three-pointers in a single game transformed the playing style of NBA teams.
Over his 13 seasons, Stephen Curry consistently averaged 3.6 successful three-pointers per game and ranked in second.
Given this significant impact, it is reasonable to assume that Curry will leads the league in three-point shooting soon.

Meanwhile, Chris Paul recorded 2.1 steals per game during his 17-year career, accumulating a total of 2,431 steals.

Tim Duncan's rebounding prowess is particularly noteworthy, as he recorded 14980 rebounds  during his 19 seasons in the league.

Given that the data spans from 1988 to 2022, it's important to note that the identified statistical leaders may not necessarily be the definitive leaders,
leading us to consider whether individuals such as Michael Jordan or Kareem Abdul-Jabbar should also be taken into account.
*/

-- 1-2. Who is the youngest and oldest player in the league in 2022 and in history?
-- Only 2021-2022 season
WITH age_table AS (
    SELECT
        DISTINCT(Player),
        Age
    FROM nba_table
    WHERE Year = '2021-2022'
)
SELECT
    Player
  , Age
FROM age_table
WHERE Age = (SELECT MIN(Age) FROM age_table)
UNION
SELECT
    Player
  , Age
FROM age_table
WHERE Age = (SELECT MAX(Age) FROM age_table);
/*
During the 2021-2022 NBA seasons, there were 11 players who entered the league at the age of 19, making them the youngest players at the time.
Conversely, Udonis Haslem held the distinction of being the oldest player in the league at the age of 41.

Usman Garuba - 19
Josh Giddey - 19
Jalen Green - 19
Keon Johnson - 19
Jonathan Kuminga - 19
Moses Moody - 19
Daishen Nix - 19
Joshua Primo - 19
Alperen Sengun - 19
Jaden Springer - 19
JT Thor	- 19
Udonis Haslem - 41
*/
-- Only 2021-2022 season
WITH age_table AS (
    SELECT
        DISTINCT(Player),
        Age
    FROM nba_table
)
SELECT
    Player
  , Age
FROM age_table
WHERE Age = (SELECT MIN(Age) FROM age_table)
UNION
SELECT
    Player
  , Age
FROM age_table
WHERE Age = (SELECT MAX(Age) FROM age_table);
/*
Between 1988 and 2022, there was only one age for the youngest NBA players, which was 18 years old. Ten players made their NBA debuts at this age.
Remarkably, among these players, Tracy McGrady and C.J. Miles stood out as they achieved great success in the league,
eventually becoming some of the best players in its history.
In contrast, Kevin Willis holds the record for being the oldest NBA player, having played in the league at the age of 44.
To put this in perspective, as of 2022, Willis is three years older than Udonis Haslem, who is 41 years old.

Tracy McGrady - 18
Al Harrington - 18
Bruno sundov - 18
Maciej Lampe - 18
Darko Milicic - 18
Andris Biedrins - 18
Andrew Bynum - 18
Amir Johnson - 18
Yaroslav Korolev - 18
C.J. Miles - 18
Kevin Willis - 44
*/

-- 1-3. Which players have participated in the highest number of games?
SELECT
	Player
  , SUM(G) AS total_game_played
  , SUM(GS) AS total_game_start
FROM nba_table
GROUP BY Player
ORDER BY total_game_played DESC
LIMIT 10;

/*
To maximize their number of appearances in games, players need to either excel as superstars or demonstrate outstanding proficiency in a specific skill,such as being a sharpshooter from beyond the three-point line.

Among the top 10 players with the most game appearances, all of them fall into one of three categories: they are either the cornerstone superstars of their respective franchises,
renowned for their exceptional three-point shooting abilities, or highly regarded as versatile and impactful sixth men coming off the bench.

Vince Carter
Andre Miller
Dirk Nowitzki
Joe Johnson
Kyle Korver
Jason Terry
Tim Duncan
Jamal Crawford
Nazr Mohammed
LeBron James
*/

-- 2. Common Traits Among Elite Players:
-- 2-1. Giannis Antetokounmpo, Stephen Curry, Nikola Jokic, and LeBron James are among the renowned stars who epitomize the league's excellence.
WITH player_rank AS (
SELECT
    Player
  , minute
  , RANK() OVER (ORDER BY minute DESC) AS minute_rank
  , point
  , RANK() OVER (ORDER BY point DESC) AS points_rank
  , assist
  , RANK() OVER (ORDER BY assist DESC) AS assist_rank
  , rebound
  , RANK() OVER (ORDER BY rebound DESC) AS rebound_rank
  , steal
  , RANK() OVER (ORDER BY steal DESC) AS steal_rank
  , block_stat
  , RANK() OVER (ORDER BY block_stat DESC) AS block_rank
FROM
    nba_by_player
)
SELECT *
FROM player_rank
WHERE
    Player IN (
        'LeBron James'
	  , 'Giannis Antetokounmpo'
	  , 'Vince Carter'
	  , 'Dirk Nowitzki'
	  , 'Tim Duncan'
	  , 'Chris Paul'
	  , 'Kobe Bryant'
	  , 'Stephen Curry'
	  , 'Kevin Durant'
	  , 'Anthony Davis'
      , 'Steve Nash'
      , 'Michael Jordan'
    );
/*
Out of the 12 players, excluding Drik Nowitzki and Vince Carter, a total of 10 players achieved rankings within the top 10 in a particular category.
Out of the ten players, eight displayed performance that placed them within the top 15 in two or more categories.

Among them, LeBron James and Anthony Davis excelled by ranking within the top 15 in three different areas.
Moreover, only LeBron James and Chris Paul achieved top-5 rankings in two separate categories during their careers.

Although performance statistics alone cannot definitively determine a player's greatness, they serve as indicative measures.
Many people have regarded LeBron James as the best player over the past 15 years, and this data further substantiates that assertion.
*/

WITH player_rank AS (
SELECT
    Player
  , minute
  , RANK() OVER (ORDER BY minute DESC) AS minute_rank
  , point
  , RANK() OVER (ORDER BY point DESC) AS points_rank
  , assist
  , RANK() OVER (ORDER BY assist DESC) AS assist_rank
  , rebound
  , RANK() OVER (ORDER BY rebound DESC) AS rebound_rank
  , steal
  , RANK() OVER (ORDER BY steal DESC) AS steal_rank
  , block_stat
  , RANK() OVER (ORDER BY block_stat DESC) AS block_rank
FROM
    nba_by_player
)
SELECT *,
    (IF(minute_rank < 5, 1, 0) +
     IF(points_rank < 5, 1, 0) +
     IF(assist_rank < 5, 1, 0) +
     IF(rebound_rank < 5, 1, 0) +
     IF(steal_rank < 5, 1, 0) +
     IF(block_rank < 5, 1, 0)
    ) AS top_5
    ,
    (IF(minute_rank < 10, 1, 0) +
     IF(points_rank < 10, 1, 0) +
     IF(assist_rank < 10, 1, 0) +
     IF(rebound_rank < 10, 1, 0) +
     IF(steal_rank < 10, 1, 0) +
     IF(block_rank < 10, 1, 0)
    ) AS top_10
    ,
    (IF(minute_rank < 15, 1, 0) +
     IF(points_rank < 15, 1, 0) +
     IF(assist_rank < 15, 1, 0) +
     IF(rebound_rank < 15, 1, 0) +
     IF(steal_rank < 15, 1, 0) +
     IF(block_rank < 15, 1, 0)
    ) AS top_15
FROM player_rank
ORDER BY top_15 DESC, top_10 DESC, top_5 DESC;
/*
Among the players who rank in the top 10 for two distinct attributes, we observe a distribution of five point guards, one shooting guard, one small forward, and three centers.
Point guards tend to excel in categories like steals and assists, while centers showcase their prowess in blocking and rebounding.

Conversely, small forwards and shooting guards are often perceived as versatile players who contribute across various aspects of the game.
Consequently, they have a greater likelihood of being recognized as league superstars. Balancing their individual statistics to support their reputation can be more challenging for these players.

LeBron James and Kobe Bryant stand out as exceptional cases.
Not only are they celebrated as league superstars, but their impressive statistical performances also reinforce their prominence and popularity within the basketball community.
*/

SELECT * FROM nba_by_player;

-- 3-1. Which team holds the highest potential for success based on its players?
CREATE TEMPORARY TABLE nba_by_player_2022 AS(
	SELECT
		Player
	  , Tm
	  , MAX(POS) as position
	  , ROUND(AVG(G),0) AS avg_game
      , ROUND(AVG(MP),1) AS minute
      , ROUND(AVG(FG),1) AS field_goal
      , ROUND(AVG(FT),1) AS freethrow
      , ROUND(AVG(2p),1) AS two_point
      , ROUND(AVG(3p),1) AS three_point
      , ROUND(AVG(TRB),1) AS rebound
      , RANK() OVER (ORDER BY ROUND(AVG(TRB),1) DESC) AS rebound_rank
      , ROUND(AVG(AST),1) AS assist
      , RANK() OVER (ORDER BY ROUND(AVG(AST),1) DESC) AS assist_rank
      , ROUND(AVG(STL),1) AS steal
      , RANK() OVER (ORDER BY ROUND(AVG(STL),1) DESC) AS steal_rank
      , ROUND(AVG(BLK),1) AS block_stat
      , RANK() OVER (ORDER BY ROUND(AVG(BLK),1) DESC) AS block_rank
      , ROUND(AVG(TOV),1) AS turnover
      , ROUND(AVG(PTS),1) AS point
      , RANK() OVER (ORDER BY ROUND(AVG(PTS),1) DESC) AS points_rank
      , (IF(RANK() OVER (ORDER BY ROUND(AVG(PTS),1) DESC) < 25, 1, 0) +
         IF(RANK() OVER (ORDER BY ROUND(AVG(TRB),1) DESC) < 25, 1, 0) +
         IF(RANK() OVER (ORDER BY ROUND(AVG(AST),1) DESC) < 25, 1, 0) +
         IF(RANK() OVER (ORDER BY ROUND(AVG(STL),1) DESC) < 25, 1, 0) +
         IF(RANK() OVER (ORDER BY ROUND(AVG(BLK),1) DESC) < 25, 1, 0)
        ) AS top_25
	FROM nba_table_clean
    WHERE Year = '2021-2022'
	GROUP BY Player, Tm, Age
);

SELECT * FROM nba_by_player_2022 ORDER BY Player;


SELECT
    t1.Tm,
    t1.Player,
    t2.players
FROM nba_by_player_2022 t1
JOIN (
    SELECT Tm, COUNT(Tm) as players
    FROM (
        SELECT DISTINCT Tm, Player
        FROM nba_by_player_2022
        WHERE top_25 > 1
    ) AS player_table
    GROUP BY Tm
) t2
ON t1.Tm = t2.Tm;

drop table nba_by_player_2022;

SELECT
	t1.Tm
  , t1.Player
  , t2.players
FROM nba_by_player_2022 t1
JOIN (SELECT
	Tm
  , COUNT(Player) as players
FROM nba_by_player_2022
WHERE top_25> 1
GROUP BY Tm
) t2
on t1.Tm =t2.Tm
WHERE top_25> 1
ORDER BY t1.tm,t2.players DESC;