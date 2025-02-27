--Question 1
SELECT
    c2010.geo_name,
    c2010.state_us_abbreviation,
    c2000.geo_name
FROM
    us_counties_2010 c2010
    LEFT JOIN us_counties_2000 c2000 ON c2010.state_fips = c2000.state_fips --join the tables where the county codes match
    AND c2010.county_fips = c2000.county_fips
WHERE
    c2000.geo_name IS NULL; --filters out rows that match

--Question 3
--hurricane katrina occured in 2005
SELECT
    c2010.geo_name,
    c2010.state_us_abbreviation,
    c2010.p0010001 AS pop_2010,
    c2000.p0010001 AS pop_2000,
    c2010.p0010001 - c2000.p0010001 AS raw_change,
    ROUND(
        (
            CAST(c2010.p0010001 AS DECIMAL(8, 1)) - c2000.p0010001
        ) / c2000.p0010001 * 100,
        1
    ) AS pct_change
FROM
    us_counties_2010 c2010
    JOIN us_counties_2000 c2000 ON c2010.state_fips = c2000.state_fips
    AND c2010.county_fips = c2000.county_fips
ORDER BY
    pct_change ASC;

--st.bernard parish expierienced the greatest population loss