alter table rentals add returned char(1) default 1 not null;
update rentals set returned = '0' where returned = '1';


--Film in stock – Create a subprogram that determines if a film is currently available for rent.
create or replace function filmInStock(movieTitle in varchar2) RETURN CHAR AS
--variables
numOfFreeMovies number(4) := 0;
begin 
SELECT COUNT(movieid) INTO numOfFreeMovies FROM inventory 
JOIN MOVIES using(movieid)
WHERE movieTitle = title AND totalavailable > 0
GROUP BY movieid;
IF numOfFreeMovies > 0 then
dbms_output.put_line('yes the movie is in stock');
return '1';
else 
dbms_output.put_line('no the movie is not in stock');
return '0';
end if;
end;
-- run function 
DECLARE
		movie char(1) := 0;
BEGIN
		movie := filmInStock('Nothing Lasts Forever');
		dbms_output.put_line(movie);
END;


--Calculate Late Fees – Calculates a customer’s late fees.
create or replace procedure calculateLateFees(custId in varchar2) as
--variables
latefees number(6,2) := 0;
type dlate is varray(10) of number(4);
days_late dlate ;
BEGIN
SELECT  TO_NUMBER(TO_DATE(current_date) - TO_DATE(return_date))BULK COLLECT INTO days_late FROM rentals
  WHERE TO_DATE(current_date) - TO_DATE(return_date) > 0 AND returned = '1'
  group by rentalid, serialnumber, TO_NUMBER(TO_DATE(current_date) - TO_DATE(return_date));
  
  FOR i IN 1..days_late.last LOOP
    dbms_output.put_line(days_late(i));
    latefees := 50 * days_late(i);
  end LOOP;
  dbms_output.put_line(latefees);
END;
execute calculateLateFees('0001' );

-- rent movie
CREATE OR REPLACE PROCEDURE RentMovie(custID IN VARCHAR2, movID IN VARCHAR2)
AS
  SerialNumber VARCHAR2(64);
  MovPrice NUMBER(4);
BEGIN
	  Select SerialNum, Price INTO SerialNumber, MovPrice FROM Movies where movies.MovieID = movID;
	  INSERT INTO rentals
	  VALUES('R'||custID||movID, custID, 'DM1234', movID, SerialNumber,TO_DATE('2017-06- 25','YYYY-MM-DD'), TO_DATE('2017-06- 29','YYYY-MM-DD'), MovPrice, null, MovPrice);
END;

execute RentMovie('0001', '0003');


/*Get Total Rented – Create a subprogram that counts the total number of films a customer has rented*/
CREATE OR REPLACE PROCEDURE GetRented(custID IN VARCHAR2)
AS
  total NUMBER(4);
BEGIN
	Select count(customerID) INTO total FROM rentals where customerID = custID;
	dbms_output.put_line('Total number of movies rented: ' || total);
END;

execute GetRented('0001');

/*Customer Report – Create a subprogram that lists each customer along with the total number of movies they currently have out, and total amount of movies they have rented in the past month.*/
/*Customer Report – Create a subprogram that lists each customer along with the total number of movies they currently have out, and total amount of movies they have rented in the past month.*/
CREATE OR REPLACE PROCEDURE CustomerReport
AS
	TYPE CustomersVarray IS VARRAY(10) of VARCHAR2(64);
	Customers CustomersVarray;
	total NUMBER(4);
	MonthlyTotal NUMBER(4);
BEGIN
	SELECT CustomerID BULK COLLECT INTO Customers
	FROM StoreCustomers;
	FOR i IN 1..Customers.COUNT LOOP
		SELECT count(CustomerID) INTO total FROM rentals WHERE customerID = Customers(i);
		SELECT count(customerID) INTO MonthlyTOtal FROM rentals WHERE customerID = Customers(i)
		AND Date_Rented BETWEEN TO_DATE('2017-03-01','YYYY-MM-DD') AND TO_DATE('2017-03-30','YYYY-MM-DD');
		dbms_output.put_line('Total movies rented for customer ' || Customers(i)|| ': ' || total);
		dbms_output.put_line('Monthly movies rented for customer ' || Customers(i)|| ': ' || MOnthlyTotal);
	END LOOP;
END;

EXECUTE CustomerReport;

-------------------Triggers----------------------
/* 1. Rental Log – Create a trigger which logs movie rentals and returns,
indicating who has rented movies and when */
CREATE OR REPLACE TRIGGER AFTER_RENTALS_INSERTORUPDATE
after INSERT OR UPDATE
ON Rentals
FOR EACH ROW
DECLARE
	inStock CHAR(1) := :NEW.Returned;
BEGIN
	dbms_output.put_line('Rental ID..: ' || :new.rentalid);
	dbms_output.put_line('Customer ID: ' || :new.CustomerID);
	dbms_output.put_line('Movie ID...: ' || :new.MovieID);
	dbms_output.put_line('Date rented: ' || :new.Date_Rented);
	dbms_output.put_line('Return date: ' || :new.Return_Date);
	IF (inStock = '1') THEN
		dbms_output.put_line('Returned?..: Yes' );
	ELSE
		dbms_output.put_line('Returned?..: No'  );
	END IF;
END;

INSERT INTO rentals VALUES('0007', '0001', 'DM1234', '0004', 'A931KFMD8' ,TO_DATE('2017-06- 25','YYYY-MM-DD'), 
TO_DATE('2017-06- 29','YYYY-MM-DD'), 5.99, null, 5.99,'1');
  
/* 2. Quantity Update – Create a trigger that automatically updates the quantity of movies in 
stock when a film is rented or returned. */
 CREATE OR REPLACE TRIGGER AFTER_RENTALS_INSERTORUPDATE
 AFTER INSERT OR UPDATE
 ON RENTALS
 FOR EACH ROW
BEGIN
if :NEW.Returned = 0 THEN
	UPDATE Inventory SET TotalAvailable = (TotalAvailable - 1) 
	WHERE MovieID = :NEW.MovieID;
ELSIF :NEW.Returned = 1 THEN
	UPDATE Inventory SET TotalAvailable = (TotalAvailable + 1) 
	WHERE MovieID = :NEW.MovieID;
END IF;
END;

-- INSTRUCTIONS
-- check if movie has been rented last 30 days in table from input from INSERT
-- and quantity isnt 1
CREATE OR REPLACE TRIGGER BEFORE_RENTALS_CanRent
BEFORE INSERT OR UPDATE
ON RENTALS
 FOR EACH ROW
DECLARE 
no_records number(4);
ex_custom       EXCEPTION;
PRAGMA EXCEPTION_INIT( ex_custom, -20001 );
BEGIN
  -- select if customer has rented movie from input 
  -- and has been in last 30 days
  SELECT count(movieid) INTO no_records FROM RENTALS 
  JOIN inventory using(movieid)
  where customerID = :new.customerid
  and TO_DATE(:new.date_rented,'YYYY-MM-DD') -
  TO_DATE(date_rented,'YYYY-MM-DD')
   < 30 and TotalAvailable = 1;
   
  if no_records != 0 then
    RAISE_APPLICATION_ERROR(-20101, 'You cannot rent out the last movie');
    ROLLBACK;
  end if;    
end;  

/*Find the movie that has been rented the most*/
CREATE OR REPLACE PROCEDURE MostCommonMovie
AS
  total NUMBER(4);
  movID VARCHAR2(64);
  title VARCHAR2(64);
BEGIN
Select MovieID, count(MovieID) into movID, total from rentals GROUP BY MovieID HAVING count(MovieID) = 
(Select MAX(COUNT(MovieID)) from Rentals GROUP BY MovieID);  SELECT Title into title from Movies where MovieID = movID;
  Select title into title from movies where movieID = movid;
	dbms_output.put_line('Movie rented the most often: ID: '|| movID|| ' : ' || title || ' rented ' || total || ' time(s)');
END;

execute MostCommonMovie;

/*Find the customer who has referred the most amount of customers*/
CREATE OR REPLACE PROCEDURE MostReferrals
AS
  total NUMBER(4);
  custID VARCHAR2(64);
  FirstName VARCHAR2(64);
  LastName VARCHAR2(64);
BEGIN  
Select REFERREDBY, count(REFERREDBY) into custID, total from Storecustomers GROUP BY REFERREDBY HAVING count(REFERREDBY) = 
(Select MAX(COUNT(REFERREDBY)) from Storecustomers GROUP BY REFERREDBY);  
  Select First_Name, Last_Name into FirstName, LastName from Storecustomers where customerid = custID;
	dbms_output.put_line('Customer with the most referrals: ' || custID || ' ' || FirstName || ' ' || LastName);
END;

execute MostReferrals;


INSERT INTO STORECUSTOMERS 
VALUES('0007','Eric', 'Hughes', '234-567-8802', '123 some other fake street', 80.00, '0001' );

INSERT INTO STORECUSTOMERS 
VALUES('0008','Eric', 'Hughes', '234-567-8802', '123 some other fake street', 80.00, '0001' );

/*Automatically update inventory with new shipments*/
CREATE OR REPLACE TRIGGER AFTER_SHIPMENTS_UpdateInv
AFTER INSERT OR UPDATE
ON SHIPMENTS
 FOR EACH ROW
DECLARE 
BEGIN
    INSERT INTO Inventory VALUES (:new.shipmentID, :new.MovieID, :new.shipmentQuantity, :new.ShipmentQuantity);
 dbms_output.put_line(:new.shipmentID || ' ' || :new.MovieID || ' ' || :new.Shipmentquantity);
end;  

Insert into SHIPMENTS VALUES ('aasdA1', '0002', TO_DATE('2017-06- 25','YYYY-MM-DD'), 'street', 
'country', 'title', 9.99, 'action',  'DM1234', 100);
  