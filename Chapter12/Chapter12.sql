-- Listing 12-1: Using a subquery in a WHERE clause

SELECT geo_name,
       state_us_abbreviation,
       p0010001
FROM us_counties_2010
WHERE p0010001 >= (
    SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
    FROM us_counties_2010
    )
ORDER BY p0010001 DESC;

-- Listing 12-2: Using a subquery in a WHERE clause for DELETE

CREATE TABLE us_counties_2010_top10 AS
SELECT * FROM us_counties_2010;

DELETE FROM us_counties_2010_top10
WHERE p0010001 < (
    SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
    FROM us_counties_2010_top10
    );

SELECT count(*) FROM us_counties_2010_top10;

-- Listing 12-3: Subquery as a derived table in a FROM clause

SELECT round(calcs.average, 0) as average,
       calcs.median,
       round(calcs.average - calcs.median, 0) AS median_average_diff
FROM (
     SELECT avg(p0010001) AS average,
            percentile_cont(.5)
                WITHIN GROUP (ORDER BY p0010001)::numeric(10,1) AS median
     FROM us_counties_2010
     )
AS calcs;

-- Listing 12-4: Joining two derived tables

SELECT census.state_us_abbreviation AS st,
       census.st_population,
       plants.plant_count,
       round((plants.plant_count/census.st_population::numeric(10,1)) * 1000000, 1)
           AS plants_per_million
FROM
    (
         SELECT st,
                count(*) AS plant_count
         FROM meat_poultry_egg_inspect
         GROUP BY st
    )
    AS plants
JOIN
    (
        SELECT state_us_abbreviation,
               sum(p0010001) AS st_population
        FROM us_counties_2010
        GROUP BY state_us_abbreviation
    )
    AS census
ON plants.st = census.state_us_abbreviation
ORDER BY plants_per_million DESC;

-- Listing 12-5: Adding a subquery to a column list

SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
        FROM us_counties_2010) AS us_median
FROM us_counties_2010;

-- Listing 12-6: Using a subquery expression in a calculation

SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
        FROM us_counties_2010) AS us_median,
       p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
                   FROM us_counties_2010) AS diff_from_median
FROM us_counties_2010
WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
                   FROM us_counties_2010))
       BETWEEN -1000 AND 1000;

            
-- BONUS: Subquery expressions
-- If you'd like to try the IN, EXISTS, and NOT EXISTS expressions on pages 199-200,
-- here's the code to create a retirees table. The queries below are similar
-- to the hypothetical examples on pages 199 and 200. You will need the
-- employees table you created in Chapter 6.
              
-- Create table and insert data
CREATE TABLE retirees (
    id int,
    first_name varchar(50),
    last_name varchar(50)
);

INSERT INTO retirees 
VALUES (2, 'Lee', 'Smith'),
       (4, 'Janet', 'King');

-- Generating values for the IN operator
SELECT first_name, last_name
FROM employees
WHERE emp_id IN (
    SELECT id
    FROM retirees);

-- Checking whether values exist (returns all rows from employees
-- if the expression evaluates as true)
SELECT first_name, last_name
FROM employees
WHERE EXISTS (
    SELECT id
    FROM retirees);

-- Using a correlated subquery to find matching values from employees
-- in retirees.
SELECT first_name, last_name
FROM employees
WHERE EXISTS (
    SELECT id
    FROM retirees
    WHERE id = employees.emp_id);

                   
                   
-- Listing 12-7: Using a simple CTE to find large counties

WITH
    large_counties (geo_name, st, p0010001)
AS
    (
        SELECT geo_name, state_us_abbreviation, p0010001
        FROM us_counties_2010
        WHERE p0010001 >= 100000
    )
SELECT st, count(*)
FROM large_counties
GROUP BY st
ORDER BY count(*) DESC;

-- Bonus: You can also write this query as:
SELECT state_us_abbreviation, count(*)
FROM us_counties_2010
WHERE p0010001 >= 100000
GROUP BY state_us_abbreviation
ORDER BY count(*) DESC;

-- Listing 12-8: Using CTEs in a table join

WITH
    counties (st, population) AS
    (SELECT state_us_abbreviation, sum(population_count_100_percent)
     FROM us_counties_2010
     GROUP BY state_us_abbreviation),

    plants (st, plants) AS
    (SELECT st, count(*) AS plants
     FROM meat_poultry_egg_inspect
     GROUP BY st)

SELECT counties.st,
       population,
       plants,
       round((plants/population::numeric(10,1))*1000000, 1) AS per_million
FROM counties JOIN plants
ON counties.st = plants.st
ORDER BY per_million DESC;

-- Listing 12-9: Using CTEs to minimize redundant code

WITH us_median AS 
    (SELECT percentile_cont(.5) 
     WITHIN GROUP (ORDER BY p0010001) AS us_median_pop
     FROM us_counties_2010)

SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       us_median_pop,
       p0010001 - us_median_pop AS diff_from_median 
FROM us_counties_2010 CROSS JOIN us_median
WHERE (p0010001 - us_median_pop)
       BETWEEN -1000 AND 1000;


-- Cross tabulations
-- Install the crosstab() function via the tablefunc module

CREATE EXTENSION tablefunc;

-- Listing 12-10: Creating and filling the ice_cream_survey table

CREATE TABLE ice_cream_survey (
    response_id integer PRIMARY KEY,
    office varchar(20),
    flavor varchar(20)
);

COPY ice_cream_survey
FROM 'C:\YourDirectory\ice_cream_survey.csv'
WITH (FORMAT CSV, HEADER);

-- Listing 12-11: Generating the ice cream survey crosstab

SELECT *
FROM crosstab('SELECT office,
                      flavor,
                      count(*)
               FROM ice_cream_survey
               GROUP BY office, flavor
               ORDER BY office',

              'SELECT flavor
               FROM ice_cream_survey
               GROUP BY flavor
               ORDER BY flavor')

AS (office varchar(20),
    chocolate bigint,
    strawberry bigint,
    vanilla bigint);

-- Listing 12-12: Creating and filling a temperature_readings table

CREATE TABLE temperature_readings (
    reading_id bigserial PRIMARY KEY,
    station_name varchar(50),
    observation_date date,
    max_temp integer,
    min_temp integer
);

COPY temperature_readings 
     (station_name, observation_date, max_temp, min_temp)
FROM 'C:\YourDirectory\temperature_readings.csv'
WITH (FORMAT CSV, HEADER);

-- Listing 12-13: Generating the temperature readings crosstab

SELECT *
FROM crosstab('SELECT
                  station_name,
                  date_part(''month'', observation_date),
                  percentile_cont(.5)
                      WITHIN GROUP (ORDER BY max_temp)
               FROM temperature_readings
               GROUP BY station_name,
                        date_part(''month'', observation_date)
               ORDER BY station_name',

              'SELECT month
               FROM generate_series(1,12) month')

AS (station varchar(50),
    jan numeric(3,0),
    feb numeric(3,0),
    mar numeric(3,0),
    apr numeric(3,0),
    may numeric(3,0),
    jun numeric(3,0),
    jul numeric(3,0),
    aug numeric(3,0),
    sep numeric(3,0),
    oct numeric(3,0),
    nov numeric(3,0),
    dec numeric(3,0)
);

-- Listing 12-14: Re-classifying temperature data with CASE

SELECT max_temp,
       CASE WHEN max_temp >= 90 THEN 'Hot'
            WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
            WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
            WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
            WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
            ELSE 'Inhumane'
        END AS temperature_group
FROM temperature_readings;

-- Listing 12-15: Using CASE in a Common Table Expression

WITH temps_collapsed (station_name, max_temperature_group) AS
    (SELECT station_name,
           CASE WHEN max_temp >= 90 THEN 'Hot'
                WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
                WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
                WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
                WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
                ELSE 'Inhumane'
            END
    FROM temperature_readings)

SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;



--extra task--
--brief--
-- -I have started a business, and would like a data capture to show my employees with their names, birthdates, roles, role descriptions and role salaries.

-- Here are the roles:

-- Graphic Designer - Helps with video editing, photo editing and market advertisement designs - 35k ZAR
-- Videographer - Helps with all digital media productions - 18k ZAR
-- Social Marketer - Helps with social media strategies and social data - 26k ZAR
-- Sales Rep - Helps promote and sign clients - 20k ZAR

-- Here are my employees:

-- Aragorn - 24/08/1994 - Sales Rep (22 sales)
-- Gandalf - 11/05/1982 - Graphic Designer
-- Frodo - 18/01/1990 - Videographer
-- Legolas - 22/04/1998 - Social Marketer
-- Gimli - 08/11/2000 - Sales Rep (10 sales)
-- Samwise - 01/01/2001 - Sales Rep (9 sales)
-- Pippin - 26/09/1999 - Sales Rep (18 sales)
-- Merry - 07/08/2005 - Social Marketer

-- With my sales reps, can you please update the salaries by 200 ZAR per every unit they sell over 10. Also, can you please separate all my employees older than 27 years old.

--solution--
-- roles table --
CREATE TABLE roles1 (
  role_id SERIAL PRIMARY KEY,
  role_name TEXT UNIQUE,
  description TEXT,
  base_salary NUMERIC
);

INSERT INTO roles1 (role_name, description, base_salary)
VALUES
  ('Graphic Designer', 'Helps with video editing, photo editing and market advertisement designs', 35000),
  ('Videographer', 'Helps with all digital media productions', 18000),
  ('Social Marketer', 'Helps with social media strategies and social data', 26000),
  ('Sales Rep', 'Helps promote and sign clients', 20000);
  
 SELECT * FROM roles1

-- employees table --
CREATE TABLE employees2 (
  employee_id SERIAL PRIMARY KEY,
  name TEXT,
  birthdate DATE,
  role_id INT REFERENCES roles1(role_id),
  sales INT
);

INSERT INTO employees2 (name, birthdate, role_id, sales)
VALUES
  ('Aragorn', '1994-08-24', 4, 22),
  ('Gandalf', '1982-05-11', 1, NULL),
  ('Frodo', '1990-01-18', 2, NULL),
  ('Legolas', '1998-04-22', 3, NULL),
  ('Gimli', '2000-11-08', 4, 10),
  ('Samwise', '2001-01-01', 4, 9),
  ('Pippin', '1999-09-26', 4, 18),
  ('Merry', '2005-08-07', 3, NULL);
  
 SELECT * FROM employees2
 
-- Get name, birthdate, role, description, base salary, adjusted salary --
SELECT
  e.name,
  e.birthdate,
  r.role_name,
  r.description,
  r.base_salary,
  CASE 
    WHEN r.role_name = 'Sales Rep' AND e.sales > 10 THEN 
      r.base_salary + ((e.sales - 10) * 200)
    ELSE 
      r.base_salary
  END AS final_salary
FROM employees2 e
JOIN roles1 r ON e.role_id = r.role_id;


-- Show Employees Older Than 27 --
SELECT
  e.name,
  e.birthdate,
  r.role_name,
  r.base_salary
FROM employees2 e
JOIN roles1 r ON e.role_id = r.role_id
WHERE AGE(e.birthdate) > INTERVAL '27 years';

--combined--
SELECT
  e.name,
  e.birthdate,
  r.role_name,
  r.description,
  r.base_salary,
  CASE 
    WHEN r.role_name = 'Sales Rep' AND e.sales > 10 THEN 
      r.base_salary + ((e.sales - 10) * 200)
    ELSE 
      r.base_salary
  END AS final_salary,
  CASE 
    WHEN AGE(e.birthdate) > INTERVAL '27 years' THEN 'Yes'
    ELSE 'No'
  END AS over_27
FROM employees2 e
JOIN roles1 r ON e.role_id = r.role_id;