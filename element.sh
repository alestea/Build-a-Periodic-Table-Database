#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

FIX_DATABASE() 
{
# You should rename the weight column to atomic_mass
RENAME_WEIGHT=$($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;")

# You should rename the melting_point column to melting_point_celsius and the boiling_point column to boiling_point_celsius
RENAME_MP=$($PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;")
RENAME_BP=$($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;")

# Your melting_point_celsius and boiling_point_celsius columns should not accept null values
NOT_NULL_MP=$($PSQL"ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;")
NOT_NULL_BP=$($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;")

# You should add the UNIQUE constraint to the symbol and name columns from the elements table
#ADD_UNIQUE_SYMBOL=$($PSQL "ALTER TABLE elements ADD UNIQUE(symbol);")
#ADD_UNIQUE_NAME=$($PSQL "ALTER TABLE elements ADD UNIQUE(name);")

# Your symbol and name columns should have the NOT NULL constraint
NOT_NULL_SYMBOL=$($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;")
NOT_NULL_NAME=$($PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL;")

# You should set the atomic_number column from the properties table as a foreign key that references the column of the same name in the elements table
ATOMIC_NUMBER_FOREIGN_KEY=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY (atomic_number) REFERENCES elements(atomic_number);")

# You should create a types table that will store the three types of elements
CREATE_TABLE_TYPES=$($PSQL "CREATE TABLE types();")

# Your types table should have a type_id column that is an integer and the primary key
TYPES_ADD_COLUMN_TYPE_ID=$($PSQL "ALTER TABLE types ADD COLUMN type_id SERIAL PRIMARY KEY;")

# Your types table should have a type column that's a VARCHAR and cannot be null. It will store the different types from the type column in the properties table
TYPES_ADD_COLUMN_TYPE=$($PSQL "ALTER TABLE types ADD COLUMN type VARCHAR(30) NOT NULL;")

# You should add three rows to your types table whose values are the three different types from the properties table
TYPES_INSERT_INTO_TYPE=$($PSQL "INSERT INTO types(type) SELECT DISTINCT(type) FROM properties;")

# Your properties table should have a type_id foreign key column that references the type_id column from the types table. It should be an INT with the NOT NULL constraint
PROPERTIES_ADD_COLUMN_TYPE_ID=$($PSQL "ALTER TABLE properties ADD COLUMN type_id INT;")
PROPERTIES_ADD_FOREIGN_KEY_TYPE_ID=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY(type_id) REFERENCES types(type_id);")

# Each row in your properties table should have a type_id value that links to the correct type from the types table
PROPERTIES_UPDATE_TYPE_ID=$($PSQL "UPDATE properties SET type_id = (SELECT type_id FROM types WHERE properties.type = types.type);")
COLUMN_PROPERTIES_ALTER_TYPE_ID_NOT_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;")

# You should capitalize the first letter of all the symbol values in the elements table. Be careful to only capitalize the letter and not change any others
ELEMENTS_UPDATE_SYMBOL_CAPITAL=$($PSQL "UPDATE elements SET symbol=INITCAP(symbol);")

# You should remove all the trailing zeros after the decimals from each row of the atomic_mass column. You may need to adjust a data type to DECIMAL for this. The final values they should be are in the atomic_mass.txt file
PROPERTIES_VARCHAR_ATOMIC_MASS=$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE VARCHAR(10);")
PROPERTIES_FLOAT_ATOMIC_MASS=$($PSQL"UPDATE properties SET atomic_mass=CAST(atomic_mass AS FLOAT);")

# You should add the element with atomic number 9 to your database. Its name is Fluorine, symbol is F, mass is 18.998, melting point is -220, boiling point is -188.1, and it's a nonmetal
ELEMENTS_INSERT_FLOURINE=$($PSQL "INSERT INTO elements(atomic_number,symbol,name) VALUES(9,'F','Fluorine');")
PROPERTIES_INSERT_FLOURINE=$($PSQL "INSERT INTO properties(atomic_number,type,melting_point_celsius,boiling_point_celsius,type_id,atomic_mass) VALUES(9,'nonmetal',-220,-188.1,3,'18.998');")

# You should add the element with atomic number 10 to your database. Its name is Neon, symbol is Ne, mass is 20.18, melting point is -248.6, boiling point is -246.1, and it's a nonmetal
ELEMENTS_INSERT_NEON=$($PSQL "INSERT INTO elements(atomic_number,symbol,name) VALUES(10,'Ne','Neon');")
PROPERTIES_INSERT_NEON=$($PSQL "INSERT INTO properties(atomic_number,type,melting_point_celsius,boiling_point_celsius,type_id,atomic_mass) VALUES(10,'nonmetal',-248.6,-246.1,3,'20.18');")

# You should delete the non existent element, whose atomic_number is 1000, from the two tables
PROPERTIES_DELETE_1000=$($PSQL "DELETE FROM properties WHERE atomic_number=1000;")
ELEMENTS_DELETE_1000=$($PSQL "DELETE FROM elements WHERE atomic_number=1000;")

# Your properties table should not have a type column
DELETE_COLUMN_PROPERTIES_TYPE=$($PSQL "ALTER TABLE properties DROP COLUMN type;")
}

FIX_DATABASE

MAIN_MENU() 
{
  if [[ -z $1 ]]
  then 
    echo "Please provide an element as an argument."
  
  else
    OUTPUT_ELEMENT_DETAILS $1
  fi
}

OUTPUT_ELEMENT_DETAILS()
{
 ELEMENT_INPUT=$1
  
  # When user input is not numeric
  if [[ ! $ELEMENT_INPUT =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ELEMENT_INPUT' OR name='$ELEMENT_INPUT';") | sed 's/ //g')
  
  # When user input is numeric
  else
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ELEMENT_INPUT;") | sed 's/ //g')
  fi
  
  # If element does not exist in database
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  
  # If element does exist
  else
    TYPE_ID=$(echo $($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    NAME=$(echo $($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    ATOMIC_MASS=$(echo $($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    TYPE=$(echo $($PSQL "SELECT type FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    MELTING_POINT_CELSIUS=$(echo $($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    BOILING_POINT_CELSIUS=$(echo $($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    
    # Final input
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

MAIN_MENU $1