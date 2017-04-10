 SELECT * FROM INPUT;   
--1.	Write a PL/SQL block that will print to the server output the title and price of the 
--book with ISBN 1059831198.
DECLARE
	BookTitle varchar2(50);
  BookPrice number(8,2);

 BEGIN
   select
     b.title, b.COST into BookTitle, BookPrice
  from
   BOOKS b
   where
    b.ISBN= 1059831198;

   dbms_output.put_line('Book title: '||BookTitle);
  dbms_output.put_line('Book Price: '||BookPrice);
  END;
  
--2.	Write a PL/SQL block that declares all the variables necessary to create a new 
--book order, and then 
--inserts the necessary records to order a single book.

DECLARE
  BookISBN varchar2(50) := '1059831778';
  BookTitle varchar2(50) := 'The legend of zelda';
  BookPrice number(8,2) :=45;
  BookPubID number(2,0):= 2;
  
  CurrentOrderNum number(4,0) := 1111;
  CurrentCustomerNum number(8,2) :=1020;
  CurrentOrderDate DATE := SYSDATE();
 BEGIN
    INSERT INTO ORDERS o
      (o.ORDER#, o.CUSTOMER#,o.ORDERDATE)
    VALUES
      (CurrentOrderNum, CurrentCustomerNum,CurrentOrderDate);
    
    INSERT INTO orderitems oi
      (oi.order#, oi.item#, oi.isbn,oi.quantity)
    VALUES
      (1001,1,'8843172113', 2);
  END;
--3.	The JUSTLEE bookstore is having a sale that will affect retail
--prices of books based on their categories. 
--Books in the COMPUTER category will be 70% of their retail price, books in the 
--FITNESS category will be 60% of their retail price, 
--books in the BUSINESS category will be 80% of their retail price, 
--and all other books will be 90% of their retail price. 

--Write a PL/SQL block that declares and initializes a variable bookISBN, and then calculates 
--for that ISBN what the retail price would be during the sale using an IF condition. 
--The result should be output via the DBMS output. 
--Check your code using a few different ISBN’s.
DECLARE
  BookISBN varchar2(50);
  BookTitle varchar2(50);
  BookPrice number(8,2);
  BookPubID number(2,0):= 2;
  BookCategory VARCHAR2(12);
  -- end of declare
  BEGIN
        select b.title, b.RETAIL, b.CATEGORY into BookTitle, BookPrice, BookCategory
        from BOOKS b
        WHERE b.ISBN = '8843172113';
        
        IF BookCategory = 'COMPUTER' THEN
        BookPrice := BookPrice * .7;
        ELSIF BookCategory = 'FITNESS' THEN
         BookPrice := BookPrice * .6;
        ELSIF BookCategory = 'BUSINESS' THEN
         BookPrice := BookPrice * .8;
         ELSE
          BookPrice := BookPrice * .9;
        END IF;
      dbms_output.put_line('Book Title: '||BookTitle);
       dbms_output.put_line('Book Category: '||BookCategory);
       dbms_output.put_line('Sale Price: '||BookPrice);
        
  END;

--4.	The JUSTLEE bookstore is starting a customer rewards program. In this program, 
--Customers can earn reward points by buying books and recommending friends to the bookstore. 
--Each purchased book is worth 100 reward points, and each recommended friend is worth 500 reward points.
--Customers with 0-1000 reward points are considered to be ‘BRONZE TIER’,
--customers with 1001-2000 reward points are considered to be ‘SILVER TIER’, 
--customers with over 2000 reward points are considered to be ‘GOLD TIER’. 

--Write a  PL/SQL block which declares a customer#,
--and then outputs that customers name, and what their reward tier would be based on the number
--of recommendations that customer has made and how many books they have bought.
DECLARE
  PeopleReferred NUMBER(10,0) := 0;
  PurchasedBooks  NUMBER(10,0) := 0;
  CurrentCustomerNumber NUMBER(4,0) := 1001;
  CustomerTier varchar2(50);
  CustomerFirstName varchar2(50);
  CustomerLastName varchar2(50);
  RewardPoints NUMBER(10,2);
  -- end of declare
  BEGIN
  -- line 10
    SELECT  COUNT(*) into PurchasedBooks 
    FROM CUSTOMERS c 
    JOIN orders o ON c.CUSTOMER# = o.CUSTOMER#
    WHERE c.customer# = CurrentCustomerNumber
    GROUP BY c.customer# 
    ORDER BY c.customer#;
    
    SELECT firstname, lastname, COUNT(*) into CustomerFirstName, CustomerLastName,PeopleReferred 
    FROM CUSTOMERS
    WHERE referred# = CurrentCustomerNumber
    GROUP BY firstname, lastname;
    
    RewardPoints := (PurchasedBooks * 100) + (PeopleReferred * 500);
    --Customers with 0-1000 reward points are considered to be �BRONZE TIER",
    --customers with 1001-2000 reward points are considered to be �SILVER TIER", 
    --customers with over 2000 reward points are considered to be �GOLD TIER".
    IF RewardPoints > 0 and RewardPoints <= 1000 then
      CustomerTier := 'Bronze';
    ELSIF RewardPoints > 1000 and RewardPoints <= 2000 then
      CustomerTier := 'Silver';
    ELSIF RewardPoints >2000 then
      CustomerTier := 'Gold';
   END IF;
   dbms_output.put_line('Customer ' || CustomerFirstname || ' ' || CustomerLastname); 
   dbms_output.put_line(RewardPoints || ' points from purchasing ' || PurchasedBooks || ' books and ' );
   dbms_output.put_line('referred '|| PeopleReferred ||' people and CustomerTier is ' || CustomerTier);
        
  END;
--5.	Create a new table called input which should contain 3 number fields, a, b, and c. Now, 
--write a program block that retrieves a, b, and c from the table. If all a, b, and c are not null, the block should do nothing. 
--If one value is missing, the block should compute the last value using the formula a2 + b2 = c2 (hint: you may need to use some 
--built-in functions!), and then update the table’s record with that value. If two values are missing, the DMBS should print 
--the text ‘insufficient data’. In all 3 cases, the values of the three variables should be printed to DBMS output.
--Test your code by inserting and modifying one record.
DROP TABLE INPUT;
CREATE TABLE INPUT (
	a NUMBER(5,2),
	b NUMBER(5,2),
	c NUMBER(5,2)); 

INSERT INTO INPUT i
      (i.a,i.b,i.c)
    VALUES
      (2, 2,null);
      
      

DECLARE 
	var_a NUMBER(5,2);
	var_b NUMBER(5,2);
	var_c NUMBER(5,2);
BEGIN 
  SELECT i.a, i.b, i.c INTO var_a, var_b, var_c FROM INPUT i; 
  IF (var_a IS NOT NULL AND var_b IS NOT NULL AND var_c IS NULL) THEN
    var_c := POWER(var_a,2) + POWER(var_b,2); 
    var_c := SQRT(var_c); 
   dbms_output.put_line('A: ' || var_a || ' B: ' || var_b || ' C: ' || var_c); 
  UPDATE INPUT set C = var_c;
  ELSIF (var_a IS NOT NULL AND var_b IS NULL AND var_c IS NOT NULL) THEN 
    var_b := POWER(var_c,2) - POWER(var_a,2); 
    var_b := SQRT(var_b); 
   dbms_output.put_line('A: ' || var_a || ' B: ' || var_b || ' C: ' || var_c); 
  UPDATE INPUT set b = var_b; 
  ELSIF (var_a IS NULL AND var_b IS NOT NULL AND var_c IS NOT NULL) THEN 
    var_a := POWER(var_c,2) - POWER(var_b,2);
    var_a := SQRT(var_a); 
   dbms_output.put_line('A: ' || var_a || ' B: ' || var_b || ' C: ' || var_c); 
  UPDATE INPUT set c = var_c; 
  ELSIF ((var_a IS NULL AND var_b IS NULL) OR (var_a IS NULL AND var_c IS NULL) OR (var_b IS NULL AND var_c IS NULL)) THEN 
   dbms_output.put_line('Insufficient data');
  END IF; 
END;

