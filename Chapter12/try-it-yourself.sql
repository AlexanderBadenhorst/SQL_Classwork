--Question 1: 
SELECT
  CASE
    WHEN high >= 90 THEN '90 or more'
    WHEN high >= 88 THEN '88-89'
    WHEN high >= 86 THEN '86-87'
    WHEN high >= 84 THEN '84-85'
    WHEN high >= 82 THEN '82-83'
    WHEN high >= 80 THEN '80-81'
    ELSE '79 or less'
  END AS temp_group,
  COUNT(*) AS days_in_group
FROM temps_collapsed
WHERE location = 'WAIKIKI'
GROUP BY temp_group
ORDER BY days_in_group DESC;

--Question 2:
SELECT *
FROM crosstab(
  $$
  SELECT flavor, office, votes
  FROM ice_cream_survey
  ORDER BY flavor, office
  $$,
  $$
  SELECT DISTINCT office FROM ice_cream_survey ORDER BY office
  $$
) AS ct (
  flavor TEXT,
  chicago INT,
  nyc INT,
  sanfran INT
);

-- You need to re-order the columns in the first subquery so flavor is
-- first and office is second. count(*) stays third. Then, you must change
-- the second subquery to produce a grouped list of office. Finally, you must
-- add the office names to the output list.

-- The numbers don't change, just the order presented in the crosstab.
