--question 1
--8.13 code
SELECT
    pls14.stabr,
    sum(pls14.visits) AS visits_2014,
    sum(pls09.visits) AS visits_2009,
    round(
        (
            CAST(sum(pls14.visits) AS decimal(10, 1)) - sum(pls09.visits)
        ) / sum(pls09.visits) * 100,
        2
    ) AS pct_change
FROM
    pls_fy2014_pupld14a pls14
    JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE
    pls14.visits >= 0
    AND pls09.visits >= 0
GROUP BY
    pls14.stabr
ORDER BY
    pct_change DESC;

--modification
SELECT
    pls14.stabr,
    sum(pls14.pitusr) AS pitusr_2014,
    sum(pls09.pitusr) AS pitusr_2009,
    round(
        (
            CAST(sum(pls14.pitusr) AS decimal(10, 1)) - sum(pls09.pitusr)
        ) / sum(pls09.pitusr) * 100,
        2
    ) AS pct_change
FROM
    pls_fy2014_pupld14a pls14
    JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE
    pls14.pitusr >= 0
    AND pls09.pitusr >= 0
GROUP BY
    pls14.stabr
ORDER BY
    pct_change DESC;

--question 2
-- Step 1: Create the regions table
CREATE TABLE
    regions (
        obereg CHAR(2) PRIMARY KEY,
        region_name TEXT NOT NULL
    );

-- Step 2: Insert region codes and names into the regions table
INSERT INTO
    regions (obereg, region_name)
VALUES
    ('01', 'New England'),
    ('02', 'Mid-Atlantic'),
    ('03', 'East North Central'),
    ('04', 'West North Central'),
    ('05', 'South Atlantic'),
    ('06', 'East South Central'),
    ('07', 'West South Central'),
    ('08', 'Mountain'),
    ('09', 'Pacific');

-- Step 3: Modify the query to join with the regions table and group by region name
SELECT
    regions.region_name,
    SUM(pls14.visits) AS visits_2014,
    SUM(pls09.visits) AS visits_2009,
    ROUND(
        (
            CAST(SUM(pls14.visits) AS DECIMAL(10, 1)) - SUM(pls09.visits)
        ) / SUM(pls09.visits) * 100,
        2
    ) AS pct_change
FROM
    pls_fy2014_pupld14a pls14
    JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
    JOIN regions ON pls14.obereg = regions.obereg
WHERE
    pls14.visits >= 0
    AND pls09.visits >= 0
GROUP BY
    regions.region_name
ORDER BY
    pct_change DESC;

--question 3
--full outer join would show all rows in both tables where there is a match in either one, and will return null if there is no match
SELECT
    pls14.fscskey AS fscskey_2014,
    pls14.stabr AS state_2014,
    pls09.fscskey AS fscskey_2009,
    pls09.stabr AS state_2009
FROM
    pls_fy2014_pupld14a pls14
    FULL OUTER JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE
    pls14.fscskey IS NULL
    OR pls09.fscskey IS NULL;