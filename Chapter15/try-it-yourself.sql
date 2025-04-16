--------------------------------------------------------------
-- Chapter 15: Saving Time with Views, Functions, and Triggers
--------------------------------------------------------------

-- 1. Create a view that displays the number of New York City taxi trips per
-- hour. Use the taxi data in Chapter 11 and the query in Listing 11-8.

-- Answer:

CREATE VIEW nyc_taxi_trips_per_hour AS
    SELECT
         date_part('hour', tpep_pickup_datetime),
         count(date_part('hour', tpep_pickup_datetime))
    FROM nyc_yellow_taxi_trips_2016_06_01
    GROUP BY date_part('hour', tpep_pickup_datetime)
    ORDER BY date_part('hour', tpep_pickup_datetime);

SELECT * FROM nyc_taxi_trips_per_hour;

-- 2. In Chapter 10, you learned how to calculate rates per thousand. Turn that
-- formula into a rates_per_thousand() function that takes three arguments
-- to calculate the result: observed_number, base_number, and decimal_places.

-- Answer: This uses PL/pgSQL, but you could use a SQL function as well.

CREATE OR REPLACE FUNCTION
rate_per_thousand(observed_number numeric,
                  base_number numeric,
                  decimal_places integer DEFAULT 1)
RETURNS numeric(10,2) AS $$
BEGIN
    RETURN
        round(
        (observed_number / base_number) * 1000, decimal_places
        );
END;
$$ LANGUAGE plpgsql;

-- Test the function:

SELECT rate_per_thousand(50, 11000, 2);

-- 3. In Chapter 9, you worked with the meat_poultry_egg_inspect table that
-- listed food processing facilities. Write a trigger that automatically adds an
-- inspection date each time you insert a new facility into the table. Use the
-- inspection_date column added in Listing 9-19, and set the date to be six
-- months from the current date. You should be able to describe the steps needed
-- to implement a trigger and how the steps relate to each other.

-- Answer:
-- a) Add the column

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspection_date date;

-- b) Create the function that the trigger will execute.

CREATE OR REPLACE FUNCTION add_inspection_date()
    RETURNS trigger AS $$
    BEGIN
       NEW.inspection_date = now() + '6 months'::interval; -- Here, we set the inspection date to six months in the future
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- c) Create the trigger

CREATE TRIGGER inspection_date_update
  BEFORE INSERT
  ON meat_poultry_egg_inspect
  FOR EACH ROW
  EXECUTE PROCEDURE add_inspection_date();

-- d) Test the insertion of a company and examine the result

INSERT INTO meat_poultry_egg_inspect(est_number, company)
VALUES ('test123', 'testcompany');

SELECT * FROM meat_poultry_egg_inspect
WHERE company = 'testcompany';