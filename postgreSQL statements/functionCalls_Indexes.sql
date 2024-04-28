-- example queries to get top distributors by beer type, with limiting results
/*
SELECT * FROM getTopDistributorsByBeerType('pilsner', 5);
SELECT * FROM getTopDistributorsByBeerType('indianpaleale', 5);
SELECT * FROM getTopDistributorsByBeerType('hazy', 10);
SELECT * FROM getTopDistributorsByBeerType('stout', 10);
SELECT * FROM getTopDistributorsByBeerType('porter', 10);
*/
-- example queries to get the nearest distributors to a given seller, with limiting results
/*
SELECT * FROM getNearestDistributors('Malt Mansion', 6);
SELECT * FROM getNearestDistributors('Hoppy Hut', 3);
SELECT * FROM getNearestDistributors('Ale Avenue', 5);
*/
-- Get the distributors who sell beer from x state, with limiting results
/*
SELECT * FROM getdistributorswhosellbeerfrom('CO', 10);
SELECT * FROM getdistributorswhosellbeerfrom('WA', 10);
SELECT * FROM getdistributorswhosellbeerfrom('NY', 10);
SELECT * FROM getdistributorswhosellbeerfrom('OR', 10);
*/
-- Get the distributors who sell the local beers relative to the given seller, with limiting results
/*
SELECT * FROM getDistributorWithMostLocalBeers('Ale Avenue', 5);
SELECT * FROM getDistributorWithMostLocalBeers('Hoppy Hut', 5);
SELECT * FROM getDistributorWithMostLocalBeers('Malty Marvels', 5);
*/
-- Get the best rated beers from a given distributor, with limiting results
/*
SELECT * FROM getBestRatedBeerFromDistributor('Brewery Bridge', 10);
SELECT * FROM getBestRatedBeerFromDistributor('Hop House', 10);
SELECT * FROM getBestRatedBeerFromDistributor('Brewery Barn', 10);
SELECT * FROM getBestRatedBeerFromDistributor('Malt Mania', 10);
*/
-- Get the distributor who sells X beer for the cheapest with limiting results
-- Would work better if the synthetic data didn't set the price to zero for all beers :(
-- might wright a function to re-randomize the price for all stock
/*
SELECT * FROM whichDistributorSellXBeerForCheapest('American Stout', 10);
SELECT * FROM whichDistributorSellXBeerForCheapest('American Black IPA', 10);
SELECT * FROM whichDistributorSellXBeerForCheapest('Belgian Saison', 10);
*/
-- Get the distributor who sells the best variety of beer in a given state with limiting results
/*
SELECT * FROM getDistributorFromSameStateWithBestVariety('Hoppy Hut', 10)
SELECT * FROM getDistributorFromSameStateWithBestVariety('Beer Box', 10)
SELECT * FROM getDistributorFromSameStateWithBestVariety('Hop Haven', 10)
*/SELECT * FROM getDistributorFromSameStateWithBestVariety('Malt Mansion', 10)/*
*/

CREATE INDEX IF NOT EXISTS seller_name
ON seller(name);

CREATE INDEX IF NOT EXISTS distributor_name
ON distributor(name);

CREATE INDEX IF NOT EXISTS brewery_name
ON brewery(name);