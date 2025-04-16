--Question 1:
ALTER TABLE meat_poultry_egg_inspect
ADD COLUMN meat_processing BOOLEAN,
ADD COLUMN poultry_processing BOOLEAN;

--Question 2:
UPDATE meat_poultry_egg_inspect
SET meat_processing = TRUE
WHERE activities ILIKE '%meat processing%';

UPDATE meat_poultry_egg_inspect
SET poultry_processing = TRUE
WHERE activities ILIKE '%poultry processing%';

--Question 3:
--Count plants that process meat
SELECT COUNT(*) AS meat_processors
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE;
--Count plants that process poultry
SELECT COUNT(*) AS poultry_processors
FROM meat_poultry_egg_inspect
WHERE poultry_processing = TRUE;
--Count plants that process both meat and poultry
SELECT COUNT(*) AS both_processors
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE AND poultry_processing = TRUE;
--all combined
SELECT
  COUNT(*) FILTER (WHERE meat_processing = TRUE) AS meat_processors,
  COUNT(*) FILTER (WHERE poultry_processing = TRUE) AS poultry_processors,
  COUNT(*) FILTER (WHERE meat_processing = TRUE AND poultry_processing = TRUE) AS both_processors
FROM meat_poultry_egg_inspect;