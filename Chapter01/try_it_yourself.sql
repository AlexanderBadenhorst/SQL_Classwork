--Table for the different kinds of animals
CREATE TABLE
    animals (
        animal_id bigserial, --relational purposes
        animal_type varchar(50) --specify the type of animal
    );

--inserting data into the animals table
INSERT INTO
    animals (animal_type)
VALUES
    ('lion'),
    ('crocodile'),
    ('eagle'),
    ('frog'),
    ('salmon'),
    ('bee');

--VIEW DATA
--run the query SELECT * FROM public.animals, this will display all the data from that table

--ERROR MESSAGE 
--ERROR:  syntax error at or near "("
--LINE 7:     ('salmon'),
--           ^ 
--SQL state: 42601
--Character: 107
--error message is incredibly specific and would greatly ease in finding and resolving the error
--table for the specifics of each animal
CREATE TABLE
    animal_details (
        animal_id bigserial, --for relational purposes to the first table
        animal_species varchar(50) --to specify the species of the animal
    );

--inserting data into the animal_details table
INSERT INTO
    animal_details (animal_species)
VALUES
    ('Panthera leo'),
    ('Crocodylinae'),
    ('Aquila chrysaetos'),
    ('Rana temporaria'),
    ('Salmo salar'),
    ('Apis mellifera');