import psycopg2 

class DatabaseConnection():

    def __init__(self, host, dbname, user, password, port):
        self.host = host
        self.dbname = dbname
        self.user = user
        self.password = password
        self.port = port
        self.conn = None
        self.cur = None

    #Attempt a server connection
    def setUpConnection(self):
        #connect to database
        try: 
            print('Connecting to the PostgreSQL database...') 
            conn = psycopg2.connect( 
                host = self.host,
                dbname = self.dbname,
                user = self.user,
                password = self.password,
                port = self.port,
                gssencmode='disable'
            ) 
            # Creating a cursor with name cur. 
            self.cur = conn.cursor() 
            print('Connected to the PostgreSQL database') 
            self.cur.execute('SELECT version()') 
            print(self.cur.fetchone()) 
            return True
        except(Exception, psycopg2.DatabaseError) as error: 
            print(error) 
            return False

    #close the server
    def closeConnection(self):
        self.cur.close() 
        if self.conn is not None: 
                self.conn.close() 
                print('Database connection closed.')
    
    def translateStoredFunctionHeadings(self, functionCalled):
        functionDictionary = {
                               1:["distributor_ID", "name", "distance_in_km", "city", "state"],
                               2:["distributor_ID", "name", "beer_count"],
                               3:["distributor_ID", "name", "address", "city", "state", "zipCode", "numOfBeersFromState"],
                               4:["distributor_Name", "local_beer_count", "total_stock", "local_beer_percentage"],
                               5:["beer_ID", "beer_name", "rating", "beer_description"],
                               6:["distributor_ID", "name", "price_per_ounce"],
                               7:["distributor_name", "address", "city", "state", "variety_count"]
                              }
        return functionDictionary[functionCalled]

    #given a stored function that returns a table, print the table
    def printFunctionTable(self, table, functionIndex):
        headings = self.translateStoredFunctionHeadings(functionIndex)
        if not table:
            print("No results found. Make sure value field is a valid argument")
            return
        # Calculate maximum width for each column
        column_widths = [len(heading) for heading in headings]
        for row in table:
            for i, value in enumerate(row):
                # Truncate values longer than 50 characters and add trailing ellipses
                if len(str(value)) > 50:
                    value = str(value)[:47] + "..."
                column_widths[i] = max(column_widths[i], len(str(value)))
        # Printing headings with adjusted spacing
        for i, heading in enumerate(headings):
            print(f"{heading.ljust(column_widths[i])}", end=" | ")
        print()  # Move to next line
        # Printing separator line
        print("-" * sum(column_widths) + "------")
        if isinstance(table[0], tuple):
            # Printing each row of the table with adjusted spacing
            for row in table:
                for i, value in enumerate(row):
                    # Truncate values longer than 50 characters and add trailing ellipses
                    if len(str(value)) > 50:
                        value = str(value)[:47] + "..."
                    print(f"{str(value).ljust(column_widths[i])}", end=" | ")
                print()  # Move to next line
        else:
            print("Unexpected table format.")


    #general function to call stored functions, returns a table of data in JSON i think
    def callStoredFunction(self, functionIndex, param, numOfResults):
         #dictionary of all the stored functions in the database
         print("calling stored function...")
         print()
         print()
         functionDictionary = {
                               1:"getNearestDistributors",
                               2:"getTopDistributorsByBeerType",
                               3:"getDistributorsWhoSellBeerFrom",
                               4:"getDistributorWithMostLocalBeers",
                               5:"getBestRatedBeerFromDistributor",
                               6:"whichDistributorSellXBeerForCheapest",
                               7:"getDistributorFromSameStateWithBestVariety"
                              }
         #error checking
         if (not isinstance(numOfResults, int)) or (not isinstance(functionIndex, int)):
            raise Exception("numOfResults and functionIndex must be of type: Integer")
         if (not isinstance(param, str)):
             raise Exception("param must be of type: String")
         #query the database
         self.cur.callproc(functionDictionary[functionIndex], (param, numOfResults))
         table = self.cur.fetchall()
         return table