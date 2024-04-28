import argparse
from client import DatabaseConnection

# All the info needed to connect to the database
host = 'aws-0-us-west-1.pooler.supabase.com'
dbname = 'postgres' 
user = 'postgres.zxjguvbtssqjloyvbihn'
password = 'ilovebeer@1035'
port = 6543

#dictionary of info to print for the -l command
listOfQueries = {
    "nearest": "getNearestDistributors | value = seller_name",
    "topDistributors": "getTopDistributorsByBeerType | value = beer_type",
    "from": "getDistributorsWhoSellBeerFrom | value = state in code format (XX)",
    "local": "getDistributorWithMostLocalBeers | value = seller_name",
    "topBeer": "getBestRatedBeerFromDistributor | value = distributor_name",
    "cheapestDistributor": "whichDistributorSellXBeerForCheapest | value = beer_name",
    "bestVariety": "getDistributorFromSameStateWithBestVariety | value = seller_name"
}

#dictionary to translate command to integer counterpart
translation = {
    "nearest": 1,
    "topDistributors": 2,
    "from": 3,
    "local": 4,
    "topBeer": 5,
    "cheapestDistributor": 6,
    "bestVariety" : 7
}

# Print out all of the info for the different query types
def complexQueryHelp():
    print()
    for key in listOfQueries:
        print("Argument: " + key + " | info: " + listOfQueries[key])
    print()
    print("EXAMPLE COMMAND: 15 topDistributors pilsner ")
    print("Names are case sensitive!")
    print("-h for more help")
    print()

# Set up argparser
parser = argparse.ArgumentParser(description="CLI to interact with beerFinder database")
parser.add_argument("results", nargs='?', type=int, default=None, help="number of results to be printed as an integer value")
parser.add_argument("query", nargs='?', type=str, default=None, help="enter query | type -l to get list of query types")
parser.add_argument("value", nargs='?', type=str, default=None, 
                    help="The primary argument for the request. More information can be found with -l. Values with spaces should be formatted as \"example text\"")
parser.add_argument("-l", "--listOfQueries", help="Gives more info on the query and results fields", action="store_true")
args = parser.parse_args() 

# Check if -l option is provided and execute complexQueryHelp() if yes
if args.listOfQueries:
    complexQueryHelp()

# If -l option is not provided, proceed with database connection and query execution
if not args.listOfQueries:
    try:
        if args.query is None or args.results is None or args.value is None:
            raise ValueError('value, query, and results must be provided. Type -h or -l for more help!')

        client = DatabaseConnection(host, dbname, user, password, port)
        control = client.setUpConnection()
        if not control:
            raise Exception("Failed to set up connection with database!")
        table = client.callStoredFunction(translation[args.query], args.value, args.results)
        client.printFunctionTable(table, translation[args.query])
        client.closeConnection()
    except Exception as e:
        print("Failed to call database:", e)