create database Indian_Premier_League;
use Indian_Premier_League;

#Update format of date_of_birth
UPDATE players
SET date_of_birth = STR_TO_DATE(date_of_birth,'%d-%m-%Y');

#Alter datatype of date_of_birth 
ALTER TABLE players
MODIFY date_of_birth DATE;

#Q1. Get all team names.
SELECT team_id,team_name from teams;

#Q2. Show complete information for the player whose name is MS Dhoni. 
select * from players 
where player_name = "MS Dhoni";

#Q3. Find player with best strike rate per season
SELECT a.season_id, b.player_name, a.strike_rate AS best_strike_rate
FROM player_statistics a
JOIN players b ON a.player_id = b.player_id
WHERE a.strike_rate = (
    SELECT MAX(c.strike_rate)
    FROM player_statistics c
    WHERE c.season_id = a.season_id
)
ORDER BY a.season_id;

#Q4. Get all umpires with more than 15 years experience
SELECT umpire_id, umpire_name, nationality, experience_years
FROM umpire
WHERE experience_years > 15;

#Q5. Bowlers list
SELECT player_id, player_name
FROM players
WHERE role = 'Bowler';

#Q6. Highest capacity stadium
SELECT * FROM stadium
ORDER BY capacity DESC
LIMIT 1;

#Q7. List All Teams with City and Coach Name 
SELECT team_name,city,coach_name
FROM teams
ORDER BY team_name;

#Q8. List all teams from a specific city:
SELECT team_name, city
FROM teams
WHERE city = 'Delhi';

#Q9. Find total number of players in each team.
SELECT b.team_name,
       COUNT(a.player_id) AS total_players
FROM players a
JOIN teams b
ON a.team_id = b.team_id
GROUP BY b.team_name; 

#Q10. Bottom 3 Run Scorers
SELECT a.player_id, a.player_name,
       SUM(b.total_runs) AS runs
FROM players a
JOIN player_statistics b
    ON a.player_id = b.player_id
GROUP BY a.player_id, a.player_name
ORDER BY runs ASC
LIMIT 3;

#Q11. Who is the oldest player across all seasons?
SELECT player_name, date_of_birth
FROM players
ORDER BY date_of_birth
LIMIT 1;

#Q12. Team wise wins
SELECT a.winner_team_id, b.team_name, COUNT(a.match_id) AS total_wins
FROM matches a
JOIN teams b
ON a.winner_team_id = b.team_id
GROUP BY a.winner_team_id, b.team_name
ORDER BY total_wins DESC; 

#Q13. Players with 0 wickets
SELECT a.player_id,a.player_name,
       SUM(b.total_wickets) AS Total_wickets
FROM player_statistics b
JOIN players a
    ON b.player_id = a.player_id
GROUP BY a.player_id, a.player_name
HAVING SUM(b.total_wickets) = 0;

#Q14. Find the player who won Purple Cap (highest total_wickets overall)
SELECT b.player_id AS Player_id,
       b.player_name AS Player_name,
       SUM(a.total_wickets) AS total_wickets
FROM player_statistics a
JOIN players b
    ON a.player_id = b.player_id
GROUP BY b.player_id, b.player_name
ORDER BY total_wickets DESC
LIMIT 1;

#Q15. Find the player who won Orange Cap (highest total_runs overall)
SELECT b.player_id AS Player_id,
       b.player_name AS Player_name,
       SUM(a.total_runs) AS c_total_runs
FROM player_statistics a
JOIN players b
    ON a.player_id = b.player_id
GROUP BY b.player_id, b.player_name
ORDER BY c_total_runs DESC
LIMIT 1;

#Q16. Running total of runs
SELECT 
    a.player_id,b.player_name,a.total_runs,
    SUM(a.total_runs) OVER (PARTITION BY a.player_id ORDER BY a.season_id) AS running_total
FROM player_statistics a
JOIN players b
ON a.player_id = b.player_id;

#Q17. Captains more than 1 season
SELECT b.player_id,b.player_name,c.team_name,
       COUNT(a.season_id) AS seasons_captained
FROM team_captains a
JOIN players b
    ON a.player_id = b.player_id
JOIN teams c
    ON a.team_id = c.team_id
GROUP BY b.player_id, b.player_name, c.team_name
HAVING COUNT(a.season_id) > 1
ORDER BY seasons_captained DESC;

#Q18. Umpires with above average experience
SELECT umpire_name, experience_years
FROM umpire
WHERE experience_years > (
    SELECT AVG(experience_years) FROM umpire
);

#Q19. Find season with highest total runs
SELECT season_id,
       SUM(total_runs) AS season_runs
FROM player_statistics
GROUP BY season_id
ORDER BY season_runs DESC
LIMIT 1;

#Q20. Find youngest player
SELECT player_id,player_name,date_of_birth
FROM players
ORDER BY date_of_birth DESC
LIMIT 1;

#Q21. Stadium with most matches hosted 
SELECT b.stadium_id AS stadium_id,
       b.stadium_name AS stadium_name,
       COUNT(a.match_id) AS matches_hosted
FROM matches a
JOIN stadium b ON a.stadium_id = b.stadium_id
GROUP BY b.stadium_id, b.stadium_name
ORDER BY matches_hosted DESC
LIMIT 1;

#Q22. Season-wise Orange Cap Winner
SELECT a.season_id,c.year,b.player_id,b.player_name,a.total_runs AS highest_runs
FROM player_statistics a
JOIN players b
    ON a.player_id = b.player_id
JOIN season c
    ON a.season_id = c.season_id
WHERE a.total_runs = (
        SELECT MAX(d.total_runs)
        FROM player_statistics d
        WHERE d.season_id = a.season_id
)
ORDER BY a.season_id;

#Q23. Find matches where toss winner also won match
SELECT a.match_id,
       a.season_id,
       b.toss_winner,
       a.winner_team_id
FROM matches a
JOIN toss_details b
  ON a.match_id = b.match_id
WHERE a.winner_team_id = b.toss_winner
ORDER BY a.season_id;

#Q24. Calculate player impact score (runs0.5 + wickets20).
SELECT 
       b.player_name,a.season_id,a.total_runs,a.total_wickets,
       (a.total_runs * 0.5) + (a.total_wickets * 20) AS impact_score
FROM player_statistics a
JOIN players b
    ON a.player_id = b.player_id
ORDER BY impact_score DESC limit 5;

#Q25. Players in more than 2 seasons
SELECT a.player_id,a.player_name,
       COUNT(DISTINCT b.season_id) AS seasons_played
FROM players a
JOIN player_statistics b
    ON a.player_id = b.player_id
GROUP BY a.player_id, a.player_name
HAVING COUNT(DISTINCT b.season_id) > 2;

#Q26. Count matches per season
SELECT season_id,
       COUNT(match_id) AS total_matches
FROM matches
GROUP BY season_id
ORDER BY season_id;

#Q27. Who won the “Catch of the Season” award in the 2022 season? 
SELECT c.player_name
FROM awards a
JOIN player_statistics b
     ON a.award_id = b.award_id
JOIN players c
     ON b.player_id = c.player_id
JOIN season d
     ON b.season_id = d.season_id
WHERE a.award_name = 'Catch of the Season'
AND d.year = 2022;

#Q28. List Captains and Coaches in One Result
SELECT b.player_name AS name, 'Captain' AS role
FROM team_captains a
JOIN players b
ON a.player_id = b.player_id
UNION
SELECT coach_name AS name, 'Coach' AS role
FROM teams;

#29.Rank players based on total runs.
SELECT a.player_id,a.player_name,
       SUM(b.total_runs) AS total_runs,
       RANK() OVER (ORDER BY SUM(b.total_runs) DESC) AS run_rank
FROM player_statistics b
JOIN players a ON b.player_id = a.player_id
GROUP BY a.player_id,a.player_name;
    
#30. Players whose name contains “singh” anywhere
SELECT * FROM players
WHERE player_name LIKE '%singh%';



