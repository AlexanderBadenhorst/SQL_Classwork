--question 1
CREATE TABLE
    albums (
        album_id bigserial,
        album_catalog_code varchar(100) NOT NULL,
        album_title text NOT NULL,
        album_artist text NOT NULL,
        album_release_date date,
        album_genre varchar(40),
        album_description text,
        CONSTRAINT album_id_key PRIMARY KEY (album_id),
        CONSTRAINT release_date_check CHECK (album_release_date > '1925/1/1')
    );

CREATE TABLE
    songs (
        song_id bigserial,
        song_title text NOT NULL,
        song_artist text NOT NULL,
        album_id bigint REFERENCES albums (album_id),
        CONSTRAINT song_id_key PRIMARY KEY (song_id)
    );

-- the primary keys album_id and song_id ensure uniqueness aand allow for easy indexing
-- the foeign key album_id in songs links songs to albums, ensuring valid references
-- the not null constraints on title and artist ensures essential fields are always filled
-- the check on album release date prevents immpossible or historically inacurate data

--question 2
-- album_catalog_code could also be used as it is a naturally occuring unique identifier
-- but we would have to know if it would always be available


--question 3
-- Primary key columns are indexed by default, but we should add an index
-- to the album_id foreign key column in the songs table because it will be used
-- in table joins. It's likely that we'll query these tables by titles and artists,
-- so those columns in both tables should also be indexed.
-- Additionally, the album_release_date column in the albums table is a good candidate
-- for indexing if we expect to perform many queries that include date ranges.

