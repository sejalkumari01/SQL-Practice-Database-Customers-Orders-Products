CREATE DATABASE practices;
USE practices;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

INSERT INTO customers VALUES
(1, 'Raj Malhotra', 'Mumbai', '2023-01-10'),
(2, 'Priya Mehra', 'Delhi', '2023-01-20'),
(3, 'Karan Joshi', 'Bangalore', '2023-02-05'),
(4, 'Anjali Verma', 'Mumbai', '2023-03-15');


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

INSERT INTO products VALUES
(101, 'Notebook', 'Stationery', 50.00),
(102, 'Pen', 'Stationery', 10.00),
(103, 'Bluetooth Speaker', 'Electronics', 1500.00),
(104, 'Water Bottle', 'Kitchen', 300.00);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(1001, 1, '2023-02-01', 1600.00),
(1002, 2, '2023-02-10', 300.00),
(1003, 3, '2023-03-01', 60.00),
(1004, 1, '2023-03-20', 300.00);


CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items VALUES
(1, 1001, 103, 1), -- Bluetooth Speaker
(2, 1002, 104, 1), -- Water Bottle
(3, 1003, 101, 1), -- Notebook
(4, 1003, 102, 1), -- Pen
(5, 1004, 104, 1); -- Water Bottle


-- List all customers who signed up in February 2023.

SELECT name AS CustomerName
FROM customers
WHERE signup_date BETWEEN '2023-02-01' AND '2023-02-28';


-- Show all products in the "Stationery" category.

SELECT product_name FROM products
WHERE category= "Stationery";


-- Display each order with its total amount and order date.

SELECT P.product_name, O.total_amount, O.order_date
FROM products P
JOIN order_items OT ON P.product_id= OT.product_id
JOIN orders O ON O.order_id= OT.order_id;


-- Show each customer's name and the products they ordered.

SELECT C.name AS CustomerName, GROUP_CONCAT(P.product_name SEPARATOR ', ') AS OrderedProducts
FROM customers C
JOIN orders O ON C.customer_id= O.customer_id
JOIN order_items OT ON O.order_id= OT.order_id
JOIN products P ON P.product_id= OT.product_id
GROUP BY C.name;


-- Calculate the total quantity sold per product.

SELECT P.product_name, SUM(OT.quantity) AS TotalQuantitySold
FROM products P
JOIN order_items OT ON P.product_id= OT.product_id
JOIN orders O ON O.order_id= OT.order_id
GROUP BY P.product_name;


-- Find the total sales made by each city.

SELECT C.city, SUM(O.total_amount) AS TotalSales
FROM customers C 
JOIN orders O ON C.customer_id= O.customer_id
GROUP BY C.city;


-- List customers who placed more than one order.

SELECT C.name
FROM customers C 
JOIN orders O ON C.customer_id= O.customer_id
GROUP BY C.name
HAVING COUNT(order_id)>1;


-- Show total revenue for each product category.

SELECT 
    p.category,
    SUM(oi.quantity * p.unit_price) AS total_revenue
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
GROUP BY 
    p.category;


-- Find the most expensive product each customer has purchased.

WITH expensive AS (
SELECT C.name, P.product_name, P.unit_price, 
ROW_NUMBER() OVER(PARTITION BY C.name ORDER BY P.unit_price DESC) AS RN
FROM customers C
JOIN orders O ON C.customer_id= O.customer_id
JOIN order_items OT ON O.order_id= OT.order_id
JOIN products P ON P.product_id= OT.product_id)
SELECT name, product_name, unit_price
FROM expensive
WHERE RN=1;


-- Show customers who ordered at least 2 different product categories.

SELECT C.name
FROM customers C
JOIN orders O ON C.customer_id= O.customer_id
JOIN order_items OT ON O.order_id= OT.order_id
JOIN products P ON P.product_id= OT.product_id
GROUP BY C.name
HAVING COUNT(DISTINCT P.category)>1;


-- Calculate the average order value per customer.

SELECT 
    p.category,
    ROUND(AVG(oi.quantity * p.unit_price),2) AS AverageOrderValue
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
GROUP BY 
    p.category;


-- List the top 2 best-selling products by quantity.

SELECT P.product_name
FROM customers C
JOIN orders O ON C.customer_id= O.customer_id
JOIN order_items OT ON O.order_id= OT.order_id
JOIN products P ON P.product_id= OT.product_id
GROUP BY  P.product_name
ORDER BY SUM(OT.quantity) DESC
LIMIT 2;


-- Rank products by revenue generated.


SELECT 
    p.category,
    SUM(oi.quantity * p.unit_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * p.unit_price) DESC) AS category_rank
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
GROUP BY 
    p.category;


-- Show the first order date for each customer.

SELECT name, order_date
FROM
(SELECT c.name, o.order_date,
ROW_NUMBER() OVER(PARTITION BY c.name ORDER BY o.order_date) AS orderdate
FROM customers c
JOIN orders o ON C.customer_id= O.customer_id) OD
WHERE orderdate=1;

-- List customers who placed orders but never bought anything from the "Electronics" category.

SELECT c.name AS customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name
HAVING SUM(p.category = 'Electronics') = 0;


/* Filtering, Sorting & Aggregation
📌 Topic: WHERE, ORDER BY, GROUP BY, HAVING */

-- Find the top 5 customers with the highest total spending.

SELECT C.name AS CUSTOMERNAME, SUM(O.total_amount) AS TOTALSPENDING
FROM customers C
JOIN orders O
ON C.customer_id= O.customer_id
GROUP BY C.name
ORDER BY SUM(O.total_amount) DESC
LIMIT 5;


-- List all orders with a total amount above the average order amount.

SELECT * FROM orders
WHERE total_amount> (
SELECT AVG(total_amount) FROM orders);


-- Count how many products were sold in each category.

SELECT P.category, SUM(OT.quantity)
FROM products P 
JOIN order_items OT
ON P.product_id= OT.product_id
GROUP BY P.category;


-- Find the average quantity ordered per product.

SELECT P.product_name, AVG(OT.quantity)
FROM products P 
JOIN order_items OT
ON P.product_id= OT.product_id
GROUP BY P.product_name;


-- Show customers who signed up in the last 30 days.

SELECT name 
FROM customers
WHERE signup_date>= CURRENT_DATE()- INTERVAL 30 DAY;


/* 2. JOINs
📌 Topic: INNER, LEFT, RIGHT, SELF JOIN */

-- List all customers and the products they have ever ordered.

SELECT c.name AS CUSTOMERNAME, GROUP_CONCAT(p.product_name SEPARATOR ',') AS PRODUCTSORDERED
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name;


-- Show orders that have no corresponding order items (data integrity check).

SELECT O.order_id, OT.product_id
FROM orders O
JOIN order_items OT
ON OT.order_id= O.order_id;


-- List each customer’s most recent order date.

SELECT C.name AS CUSTOMERSNAME,
MAX(O.order_date) AS RECENTORDERDATE
FROM customers C
JOIN orders O
ON C.customer_id= O.customer_id
GROUP BY C.name;


-- Get a list of customers who have never placed an order.

SELECT C.name AS CUSTOMERSNAME
FROM customers C
LEFT JOIN orders O
ON C.customer_id= O.customer_id
WHERE O.order_date IS NULL;


-- Show the total revenue by city.

SELECT C.city AS CITY, SUM(O.total_amount) AS TOTALSPENDING
FROM customers C
JOIN orders O
ON C.customer_id= O.customer_id
GROUP BY C.city
ORDER BY SUM(O.total_amount) DESC;


/* 3. Subqueries
📌 Topic: Scalar, Correlated, IN, NOT EXISTS */

-- Find customers who spent more than the average customer.

SELECT C.name
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id
WHERE total_amount> (
SELECT AVG(total_amount) FROM orders);


-- List products that were never ordered.

SELECT P.product_name
FROM products P 
LEFT JOIN order_items OT
ON P.product_id= OT.product_id
WHERE quantity IS NULL
GROUP BY P.product_name;


-- Find customers who ordered all available product categories.

SELECT C.name 
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id
JOIN order_items OT
ON O.order_id= OT.order_id
JOIN products P 
ON OT.product_id= P.product_id
GROUP BY 
    c.customer_id, c.name
HAVING 
    COUNT(DISTINCT p.category) = (
        SELECT COUNT(DISTINCT category) FROM products
    );


-- List customers who placed more than 1 order, but never in February.

SELECT 
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.name
HAVING 
    COUNT(o.order_id) > 1
    AND SUM(MONTH(o.order_date) = 2) = 0;


-- Find the products that are priced higher than the most expensive product in “Stationery”.

SELECT 
    product_name, 
    category, 
    unit_price
FROM 
    products
WHERE 
    unit_price > (
        SELECT MAX(unit_price)
        FROM products
        WHERE category = 'Stationery'
    );

/* 4. Window Functions
📌 Topic: ROW_NUMBER, RANK, DENSE_RANK, LEAD, LAG */

-- For each customer, rank their orders by total amount spent.

SELECT C.name, O.total_amount,
RANK() OVER(PARTITION BY C.name ORDER BY O.total_amount DESC) 
AS RANKED_ORDER
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id;


-- Show the difference in amount between a customer's current and previous order.

WITH DIFF AS(
SELECT C.name, O.total_amount AS CURRENT_ORDER,
LAG(O.total_amount) OVER(PARTITION BY C.name) 
AS PREVIOUS_ORDER
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id)
SELECT name, CURRENT_ORDER-PREVIOUS_ORDER AS DIFFRANCE
FROM DIFF;


-- List the top 2 best-selling products per category.

WITH BESTSELLING AS(
SELECT P.product_name, P.category, O.total_amount,
ROW_NUMBER() OVER(PARTITION BY P.category ORDER BY O.total_amount DESC)
AS BestSellingProducts
FROM products P 
JOIN order_items OT
ON P.product_id= OT.product_id
JOIN orders O 
ON OT.order_id= O.order_id)
SELECT product_name, category, total_amount
FROM BESTSELLING
WHERE BestSellingProducts IN (1,2);


-- Show each customer’s first and last purchase.

SELECT C.name AS CustomerName,
MIN(O.order_date) AS FirstPurchase,
MAX(O.order_date) AS LastPurchase
FROM customers C 
LEFT JOIN orders O 
ON C.customer_id= O.customer_id
GROUP BY C.name;


-- Identify the most recent order per product.

WITH RECENT AS(
SELECT P.product_name, O.order_date,
ROW_NUMBER() OVER(PARTITION BY P.product_name ORDER BY O.order_date DESC)
AS RecentOrders
FROM products P 
JOIN order_items OT
ON P.product_id= OT.product_id
JOIN orders O 
ON OT.order_id= O.order_id)
SELECT product_name, order_date
FROM RECENT
WHERE RecentOrders= 1;

/* 5. CASE Statements / Conditional Aggregation
📌 Topic: Dynamic columns, pivot-style logic */

-- Tag orders as ‘Small’, ‘Medium’, ‘Large’ based on amount.

SELECT order_id,
CASE
WHEN total_amount<=500 THEN 'Small'
WHEN total_amount<=1000 THEN 'Medium'
ELSE 'Large'
END AS OrderTags
FROM orders;


-- Show customers and count how many orders they placed.

SELECT C.name, COUNT(O.order_id) AS ORDERCOUNT
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id
GROUP BY C.name;


-- Flag customers as “Repeat Buyer” or “One-Time Buyer”.

WITH ORDERCOUNT AS(
SELECT C.name, COUNT(O.order_id) AS ORDERCOUNT
FROM customers C 
JOIN orders O 
ON C.customer_id= O.customer_id
GROUP BY C.name)
SELECT name, 
CASE
WHEN ORDERCOUNT=1 THEN 'One Time Buyer'
ELSE 'Repeat Buyer'
END AS Flag
FROM ORDERCOUNT;

/* 6. Common Table Expressions (CTEs)
📌 Topic: Modular queries */

-- Use a CTE to get total monthly revenue and then compare each month to the previous one.

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_difference,
    ROUND(
        100 * (revenue - LAG(revenue) OVER (ORDER BY month)) / 
        LAG(revenue) OVER (ORDER BY month), 2
    ) AS percentage_change
FROM 
    monthly_revenue;


-- Using a CTE, list all customers who have steadily increased spending over 3 consecutive months.

WITH customer_monthly_spending AS (
    SELECT 
        c.customer_id,
        c.name AS customer_name,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(o.total_amount) AS monthly_spending
    FROM 
        customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id, c.name, DATE_FORMAT(o.order_date, '%Y-%m')
),
ranked_spending AS (
    SELECT 
        customer_id,
        customer_name,
        order_month,
        monthly_spending,
        LAG(monthly_spending, 1) OVER (PARTITION BY customer_id ORDER BY order_month) AS prev1,
        LAG(monthly_spending, 2) OVER (PARTITION BY customer_id ORDER BY order_month) AS prev2
    FROM 
        customer_monthly_spending
)
SELECT DISTINCT customer_name
FROM ranked_spending
WHERE 
    prev2 IS NOT NULL
    AND prev1 > prev2
    AND monthly_spending > prev1;


-- Find the % of revenue contributed by each category using a CTE.

WITH category_revenue AS (
    SELECT 
        p.category,
        SUM(oi.quantity * p.unit_price) AS revenue
    FROM 
        products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY 
        p.category
)
SELECT 
    category,
    revenue,
    ROUND(
        100 * revenue / SUM(revenue) OVER (), 2
    ) AS revenue_percentage
FROM 
    category_revenue;

/* 🔧 1. Stored Procedures
📌 Stored Procedures are reusable blocks of SQL logic stored in the database. */

-- Write a stored procedure to insert a new customer into the customers table.

DELIMITER &&
CREATE PROCEDURE NEWCUS(IN customer_id INT,
    IN Cname VARCHAR(100),
    IN city VARCHAR(100),
    IN signup_date DATE)
BEGIN
INSERT INTO customers 
VALUES (customer_id, Cname, city, signup_date);   
END &&

DELIMITER ;

CALL NEWCUS(5, 'Arth', 'Pune', Current_date()- INTERVAL 1 DAY);
CALL NEWCUS(6, 'Sejal', 'Pune', Current_date());

SELECT * FROM CUSTOMERS;

-- Create a stored procedure that takes a customer ID and returns their total spending.

DELIMITER &&
CREATE PROCEDURE TOTAL(IN CUSID INT)
BEGIN
SELECT C.name, SUM(O.total_amount)
FROM customers C
JOIN orders O 
ON C.customer_id= O.customer_id
WHERE C.customer_id= CUSID
GROUP BY C.name;
END&&
DELIMITER ;


-- Write a stored procedure to update product prices by category (increase by 10%).

DELIMITER $$

CREATE PROCEDURE IncreasePriceByCategory (
    IN p_category VARCHAR(100)
)
BEGIN
    UPDATE products
    SET unit_price = unit_price * 1.10
    WHERE category = p_category;
END $$

DELIMITER ;

CREATE TABLE deleted_records(customer_id INT, time DATE);

DELETE FROM CUSTOMERS
WHERE customer_id= 6;

SELECT * FROM deleted_records;

DROP TRIGGER deleted;

DELIMITER //
CREATE TRIGGER DELETED
AFTER DELETE ON CUSTOMERS
FOR EACH ROW
BEGIN
INSERT INTO deleted_records
VALUES(OLD.customer_id, CURRENT_TIME());
END//
DELIMITER ;


