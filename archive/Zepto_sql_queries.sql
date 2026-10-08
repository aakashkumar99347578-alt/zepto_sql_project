-- Drop table if exists 

DROP TABLE IF EXISTS zepto;

-- create table 

CREATE TABLE zepto(
	sku_id SERIAL PRIMARY KEY,
	Category VARCHAR(120),
	name VARCHAR(150) NOT NULL,
	mrp NUMERIC(8,2),
	discountPercent NUMERIC(5,2),
	availableQuantity INTEGER,
	discountedSellingPrice NUMERIC(8,2),
	weightInGms INTEGER,
	outOfStock BOOLEAN,
	quantity INTEGER
);

-- data exploration

-- count of rows

SELECT COUNT(*) FROM zepto

-- sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * FROM zepto
WHERE name is NULL
OR
Category is NULL
OR
mrp is NULL
OR
discountPercent is NULL
OR
availablequantity is NULL
OR
outOfStock is NULL
OR
quantity is NULL;

-- different product categories
SELECT DISTINCT Category FROM zepto
ORDER BY Category;

-- product in stock vs out of stock 
SELECT outOfStock , COUNT(sku_id) 
FROM zepto
GROUP BY outOfStock;

-- product names percent multiple items
SELECT name,COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id) DESC;

-- data cleaning

-- product with price=0
SELECT * FROM zepto 
WHERE mrp=0 OR discountedSellingPrice=0;

DELETE FROM zepto
WHERE mrp=0;

-- convert paise to rupees in mrp coloumn
UPDATE zepto
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice /100.0;

SELECT mrp, discountedSellingPrice FROM zepto


-- solve some business queries

-- Q1) Find the top 10 best-value products based on the discount percentage
SELECT DISTINCT name, mrp, discountPercent FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

--Q2) What are the Products with high mrp but out of stock

SELECT DISTINCT name, mrp, outOfStock FROM zepto
WHERE outOfStock = TRUE
ORDER BY mrp DESC;

-- Q3) Calculate estimated revenue for each category
SELECT Category, SUM(discountedSellingPrice*availableQuantity) AS estimated_revenue
FROM zepto
GROUP BY Category
ORDER BY estimated_revenue DESC;

-- Q4) Find all products where mrp is greater than 500 and discount is lass than 10%

SELECT DISTINCT name, Category, mrp, discountPercent
FROM zepto
WHERE mrp>500 AND discountPercent<16.0
ORDER BY mrp;

-- Q5) Identify the top 5 categories offering the highest average disount percentage.
SELECT Category, ROUND(AVG(discountPercent)) AS average_discount_price
FROM zepto
GROUP BY Category 
ORDER BY average_discount_price DESC
LIMIT 5;

-- Q6) Find the price per gram for products above 100g and sort_by best values:
SELECT DISTINCT name, discountedSellingPrice, weightIngms,
	ROUND(discountedSellingPrice/weightIngms,2) AS price_per_gram
FROM zepto
WHERE weightIngms>=100
ORDER BY price_per_gram ;

-- Q7) Group the products into categories like low, medium, bulk.

SELECT DISTINCT name, weightIngms,
	CASE WHEN weightIngms<1000 THEN 'lOW'
		WHEN weightIngms<5000 THEN 'medium'
		ELSE 'bulk'
		END AS weight_category
	FROM zepto
	ORDER BY weight_category;

-- Q8) What is the total inventory weight per category
SELECT Category ,
	SUM(weightIngms*availableQuantity) AS total_weight
	FROM zepto
	GROUP BY Category
	ORDER BY total_weight DESC;
	


