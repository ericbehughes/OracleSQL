DROP TABLE ACTORS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE HOURS CASCADE CONSTRAINTS;
DROP TABLE INVENTORY CASCADE CONSTRAINTS;
DROP TABLE MOVIECUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE MOVIES CASCADE CONSTRAINTS;
DROP TABLE RENTALS CASCADE CONSTRAINTS;
DROP TABLE SPECIALS CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE SCHEDULE CASCADE CONSTRAINTS;
DROP TABLE STORECUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE SHIPMENTS CASCADE CONSTRAINTS;
DROP TABLE Movieactors cascade constraints;

CREATE TABLE Specials ----
(
SpecialID VARCHAR2(64),
Title VARCHAR2(64),
Discount NUMBER(4),
  CONSTRAINT Specials_SpecialID_pk PRIMARY KEY(SpecialID)
);

CREATE TABLE Movies ----
(
MovieID VARCHAR2(64),
SerialNum VARCHAR2(64) NOT NULL,
Title  VARCHAR2(64) NOT NULL,
Price NUMBER(6,2) NOT NULL,
Rating NUMBER(4),
Release_Date DATE,
Genre VARCHAR2(64),
IsOnSpecial CHAR(1),
SpecialID VARCHAR2(64),
  CONSTRAINT Movies_MovieID_pk PRIMARY KEY(MovieID),
  CONSTRAINT Movies_SpecialID_fk FOREIGN KEY (SpecialID)
    REFERENCES Specials(SpecialID)
);

CREATE TABLE StoreCustomers  ----
(
CustomerID VARCHAR2(64),
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
Phone_Number VARCHAR2(64) NOT NULL,
Address VARCHAR2(64) NOT NULL,
Late_Fees NUMBER(6,2),
ReferredBy VARCHAR2(64),
  CONSTRAINT StoreCustomers_CustomerID_pk PRIMARY KEY(CustomerID)
);
  
  
CREATE TABLE Actors ----
(
ActorID VARCHAR2(64),
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
  CONSTRAINT Actors_ActorID_pk PRIMARY KEY(ActorID)
);

CREATE TABLE MovieActors
(ActorID VARCHAR2(64), 
 MovieID VARCHAR2(64), 
  CONSTRAINT MovieActors_pk PRIMARY KEY (ActorID, MovieID),
  CONSTRAINT MovieActors_ActorID_fk FOREIGN KEY (ActorID)
             REFERENCES Actors (ActorID),
  CONSTRAINT MovieActors_MovieID_fk FOREIGN KEY (MovieID)
             REFERENCES Movies (MovieID));   
	
CREATE TABLE Employees
(
EmployeeID VARCHAR2(64),
ManagerID VARCHAR2(64) NOT NULL,
Address VARCHAR2(64) NOT NULL,
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
Phone_Number VARCHAR2(64) NOT NULL,
Title VARCHAR2(64) NOT NULL,
Salary NUMBER(20,2) NOT NULL,
Hire_Date DATE NOT NULL,
	CONSTRAINT Employees_EmployeeID_pk PRIMARY KEY(EmployeeID)
);

CREATE TABLE Shipments
(
ShipmentID VARCHAR2(64),
MovieID VARCHAR2(64),
Ship_Date DATE NOT NULL,
Ship_Street VARCHAR2(64) NOT NULL,
Ship_Country VARCHAR2(64) NOT NULL,
Title VARCHAR2(64),
Price NUMBER(6,2),
Genre VARCHAR2(64),
EmployeeID VARCHAR2(64),
ShipmentQuantity NUMBER(4),
  CONSTRAINT Shipments_ShipmentID_pk PRIMARY KEY(ShipmentID),
  CONSTRAINT Shipments_MovieID_fk FOREIGN KEY(MovieID)
  REFERENCES Movies(MovieID),
  CONSTRAINT Shipments_EmployeeID_fk FOREIGN KEY(EmployeeID)
  REFERENCES Employees(EmployeeID)
);

CREATE TABLE Inventory
(ShipmentID VARCHAR2(64), 
 MovieID VARCHAR2(64),
 TotalInStock NUMBER(4),
 TotalAvailable NUMBER(4),
  CONSTRAINT Inventory_pk PRIMARY KEY (ShipmentID, MovieID),
  CONSTRAINT Inventory_ShipID_fk FOREIGN KEY (ShipmentID)
             REFERENCES Shipments (ShipmentID),
  CONSTRAINT Inventory_MovieID_fk FOREIGN KEY (MovieID)
             REFERENCES Movies (MovieID)
);

CREATE TABLE Rentals
(
RentalID VARCHAR2(64),
CustomerID VARCHAR2(64),
EmployeeID VARCHAR2(64),
MovieID VARCHAR2(64),
SerialNumber VARCHAR2(64),
Date_Rented DATE NOT NULL,
Return_Date DATE NOT NULL,
Price Number(6,2),
SpecialID VARCHAR2(64),
Paid Number(6,2),
  CONSTRAINT Rentals_RentalID_pk Primary KEY(RentalID),
  CONSTRAINT Rentals_MovieID_fk FOREIGN KEY(MovieID)
  REFERENCES Movies(MovieID),
  CONSTRAINT Rentals_CustomerID_fk FOREIGN KEY(CustomerID)
  REFERENCES StoreCustomers(CustomerID),
  CONSTRAINT Rentals_SpecialID_fk FOREIGN KEY(SpecialID)
  REFERENCES Specials(SpecialID),
  CONSTRAINT Rentals_EmployeeID_fk FOREIGN KEY(EmployeeID)
  REFERENCES Employees(EmployeeID)
);
  
  
CREATE TABLE Schedule
  (
EmployeeID VARCHAR2(64),
CheckInTime VARCHAR2(64) NOT NULL,
CheckOutTime VARCHAR2(64) NOT NULL,
WorkDate DATE NOT NULL,
WeeklyHours NUMBER(4) NOT NULL,
    CONSTRAINT Hours_EmployeeId_fk FOREIGN KEY(EmployeeID)
    REFERENCES Employees(EmployeeID)
);

-- add an employee
INSERT INTO Employees 
VALUES('DM1234', 'MAN1234', '1234 fake street', 'Dom', 'Mazetti', '1-234-565-7890', 'customer_service' ,200,TO_DATE('2017-03-01','YYYY-MM-DD'));

-- add an employee
INSERT INTO Employees 
VALUES('EK982', 'MRROBOT', '1234 fake street', 'Elliot', 'Alderson', '1-234-565-7890', 'customer_service' ,200,TO_DATE('2017-03-01','YYYY-MM-DD'));


/*Add a new customer the store.*/
-- does not have join date, address needs some work 
INSERT INTO STORECUSTOMERS 
VALUES('0001','Eric', 'Hughes', '234-567-8802', '123 some other fake street', 80.00, NULL );

/*Add a new movie to the store.*/
INSERT INTO MOVIES 
VALUES('0001', 'A973MHFU8' ,'James Bond GoldenEye', 9.99, 95,TO_DATE('1972-03-01','YYYY-MM-DD'), 'Action', 0, null);

INSERT INTO MOVIES 
VALUES('0003', 'A931KFMD8' ,'Caddyshack', 9.99, 95, TO_DATE('1980-06- 25','YYYY-MM-DD'), 'Comedy', 0, null);

INSERT INTO MOVIES 
VALUES('0002', 'A48MFBHD7','Nothing Lasts Forever', 9.99, 95, TO_DATE('1984-09-25','YYYY-MM-DD'), 'science fiction', 0, null);

INSERT INTO MOVIES 
VALUES('0005', 'A48666HD7','Nothing Lasts Forever', 9.99, 95, TO_DATE('1984-09-25','YYYY-MM-DD'), 'science fiction', 0, null);


/*Rent out a movie to a customer.*/
INSERT INTO rentals 
VALUES('0001', '0001', 'DM1234', '0003', 'A931KFMD8' ,TO_DATE('2017-06- 25','YYYY-MM-DD'), TO_DATE('2017-06- 29','YYYY-MM-DD'), 5.99, null, 5.99);
  
INSERT INTO rentals 
VALUES('0002', '0001', 'DM1234','0002', 'A48MFBHD7', TO_DATE('2017-03-01','YYYY-MM-DD'), TO_DATE('2017-03-07','YYYY-MM-DD'), 5.99, null, 5.99);
  
  INSERT INTO rentals 
VALUES('0003', '0001', 'EK982','0002', 'A48MFBHD7', TO_DATE('2017-03-07','YYYY-MM-DD'), TO_DATE('2017-03-17','YYYY-MM-DD'), 5.99, null, 5.99);
  
  
 /* Add an Actor */
 INSERT INTO ACTORS
 VALUES ('0391','bill', 'murray');
 
 INSERT INTO MOVIEACTORS
 VALUES ('0391', '0003');
 
  INSERT INTO MOVIEACTORS
 VALUES ('0391', '0005');
 
/*Find all currently available science fiction movies starring Bill Murray.*/

Select title, movieID from movies
join MovieActors using(movieID) 
join Actors using(ActorID)
where actors.First_Name = 'bill' AND Actors.Last_Name = 'murray'
AND Movies.Genre = 'science fiction'
AND Movies.Rented = 0;

/*Find the employee who has sold the most movies between March 1, 2017 and March 7 2017.*/

Select First_Name, Last_Name, EmployeeID from Employees JOIN RENTALS using(EmployeeID) GROUP BY First_Name, Last_Name, EmployeeID HAVING count(EmployeeID) =
(Select MAX(COUNT(EmployeeID)) from Rentals WHERE Date_Rented BETWEEN TO_DATE('2017-03-01','YYYY-MM-DD') AND TO_DATE('2017-03-07','YYYY-MM-DD')
GROUP BY First_Name, Last_Name, EmployeeID);

