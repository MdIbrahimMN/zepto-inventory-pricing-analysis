create database zepto_analytics;
use zepto_analytics;
create table zepto_products (
	category VARCHAR(100),
    name VARCHAR(255),
    mrp DECIMAL(12,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(12,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);
USE zepto_analytics;

ALTER TABLE zepto_products
MODIFY COLUMN outOfStock VARCHAR(10);

select count(*) as total_records
from zepto_products;

select * from zepto_products limit 10;

describe zepto_products;

#Check missing values
select count(*) as total_records,
	sum(category is null or trim(category)=' ') as missing_category,
    sum(name is null or trim(name)=' ') as missing_name,
    sum(mrp is null ) as missing_mrp,
    sum(discountPercent is null) as missing_discountPercent,
    sum(availableQuantity is null ) as missijng_availableQuantity,
    sum(discountedSellingPrice is null ) as missing_discountedSellingPrice,
    sum(weightInGms is null ) as missing_weightInGms,
    sum(outOfStock is null or trim(outOfStock)=' ') as missing_outOfStock,
    sum(quantity is null) as missing_quantity
    from zepto_products;

# checking duplicate values
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity , count(*) as duplicate_count from zepto_products
group by category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity 
having count(*) >1
order by duplicate_count desc;

SELECT
    SUM(duplicate_count - 1) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM zepto_analytics.zepto_products
    GROUP BY
        category,
        name,
        mrp,
        discountPercent,
        availableQuantity,
        discountedSellingPrice,
        weightInGms,
        outOfStock,
        quantity
    HAVING COUNT(*) > 1
) AS duplicates;

CREATE TABLE zepto_products_backup AS
SELECT *
FROM zepto_analytics.zepto_products;

ALTER TABLE zepto_analytics.zepto_products
ADD COLUMN temp_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY;

WITH ranked_products AS (
    SELECT
        temp_id,
        ROW_NUMBER() OVER (
            PARTITION BY
                category,
                name,
                mrp,
                discountPercent,
                availableQuantity,
                discountedSellingPrice,
                weightInGms,
                outOfStock,
                quantity
            ORDER BY temp_id
        ) AS row_num
    FROM zepto_analytics.zepto_products
)
SELECT *
FROM ranked_products
WHERE row_num > 1;

#delete the duplicates
DELETE FROM zepto_analytics.zepto_products
WHERE temp_id IN (
    SELECT temp_id
    FROM (
        SELECT
            temp_id,
            ROW_NUMBER() OVER (
                PARTITION BY
                    category,
                    name,
                    mrp,
                    discountPercent,
                    availableQuantity,
                    discountedSellingPrice,
                    weightInGms,
                    outOfStock,
                    quantity
                ORDER BY temp_id
            ) AS row_num
        FROM zepto_analytics.zepto_products
    ) AS ranked
    WHERE row_num > 1
)
AND temp_id > 0;

#verify
SELECT COUNT(*) AS total_records
FROM zepto_analytics.zepto_products;

# check outofstock avalaibity
select outofstock, count(*) as total_products from zepto_products
group by outOfStock;

#top 10 products discount
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity from zepto_products
where discountPercent is not null
order by discountPercent desc
limit 10;	

#validate product price
SELECT
    MIN(mrp) AS minimum_mrp,
    MAX(mrp) AS maximum_mrp,
    MIN(discountedSellingPrice) AS minimum_selling_price,
    MAX(discountedSellingPrice) AS maximum_selling_price,
    MIN(discountPercent) AS minimum_discount,
    MAX(discountPercent) AS maximum_discount
FROM zepto_analytics.zepto_products;

#data validation using SQL
#check invalid prices
describe zepto_products;
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity from zepto_analytics.zepto_products
where mrp<=0 or discountedSellingPrice<=0;

# check invalid discount percentages
describe zepto_products;
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity from zepto_analytics.zepto_products
where discountPercent < 0 or discountPercent > 100;

#check negative inventory quantities
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity from zepto_analytics.zepto_products
where availableQuantity < 0 or quantity < 0 or weightInGms < 0;

#standarize outofstock values
select outofstock ,count(*) as total_products from zepto_analytics.zepto_products
group by outOfStock;	

#start Exploratory data analysis
select count(*) as total_Analysis from zepto_analytics.zepto_products;

#number of product categories
select count(distinct category) as total_category from zepto_analytics.zepto_products;

#number of each cateogory product
select category ,count(*) as total_products from zepto_analytics.zepto_products
group by category
order by total_products desc;

#Average discount by product
select category ,round(avg(discountPercent),2) as Average_Discount from zepto_analytics.zepto_products
group by category
order by Average_Discount desc;

#Top 10 products by discount
select category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity from zepto_analytics.zepto_products
where discountPercent is not null
order by discountPercent
limit 10;
USE zepto_analytics;

SELECT COUNT(*) AS total_records
FROM zepto_products;







