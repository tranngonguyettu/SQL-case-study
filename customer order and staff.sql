
create table CustomerType(
customerTypeID INT NOT NULL,
customerTypeName VARCHAR(45) NOT NULL,
customerTypeDescription TEXT NULL,
PRIMARY KEY (customerTypeID));

create table Customer(
customerID INT NOT NULL,
customerName VARCHAR(300) NOT NULL,
contactName VARCHAR(300) NULL,
customerPhoneNumber VARCHAR(20) NULL,
customerAddress VARCHAR(500) NULL,
customerTypeID INT NOT NULL,
PRIMARY KEY (customerID),
CONSTRAINT fk_customer_type FOREIGN KEY (customerTypeID) REFERENCES CustomerType(customerTypeID));

create table StaffMember(
staffID INT NOT NULL,
staffName VARCHAR(300) NOT NULL,
staffRole VARCHAR(30) NOT NULL,
staffCurrentEmployeeType VARCHAR(20) NOT NULL,
PRIMARY KEY (staffID));

create table `Order`(
orderID INT NOT NULL AUTO_INCREMENT,
orderDate DATE NOT NULL,
orderTime TIME NOT NULL,
orderDeliveryInstructions TEXT,
customerID INT NOT NULL,
createdByStaffID INT NOT NULL,
PRIMARY KEY (orderID),
CONSTRAINT fk_order_customer FOREIGN KEY (customerID) REFERENCES Customer(customerID),
CONSTRAINT fk_order_staff FOREIGN KEY (createdbyStaffID) REFERENCES StaffMember(staffID));

create table Payment(
paymentID INT NOT NULL,
paymentAmount DECIMAL NOT NULL,
paymentDateTime DATETIME NOT NULL, 
paymentMethod VARCHAR(20) NOT NULL,
paymentSystemReferenceNumber VARCHAR(256) NULL,
PRIMARY KEY (paymentID));

create table PaymentPortion(
paymentID INT NOT NULL,
orderID INT NOT NULL,
paymentPortionAmount DECIMAL NOT NULL,
PRIMARY KEY (paymentID,orderID),
CONSTRAINT fk_paymentPortion_payment FOREIGN KEY (paymentID) REFERENCES Payment(paymentID),
CONSTRAINT fk_paymentPortion_order FOREIGN KEY (orderID) REFERENCES `Order`(orderID));

create table OrderItem(
orderID INT NOT NULL,
itemSequenceNumber INT NOT NULL,
quantity INT NOT NULL,
salePricePerItem DECIMAL NOT NULL,
PRIMARY KEY (orderID,itemSequenceNumber),
CONSTRAINT FK_orderitem_order FOREIGN KEY (orderID) REFERENCES `Order`(orderID));

-- ##################################################################################
-- Put your SQL below for the data insertion statements for Task B
-- ===== CustomerType (4 types)
INSERT INTO CustomerType (customerTypeID, customerTypeName, customerTypeDescription) VALUES
(500,'Individual','Private person'),
(510,'Company','Registered business customer'),
(520,'Government','Government department/agency'),
(530,'Reseller','Buys to resell');

-- ===== Customer (4 customers)
INSERT INTO Customer (customerID, customerName, contactName, customerPhoneNumber, customerAddress, customerTypeID) VALUES
(216050,'Alice Smith','Alice Smith','0400123001','12 Green St, Sydney',500),
(216070,'Bob Jones','Bob Jones','0400123002','55 Blue Rd, Melbourne',510),
(216090,'Bright Interiors Pty Ltd','Sarah White','0298765003','100 High St, Sydney',520),
(216040,'Melbourne Zoo','David Black','0399988004','22 Victoria St, Melbourne',530);


-- ===== StaffMember (3 staff)
INSERT INTO StaffMember (staffID, staffName, staffRole, staffCurrentEmployeeType) VALUES
(500110,'John Carter','Sales','Full-time'),
(500130,'Tom Evans','Designer','Part-time'),
(500140,'Sophie Young','Sales','Casual');

-- ===== Order
INSERT INTO `Order` (orderID, orderDate, orderTime, orderDeliveryInstructions, customerID, createdByStaffID) VALUES
(101,'2021-01-05','09:30:00','Leave at front desk',216050,500110),
(102,'2021-06-07','14:10:00','Call before delivery',216070,500130),
(103,'2022-02-10','11:00:00','Deliver to warehouse entrance',216090,500110),
(104,'2022-03-12','15:30:00','Fragile items',216040,500140),
(105,'2022-05-15','10:15:00','Hospital loading dock',216050,500130),
(106,'2023-01-16','13:20:00','Reseller dock 3',216090,500110),
(107,'2023-12-16','13:50:00','Leave at front door',216040,500130),
(108,'2024-10-16','13:20:00','Deliver to office',216050,500140),
(109,'2025-02-16','13:20:00','Call before delivery',216070,500130),
(110,'2025-08-21','20:30:00','Deliver to office',216040,500110);

-- ===== OrderItem (34 items totally) 
INSERT INTO OrderItem (orderID, itemSequenceNumber, quantity, salePricePerItem) VALUES
(101,001,2,150.00),(101,002,1,90.00), -- Order101: 390$
(102,001,1,120.00),(102,002,3,250.00),(102,003,4,480.00), -- Order102: 2790$
(103,001,6,60.00), -- Order103:360$
(104,001,3,45.00),(104,002,5,30.00), -- Order104:285$
(105,001,7,95.00), -- Order105:665$
(106,001,2,70.00),-- Order106:140$
(107,001,1,50.00),(107,002,5,10.00),(107,003,2,70.00), -- Order107:240$
(108,001,10,100.00), -- Order108: 1000$
(109,001,1,15.00),(109,002,1,15.00), -- Order109:30$
(110,001,1,35.00),(110,002,6,12.00),(110,003,3,90.00); -- Order110:377$

-- ===== Payment
INSERT INTO Payment (paymentID, paymentAmount, paymentDateTime, paymentMethod, paymentSystemReferenceNumber) VALUES
(901,400.00,'2021-01-05 10:00:00','Card','TXN2061'), -- Pay for Order101 and 10$ for Order103
(902,1500.00,'2022-11-07 15:00:00','Cash','TXN2052'), -- Pay for Order102
(903,1290.00,'2022-07-10 11:30:00','BankTransfer','TXN2033'), -- Pay for Order102
(904,350.00,'2024-03-12 16:00:00','Card','TXN2004'), -- Pay 350$ for Order103
(905,425.00,'2024-05-15 11:00:00','BankTransfer','TXN2015'), -- Pay for Order104 and 140$ for Order106
(906,665.00,'2024-01-16 13:45:00','Card','TXN2052'), -- Pay for Order105
(907,240.00,'2025-01-20 13:45:00','BankTransfer','TXN2061'), -- Pay for Order107
(908,500.00,'2025-04-16 16:45:00','Card','TXN2100'), -- pay for Order108
(909,400.00,'2025-04-30 09:30:00','Card','TXN2052'), -- pay for Order108
(910,300.00,'2025-05-16 13:45:00','Cash','TXN2100'), -- pay for Order110
(911,107.00,'2025-09-20 07:45:00','BankTransfer','TXN2033'); -- pay for Order11 and 30$ for Order109

-- ===== PaymentPortion
INSERT INTO PaymentPortion (paymentID, orderID, paymentPortionAmount) VALUES
(901, 101, 390.00), -- Fully pay for Order101 by Payment901
(902, 102, 1500.00), (903, 102, 1290.00),  -- Split payment for Order102 by Payment902,903 totally 2790$
(901, 103, 10.00), (904, 103, 350.00), -- Split payment for Order103 by Payment901,904 totally 360$
(905, 104, 285.00), -- Fully pay for Order104 totally 285$ by Payment905 
(906, 105, 665.00), -- Fully pay for Order105 by Payment906 totally 665$
(905, 106, 140.00), -- Fully pay for Order106 totally 140$ by Payment905 
(907, 107, 240.00), -- Fully pay for Order107
(908, 108, 500.00), -- Split payment for Order108
(909, 108, 400.00), -- Split payment for Order108 and still owing $100
(911, 109, 30.00), -- Fully pay for Order109 by Payment911
(910, 110, 300.00), -- Split payment for Order110 by Payment910
(911, 110, 77.00);  -- Split payment for Order110 by Payment911

-- ##################################################################################
-- Select customer with their names containing A, Z
select customerID, customerName, customerPhoneNumber, customerAddress 
from Customer
where customerName like '%a%' 
or customerName like '%z%'
or customerName like '%A%'
or customerName like '%Z%'
order by customerName DESC;

-- Select each customer with their first order
select c.customerID, c.customerName, MIN(o.orderDate) as FirstDateOrder
from customer as c
left join `order` as o on c.customerID = o.customerID
group by c.customerID, c.customerName
order by c.customerID;

-- Select customer with their order and the amount they spent
select o.orderID, o.orderDate, o.orderTime, c.customerName, c.contactName, cast(SUM((oi.quantity*salePricePerItem)) as decimal (12,2)) as TotalAmount
from customer as c
right join `order` as o on c.customerID = o.customerID
join orderItem as oi on o.orderID = oi.orderID
group by o.orderID, o.orderDate, o.orderTime, c.customerName, c.contactName
order by o.orderDate ASC, c.customerID DESC;

-- Find the amount that are paid for each order
select o.orderID, cast(SUM(pp.paymentPortionAmount) as decimal(12,2)) AS totalPaid
from `Order` o
left join PaymentPortion pp on o.orderID = pp.orderID
group by o.orderID;

-- Calculate the total number of orders for each staff from 2021 - 2025
WITH years AS (
    SELECT 2021 AS yr UNION ALL
    SELECT 2022 UNION ALL
    SELECT 2023 UNION ALL
    SELECT 2024 UNION ALL
    SELECT 2025
)
select s.staffID, s.staffName, y.yr as `Year`, count(o.orderID) as NumberOfOrders
from staffMember as s
cross join years as y
LEFT join `order` as o on s.staffID = o.createdbyStaffID
and y.yr = year(o.orderDate)
group by s.staffID, s.staffName, y.yr
order by s.staffID;

-- your task C vi) sql query code below
-- How much is the total of an order?
WITH order_totals AS (
  select oi.orderID, SUM(oi.quantity * oi.salePricePerItem) as OrderTotal
  from OrderItem oi
  group by oi.orderID
),
-- How much have the order paid?
paid_totals AS (
  select pp.orderID, SUM(pp.paymentPortionAmount) as PaidTotal
  FROM PaymentPortion pp
  GROUP BY pp.orderID
)
-- Create a query and calculate the amount of owing by aggregration
select
  o.orderID,
  cast(coalesce(ot.OrderTotal, 0) as decimal(12,2)) as TotalOrderAmount,
  cast(coalesce(pt.PaidTotal, 0) as decimal(12,2)) as TotalPaid,
  cast(coalesce(ot.OrderTotal, 0) - coalesce(pt.PaidTotal, 0) as decimal(12,2)) AS TotalOwing
from `Order` o
left join order_totals ot on ot.orderID = o.orderID
left join paid_totals  pt on pt.orderID = o.orderID
order by o.orderID;
-- end of file