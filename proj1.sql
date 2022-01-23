-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era) AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE people.weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) AS count
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear 
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) AS count
  FROM people
  GROUP BY birthyear
  HAVING avgheight > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT a.namefirst AS namefirst, a.namelast AS namelast, a.playerid AS playerid, b.yearid as yearid
  FROM people AS a, HallofFame as b
  WHERE a.playerid = b.playerid AND b.inducted = 'Y'
  ORDER BY b.yearid DESC, b.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT a.namefirst, a.namelast, a.playerid, s.schoolid, b.yearid
  FROM people as a INNER JOIN HallofFame as b
  ON a.playerid = b.playerid,
  CollegePlaying as c INNER JOIN Schools as s
  ON s.schoolid = c.schoolid
  WHERE a.playerid = c.playerid AND s.schoolState = 'CA' AND b.inducted = 'Y'
  ORDER BY b.yearid DESC, c.schoolid, a.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT a.playerid, namefirst, namelast, schoolid
  FROM people a INNER JOIN HallofFame b  
  ON a.playerid = b.playerid
  LEFT OUTER JOIN CollegePlaying c
  ON a.playerid = c.playerid
  WHERE b.inducted = 'Y'
  ORDER BY a.playerid DESC, c.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT a.playerid, a.namefirst, a.namelast, b.yearid, 
  ROUND( CAST((b.h + b.h2b  + 2 * b.h3b + 3*b.hr) AS float )/ CAST(b.ab as float),4) as slg
  FROM people a INNER JOIN Batting b
  ON a.playerid = b.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC, yearid, a.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT a.playerid, a.namefirst, a.namelast, 
  ROUND( CAST((l.h + l.h2b  + 2 * l.h3b + 3*l.hr) AS float )/ CAST(l.ab as float),4) as lslg
  FROM people a INNER JOIN 
  (SELECT b.playerid, SUM(b.h) as h, SUM(b.h2b) as h2b, SUM(b.h3b) as h3b,SUM(b.hr) as hr,
  SUM(b.ab) as ab
  FROM Batting b 
  GROUP BY b.playerid) as l
  ON a.playerid = l.playerid
  WHERE l.ab > 50
  ORDER BY lslg DESC, a.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT a.namefirst, a.namelast, 
  ROUND( CAST((l.h + l.h2b  + 2 * l.h3b + 3*l.hr) AS float )/ CAST(l.ab as float),4) as lslg
  FROM people a INNER JOIN 
  (SELECT b.playerid, SUM(b.h) as h, SUM(b.h2b) as h2b, SUM(b.h3b) as h3b,SUM(b.hr) as hr,
  SUM(b.ab) as ab
  FROM Batting b 
  GROUP BY b.playerid) as l
  ON a.playerid = l.playerid
  WHERE l.ab > 50 AND lslg > 
  (SELECT ROUND( CAST((l.h + l.h2b  + 2 * l.h3b + 3*l.hr) AS float )/ CAST(l.ab as float),4) as lslg
  FROM people a INNER JOIN 
  (SELECT b.playerid, SUM(b.h) as h, SUM(b.h2b) as h2b, SUM(b.h3b) as h3b,SUM(b.hr) as hr,
  SUM(b.ab) as ab
  FROM Batting b 
  GROUP BY b.playerid) as l  WHERE l.playerid = 'mayswi01')
  ORDER BY lslg DESC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
-- Question 4ii 
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, q.min + binid*(CAST(((q.max - q.min)/10) AS INT)) as low, q.min+(binid + 1)*(CAST(((q.max - q.min)/10) AS INT)) as high,
  COUNT(*)
  FROM binids b, q4i q,
  salaries s
  WHERE s.yearid = 2016 AND q.yearid = 2016 AND (s.salary BETWEEN low AND high)
  GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT q2.yearid, q2.min-q1.min as mindiff, q2.max - q1.max as maxdiff,
  q2.avg - q1.avg as avgdiff
  FROM q4i q1, q4i q2 
  WHERE q2.yearid = q1.yearid + 1
  ORDER BY q2.yearid  
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM people as p INNER JOIN salaries s
  ON p.playerid = s.playerid
  WHERE (s.yearid = 2001 
  AND s.salary = (
    SELECT MAX(salary) FROM salaries WHERE yearid = 2001 
  )
  ) OR (s.yearid = 2000 
  AND s.salary = (
    SELECT MAX(salary) FROM salaries WHERE yearid = 2000 
  ))
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary) as diffAvg
  FROM allstarfull a INNER JOIN salaries s
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

