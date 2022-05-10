# Jesus Zeno

# Let's start by installing the sql dataframe package
install.packages("sqldf")
# load in the package
library(sqldf)

# Let's call in the csv files
# giffordsice.csv is the Flavors table
# giffordscust.csv is the Customers table
# giffordstop.csv is the Toppings table
# giffordsorder.csv is the Orders table
# giffords.csv is the Sites table

Flavors = read.csv(file.choose(), header=TRUE)
Customers = read.csv(file.choose(), header=TRUE)
Toppings = read.csv(file.choose(), header=TRUE)
Orders = read.csv(file.choose(), header=TRUE)
Sites = read.csv(file.choose(), header=TRUE)

# Let's get an idea of what each table looks like
head(Flavors)
head(Toppings)
head(Customers)
head(Sites)
head(Orders)

# 1. Show all possible distinct pairs of toppings
query = "
SELECT T1.Name AS Topping_1, T2.Name AS TOPPING_2
FROM [Toppings] T1
INNER JOIN [Toppings] T2
ON T1.Name < T2.Name
Order By T1.Name
"
sqldf(query)

# 2. Transform the order table's set of scoops into two columns:  order and 
# flavor.  Do the same for toppings as well.  Make sure we know which scoop
# it was or which topping it was (i.e., first).

# We are putting the order numbers and scoop flavors in two columns to save
# as one table.
query = "
SELECT * FROM(
SELECT Orders.ID, Flavors.Flavor FROM Orders, Flavors WHERE Flavors.ID = Orders.Scoop1 
UNION
SELECT Orders.ID, Flavors.Flavor FROM Orders, Flavors WHERE Flavors.ID = Orders.Scoop2
UNION
SELECT Orders.ID, Flavors.Flavor FROM Orders, Flavors WHERE Flavors.ID = Orders.Scoop3
)AS A ORDER BY ID
"
orders_and_flavors=sqldf(query)
head(orders_and_flavors)

# Let's do the same thing for toppings.
query = "
SELECT * FROM(
SELECT Orders.ID, Toppings.Name FROM Orders, Toppings WHERE Toppings.ID = Orders.Topping1 
UNION
SELECT Orders.ID, Toppings.Name FROM Orders, Toppings WHERE Toppings.ID = Orders.Topping2
UNION
SELECT Orders.ID, Toppings.Name FROM Orders, Toppings WHERE Toppings.ID = Orders.Topping3
)AS A ORDER BY ID
"
orders_and_toppings=sqldf(query)
head(orders_and_toppings)

# 3. Project away the columns about scoops and toppings from the order table.
# Note:  in combination with task 2, we have normalized the database.
query = "
SELECT ID, Customer, Site, Date
FROM Orders
"
# Save query to normalize table
Orders_Normalized = sqldf(query)
head(Orders_Normalized)

# 4. Find any "fruity" ice cream flavor.  In this case, fruity desserts will 
# contain words like peach, cherry, apple, berry, orange, or pumpkin.
query = "
SELECT *
FROM Flavors
WHERE Flavor LIKE '%peach%' OR Flavor LIKE '%cherry%' OR 
Flavor LIKE '%apple%' OR Flavor LIKE '%berry%' OR Flavor LIKE'%orange%' OR 
Flavor LIKE '%pumpkin%'
"
sqldf(query)

# 5. Rank the stores by orders placed.  Make sure that the stores are 
# labelled by their town, not by a number.
query = "
SELECT Sites.City, COUNT(Orders.Site) AS Order_Amount
FROM Orders, Sites
WHERE Sites.ID = Orders.Site
GROUP BY Orders.Site
ORDER BY Order_Amount DESC
"
sqldf(query)

# 6. Find all orders that are sundaes (i.e., have at least one topping)
query = "
SELECT ID AS Sundaes_Orders
FROM Orders
WHERE Topping1 > 0 OR Topping2 > 0 OR Topping3 > 0
Group BY ID
"
sundaes_orders = sqldf(query)
sundaes_orders

# 7. Find all customers from Maine (ME) or New Hampshire (NH)
query = "
SELECT Fname, Lname, State
FROM Customers
WHERE State = 'ME' OR State = 'NH'
"
sqldf(query)

# 8. Find all items that could be in an order which would be problematic for 
# someone with a nut allergy.
query = "
SELECT Flavor AS Item, Nuts, 'Flavor' as Topping_or_Flavor
FROM Flavors
WHERE nuts = 'Y'
UNION
SELECT Name as Item, Nuts, 'Topping' as Topping_or_Flavor
FROM Toppings
WHERE nuts = 'Y'
"
sqldf(query)
