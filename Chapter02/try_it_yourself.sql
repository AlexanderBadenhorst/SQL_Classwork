--QUESTION 1
SELECT
    school,
    last_name
FROM
    teachers
ORDER BY
    school,
    last_name;

--QUESTION 2
SELECT
    first_name,
    salary
FROM
    teachers
WHERE
    first_name LIKE 'S%'
    AND salary > 40000;

--QUESTION 3
SELECT
    first_name,
    last_name,
    salary,
    hire_date
FROM
    teachers
WHERE
    hire_date >= '2010-01-01'
ORDER BY
    salary DESC;