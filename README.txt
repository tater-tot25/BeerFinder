Welcome to BeerFinder!!!!

Dependencies: psycopg2

Usage Guide:

-Navigate to directory and run: <directory>/python3 -m beerFinder [-h] [-l] [results] [query] [value]

results: an integer value representing the maximum number of rows in the returned table
query: a string representing the type of query that the user would like to run
value: the primary argument that is ran with the query
-l: a help command that shows a list of queries that can be ran, and the value argument that goes with it
-h: a general help/quickstart guide for the CLI

Notes:

None of the current data is real, all of it is generated by chatGPT, this is a proof of concept.
There is currently no accounts, and it is super easy to destroy this entire database, given that the password
is in the beerFinder.py file, so please be cool and don't do that!

Thanks for checking this out!
