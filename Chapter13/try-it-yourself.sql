--Question 1:
-- Remove comma before suffixes like Jr. and Sr.
SELECT 
  full_name,
  regexp_replace(full_name, ', ', ' ') AS cleaned_name
FROM author_names;

-- Extract suffix into its own column using regex match
SELECT 
  full_name,
  (regexp_match(full_name, '.*, (.*)'))[1] AS suffix
FROM author_names;

--Question 2:
WITH word_list(word) AS (
  SELECT regexp_split_to_table(speech_text, '\s') AS word
  FROM president_speeches
  WHERE speech_date = '1974-01-30'
)

SELECT 
  LOWER(REGEXP_REPLACE(word, '[\.,:]+$', '')) AS cleaned_word,
  COUNT(*) AS occurrences
FROM word_list
WHERE LENGTH(word) >= 5
GROUP BY cleaned_word
ORDER BY occurrences DESC;

--Question 3:
SELECT 
  president,
  speech_date,
  ts_rank_cd(search_speech_text, search_query, 2) AS rank_score
FROM president_speeches,
     to_tsquery('war & security & threat & enemy') AS search_query
WHERE search_speech_text @@ search_query
ORDER BY rank_score DESC
LIMIT 5;
