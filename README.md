# ygeiopolis
NTUA - Project for Database Course Spring 2026 - Hospital

This database, written for Postgresql, contains data for music festivals.


# Project Structure

sql/ contains all sql files demanded by the project description, including the schema, constraints & triggers, indexes, data, queries and their outputs

code/ contains all scripts and my own code used

diagrams/ contains the relational and the ER diagram

docs/ contains the report for the project

other/ contains the rest, like the project description, the source of the ER diagram, docx of the report etc.

# Instructions
Install postgres, postgres-contrib, python, faker (python lib)

Change directory to $ cd code to run the automated scripts

Run ./make_load_sql.sh to create the load.sql file with all the insert statements. This basically combines the output of print_fake_data.py with adjust_data_for_Q14.sql into a single, gigantic load.sql. Depending on the configuration (specified in print_fake_data.py) this can take some time, and the resulting file may be hundreds of megabytes long.

Alternatively you can split/reconstruct the single load.sql to/from its chuncks load_part_x.sql using the scripts ./split_load_sql.sh/./reconstruct_load_sql.sh respectively.

Run ./setup_db.sh to create a user, the database, install the schema (specified in sql/install.sql) and insert all the data (sql/load.sql).

Run ./run_queries.sql in order to run all the QXX.sql queries and create their output files.


