# Zepto SQL Data Analysis Project

## Project Overview
This project contains data exploration, cleaning, and business analysis for Zepto e-commerce grocery data using SQL (PostgreSQL). The dataset includes product details, pricing, discount percentages, stock status, and inventory quantities.

---

## Project Structure
```text
zepto_sql_project/
└── archive/
    ├── Zepto_sql_queries.sql   # SQL script for schema, exploration, cleaning, and business queries
    ├── zepto_v1.xlsx           # Excel dataset
    └── zepto_v2.csv            # Raw CSV dataset (3,700+ rows)
```

---

## Database Schema

```sql
CREATE TABLE zepto (
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
```

---

## Data Exploration & Quality Checks

### 1. Total Row Count
```sql
SELECT COUNT(*) FROM zepto;
```

### 2. Sample Data
```sql
SELECT * FROM zepto
LIMIT 10;
```

### 3. Check for Null Values
```sql
SELECT * FROM zepto
WHERE name IS NULL
   OR Category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;
```

### 4. Distinct Product Categories
```sql
SELECT DISTINCT Category FROM zepto
ORDER BY Category;
```

### 5. In-Stock vs Out-of-Stock Product Count
```sql
SELECT outOfStock, COUNT(sku_id) 
FROM zepto
GROUP BY outOfStock;
```

### 6. Multiple SKUs for Same Product Name
```sql
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;
```

---

## Data Cleaning

### 1. Remove Zero-Priced Records
```sql
SELECT * FROM zepto 
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;
```

### 2. Convert Paise to Rupees
```sql
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;
```

---

## Business Queries & Analysis

### Q1. Top 10 Best-Value Products by Discount Percentage
Find the top 10 products offering the highest discount percentage.
```sql
SELECT DISTINCT name, mrp, discountPercent FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```

### Q2. High MRP Products Currently Out of Stock
Identify expensive items that are currently unavailable.
```sql
SELECT DISTINCT name, mrp, outOfStock FROM zepto
WHERE outOfStock = TRUE
ORDER BY mrp DESC;
```

### Q3. Estimated Revenue per Category
Calculate the potential revenue for each category based on available stock and discounted selling price.
```sql
SELECT Category, SUM(discountedSellingPrice * availableQuantity) AS estimated_revenue
FROM zepto
GROUP BY Category
ORDER BY estimated_revenue DESC;
```

### Q4. Premium Products with Low Discounts
Find products with MRP greater than 500 and discount less than 16%.
```sql
SELECT DISTINCT name, Category, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 16.0
ORDER BY mrp;
```

### Q5. Top 5 Categories with Highest Average Discount
Identify product categories offering the highest average discount percentage.
```sql
SELECT Category, ROUND(AVG(discountPercent)) AS average_discount_price
FROM zepto
GROUP BY Category 
ORDER BY average_discount_price DESC
LIMIT 5;
```

### Q6. Price per Gram for Products Above 100g
Determine the best-value products by calculating the cost per gram for items weighing 100g or more.
```sql
SELECT DISTINCT name, discountedSellingPrice, weightInGms,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;
```

### Q7. Group Products by Weight Category
Categorize products into weight brackets: 'LOW' (< 1000g), 'medium' (< 5000g), and 'bulk' (>= 5000g).
```sql
SELECT DISTINCT name, weightInGms,
       CASE 
           WHEN weightInGms < 1000 THEN 'lOW'
           WHEN weightInGms < 5000 THEN 'medium'
           ELSE 'bulk'
       END AS weight_category
FROM zepto
ORDER BY weight_category;
```

### Q8. Total Inventory Weight per Category
Calculate the total weight of available inventory across each category.
```sql
SELECT Category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY Category
ORDER BY total_weight DESC;
```
