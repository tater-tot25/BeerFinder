CREATE TABLE location(
  location_ID int PRIMARY KEY,
  address VARCHAR(200) NOT NULL,
  state CHAR(2) NOT NULL,
  zipCode int NOT NULL,
  city VARCHAR(50) NOT NULL,
  lat float NOT NULL,
  long float NOT NULL
);

CREATE TABLE Brewery(
  brewery_ID SERIAL PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  website VARCHAR(200),
  description VARCHAR(500),
  rating CHAR(1),
  location_ID int NOT NULL,
  FOREIGN KEY (location_ID) 
    REFERENCES location(location_ID)
    ON DELETE RESTRICT
);

CREATE TABLE Distributor(
  distributor_ID SERIAL PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  website VARCHAR(200),
  description VARCHAR(500),
  rating CHAR(1),
  location_ID int NOT NULL,
  FOREIGN KEY (location_ID) 
    REFERENCES location(location_ID)
    ON DELETE RESTRICT
);

CREATE TABLE BeerType(
  type_ID SERIAL PRIMARY KEY,
  AmericanAle boolean NOT NULL DEFAULT false,
  pilsner boolean NOT NULL DEFAULT false,
  bock boolean NOT NULL DEFAULT false,
  dunkel boolean NOT NULL DEFAULT false,
  blondAle boolean NOT NULL DEFAULT false,
  belgianTripel boolean NOT NULL DEFAULT false,
  bitter boolean NOT NULL DEFAULT false,
  barleyWine boolean NOT NULL DEFAULT false,
  irishRed boolean NOT NULL DEFAULT false,
  caskAle boolean NOT NULL DEFAULT false,
  indianPaleAle boolean NOT NULL DEFAULT false,
  hazy boolean NOT NULL DEFAULT false,
  sour boolean NOT NULL DEFAULT false,
  irishDryStout boolean NOT NULL DEFAULT false,
  stout boolean NOT NULL DEFAULT false,
  porter boolean NOT NULL DEFAULT false
);

CREATE TABLE Beer(
  beer_ID SERIAL PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(500),
  rating CHAR(1),
  brewery_ID SERIAL,
  type_ID SERIAL,
  FOREIGN KEY (brewery_ID) 
    REFERENCES Brewery(brewery_ID)
    ON DELETE CASCADE,
  FOREIGN KEY (type_ID)
    REFERENCES BeerType(type_ID)
    ON DELETE RESTRICT
);

CREATE TABLE Distributes(
  beer_ID SERIAL,
  distributor_ID SERIAL,
  price DECIMAL(19, 4) NOT NULL,
  FOREIGN KEY (beer_ID) 
    REFERENCES Beer(beer_ID)
    ON DELETE CASCADE,
  FOREIGN KEY (distributor_ID) 
    REFERENCES Distributor(distributor_ID)
    ON DELETE CASCADE
);

CREATE TABLE Seller(
  seller_ID SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  website VARCHAR(100),
  primaryDistributor SERIAL,
  location_ID int NOT NULL,
  FOREIGN KEY (location_ID) 
    REFERENCES location(location_ID)
    ON DELETE RESTRICT,
  FOREIGN KEY (primaryDistributor) 
    REFERENCES distributor(distributor_ID)
    ON DELETE SET NULL
);