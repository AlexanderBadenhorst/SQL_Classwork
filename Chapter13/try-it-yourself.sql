-------------------------------------------------------------
-- Chapter 13: Mining Text to Find Meaningful Data
--------------------------------------------------------------

-- 1. The style guide of a publishing company you're writing for wants you to
-- avoid commas before suffixes in names. But there are several names like
-- Alvarez, Jr. and Williams, Sr. in your author database. Which functions can
-- you use to remove the comma? Would a regular expression function help?
-- How would you capture just the suffixes to place them into a separate column?

-- Answer: You can use either the standard SQL replace() function or the
-- PostgreSQL regexp_replace() function:

SELECT replace('Williams, Sr.', ', ', ' ');
SELECT regexp_replace('Williams, Sr.', ', ', ' ');

-- Answer: To capture just the suffixes, search for characters after a comma
-- and space and place those inside a match group:

SELECT (regexp_match('Williams, Sr.', '.*, (.*)'))[1];


-- 2. Using any one of the State of the Union addresses, count the number of
-- unique words that are five characters or more. Hint: you can use
-- regexp_split_to_table() in a subquery to create a table of words to count.
-- Bonus: remove commas and periods at the end of each word.

-- Answer:

WITH
    word_list (word)
AS
    (
        SELECT regexp_split_to_table(speech_text, '\s') AS word
        FROM president_speeches
        WHERE speech_date = '1974-01-30'
    )

SELECT lower(
               replace(replace(replace(word, ',', ''), '.', ''), ':', '')
             ) AS cleaned_word,
       count(*)
FROM word_list
WHERE length(word) >= 5
GROUP BY cleaned_word
ORDER BY count(*) DESC;

-- Note: This query uses a Common Table Expression to first separate each word
-- in the text into a separate row in a table named word_list. Then the SELECT
-- statement counts the words, which are cleaned up with two operations. First,
-- several nested replace functions remove commas, periods, and colons. Second,
-- all words are converted to lowercase so that when we count we group words
-- that may appear with various cases (e.g., "Military" and "military").


-- 3. Rewrite the query in Listing 13-25 using the ts_rank_cd() function
-- instead of ts_rank(). According to th PostgreSQL documentation, ts_rank_cd()
-- computes cover density, which takes into account how close the lexeme search
-- terms are to each other. Does using the ts_rank_cd() function significantly
-- change the results?

-- Answer:
-- The ranking does change, although the same speeches are generally
-- represented. The change might be more or less pronounced given another set
-- of texts.

SELECT president,
       speech_date,
       ts_rank_cd(search_speech_text, search_query, 2) AS rank_score
FROM president_speeches,
     to_tsquery('war & security & threat & enemy') search_query
WHERE search_speech_text @@ search_query
ORDER BY rank_score DESC
LIMIT 5;