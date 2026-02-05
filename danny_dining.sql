CREATE TABLE members (
	customer_id VARCHAR(1) PRIMARY KEY,
    join_date TIMESTAMP
);

CREATE TABLE menu (
	product_id INT PRIMARY KEY,
    product_name VARCHAR(5),
    price INT
);

DROP TABLE sales;

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT,
    FOREIGN KEY (product_id) REFERENCES menu(product_id)
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
-- What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) as totalSpent
FROM sales s
JOIN menu m ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id; 

-- How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT s.order_date) as daysVisited
FROM sales s
GROUP BY s.customer_id;

-- What was the first item from the menu purchased by each customer?
WITH first_purchase AS(
	SELECT 
		customer_id, order_date, product_id, 
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY order_date) as rn
	FROM sales)
SELECT fp.customer_id, menu.product_name
FROM first_purchase fp
JOIN menu ON fp.product_id = menu.product_id
WHERE fp.rn = 1
ORDER BY fp.customer_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT menu.product_id, menu.product_name, COUNT(s.order_date) as purchased_times
FROM menu 
JOIN sales s ON menu.product_id = s.product_id
GROUP BY menu.product_id, menu.product_name
ORDER BY purchased_times DESC;

-- Which item was the most popular for each customer?
WITH item_count AS(
	SELECT s.customer_id, s.product_id, COUNT(s.order_date) as purchased_times
	FROM sales s
    GROUP BY s.customer_id, s.product_id
	),
max_count AS(
	SELECT customer_id, MAX(purchased_times) as max_purchase
    FROM item_count
    GROUP BY customer_id
    )
SELECT ic.customer_id, ic.purchased_times, menu.product_name
FROM item_count ic
JOIN max_count mc ON ic.customer_id = mc.customer_id 
AND ic.purchased_times = mc.max_purchase
JOIN menu 
ON ic.product_id = menu.product_id
ORDER BY ic.customer_id;

-- Which item was purchased first by the customer after they became a member?
WITH after_join AS(
	SELECT s.customer_id, s.product_id, s.order_date
    FROM sales s
    JOIN members m ON s.customer_id = m.customer_id
    WHERE s.order_date >= m.join_date
),
first_date AS(
	SELECT customer_id, MIN(order_date) as firstDate
    FROM after_join
    GROUP BY customer_id
)
SELECT aj.customer_id, menu.product_name, fd.firstDate
FROM after_join aj
JOIN first_date fd ON aj.customer_id = fd.customer_id
AND aj.order_date = fd.firstDate
JOIN menu ON aj.product_id = menu.product_id
ORDER BY aj.customer_id;

-- Which item was purchased just before the customer became a member?
WITH before_member AS (
	SELECT s.customer_id, s.product_id, s.order_date
    FROM sales s
    JOIN members ON s.customer_id = members.customer_id
    WHERE s.order_date < members.join_date
),
last_item AS (
	SELECT customer_id, MAX(order_date) AS dayBefore
    FROM before_member
    GROUP BY customer_id
)
SELECT bm.customer_id, menu.product_name, li.dayBefore
FROM before_member bm
JOIN last_item li ON bm.customer_id = li.customer_id
AND bm.order_date = li.dayBefore
JOIN menu ON bm.product_id = menu.product_id
ORDER BY bm.customer_id;

-- What is the total items and amount spent for each member before they became a member?
WITH before_member AS (
	SELECT s.customer_id, s.product_id, s.order_date
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    WHERE s.order_date < mem.join_date
),
total_spent AS (
    SELECT customer_id, SUM(menu.price) as totalSpent
    FROM before_member bm
    JOIN menu ON bm.product_id = menu.product_id
    GROUP BY customer_id
)
SELECT bm.customer_id, ts.totalSpent, COUNT(*) as totalItem
FROM before_member bm
JOIN total_spent ts ON bm.customer_id = ts.customer_id
GROUP BY bm.customer_id
ORDER BY bm.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(
	CASE
		WHEN m.product_name = 'sushi' THEN m.price*10*2
        ELSE m.price*10
	END) AS pointsEarned
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, SUM(
	CASE 
		WHEN m.product_name = 'sushi' 
			OR (s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY))
        THEN m.price*10*2
        ELSE m.price*10
	END) AS JantotalPoints
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON m.product_id = s.product_id
WHERE s.order_date < DATE '2021-02-01'
GROUP BY s.customer_id
ORDER BY s.customer_id; 
