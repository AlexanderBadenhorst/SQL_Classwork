--QUESTION 1
-- Create the table to import data into
CREATE TABLE
    movies (id INT, movie VARCHAR(50), actor VARCHAR(50));

-- Use the COPY statement with a WITH clause to import the data
COPY movies (id, movie, actor)
FROM
    'C:\YourDirectory\imaginary_text_file.txt'
WITH
    (FORMAT CSV, DELIMITER ':', HEADER);

--QUESTION 2
-- Export the 20 counties with the most housing units to a CSV file
COPY (
    SELECT
        geo_name,
        state_us_abbreviation
    FROM
        us_counties_2010
    WHERE
        geo_name ILIKE '%mill%'
) TO 'C:\YourDirectory\us_counties_mill_export.txt'
WITH
    (FORMAT CSV, HEADER, DELIMITER '|');

--QUESTION 3
--No, a column wouldnt work. the numeric data type specifies a total of 3 digits with 8 after the decimal point.
--this owuld not be sufficient to store larger data values