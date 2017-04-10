CREATE TABLE Movies
(
MovieID NUMBER(4) ,
Title  VARCHAR2(64) NOT NULL,
Category VARCHAR2(64),
Price NUMBER(6,2) NOT NULL,
Rented CHAR(10),
Rating NUMBER(4),
Release_Date DATE,
Genre VARCHAR2(64),
IsOnSpecial CHAR(1),
  CONSTRAINT Movies_movieID_pk PRIMARY KEY(MovieID));
  
CREATE TABLE Specials 
(
Title VARCHAR2(64) NOT NULL,
MovieID NUMBER(4),
Discount NUMBER(4),
  CONSTRAINT Specials_Tital_pk PRIMARY KEY(Title),
  CONSTRAINT Specials_MovieID_fk FOREIGN KEY (MovieID)
    REFERENCES Movies(MovieID)
);

CREATE TABLE MovieCustomers 
(
CustomerID NUMBER(4),
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
Phone_Number NUMBER(10),
Address VARCHAR2(64),
Late_Fees NUMBER(6,2),
ReferralID NUMBER(4),
  CONSTRAINT Customers_CustomerID_pk PRIMARY KEY(CustomerID)
);
  
CREATE TABLE Actors 
(
ActorID NUMBER(4),
MovieID NUMBER(4),
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
  CONSTRAINT Actors_ActorID_pk PRIMARY KEY(ActorID),
  CONSTRAINT Actors_MovieID_fk FOREIGN KEY (MovieID)
    REFERENCES Movies(MovieID)
);
	

CREATE TABLE Inventory
(
MovieID NUMBER(4),
Ship_Date DATE,
Ship_Street VARCHAR2(64),
Ship_Country VARCHAR2(64),
Quantity NUMBER(4),
Title VARCHAR2(64),
Category VARCHAR2(64),
Price NUMBER(6,2),
  CONSTRAINT Movies_movieID_fk FOREIGN KEY(MovieID)
  REFERENCES Movies(MovieID)
);

  
CREATE TABLE Employees
(
EmployeeID NUMBER(4),
ManagerID NUMBER(4),
Address VARCHAR2(64),
First_Name VARCHAR2(64) NOT NULL,
Last_Name VARCHAR2(64) NOT NULL,
Phone_Number VARCHAR2(64),
Title VARCHAR2(64),
Salary NUMBER(20),
Hire_Date DATE,
	CONSTRAINT Employees_EmployeeID_pk PRIMARY KEY(EmployeeID)
);
	
CREATE TABLE Rentals
(
RentalID Number(4),
CustomerName VARCHAR2(64),
MovieID NUMBER(4),
Date_Rented DATE,
Return_Date DATE,
CustomerID NUMBER(4),
Price Number(6,2),
Discount Number(6,2),
Paid Number(6,2),
EmployeeID NUMBER(4),
  CONSTRAINT Rentals_RentalID_pk Primary KEY(RentalID),
  CONSTRAINT Rentals_MovieID_fk FOREIGN KEY(MovieID)
  REFERENCES Movies(MovieID),
  CONSTRAINT Rentals_CustomerID_fk FOREIGN KEY(CustomerID)
  REFERENCES MovieCustomers(CustomerID),
  CONSTRAINT Rentals_EmployeeID_fk FOREIGN KEY(EmployeeID)
  REFERENCES Employees(EmployeeID)
  );
  
  
  CREATE TABLE Hours
  (
EmployeeID NUMBER(4),
CheckInTime VARCHAR2(64),
CheckOutTime VARCHAR2(64),
CheckInDate DATE,
WeeklyHours NUMBER(4),
    CONSTRAINT Hours_EmployeeId_fk FOREIGN KEY(EmployeeID)
    REFERENCES Employees(EmployeeID)
);

  
/*Find all currently available science fiction movies starring Bill Murray.*/

Select title from Movies 
join Actors using(movieID) 
where actor.First_Name = 'Bill' AND Actor.Last_Name = 'Murray' 
AND Movies.Category = 'Science Fiction';

/*Find the employee who has sold the most movies between March 1, 2017 and March 7 2017.*/

Select firstname, lastname from Employees where EmployeeID = 
(Select MAX(EmployeeID) from Rentals WHERE Date_Rented BETWEEN TO_DATE('2017-03-01','YYYY-MM-DD') AND TO_DATE('2017-03-07','YYYY-MM-DD')
);

-- add an employee
INSERT INTO Employees 
VALUES(0001, 0002, '1234 fake street', 'Dom', 'Mazetti', '123-4565-7890', 'customer_service',200,TO_DATE('2017-03-01','YYYY-MM-DD'));

/*Add a new movie to the store.*/
INSERT INTO MOVIES 
VALUES(0002, 'James Bond GoldenEye', 'Adventure' , 9.99, 1, 5,TO_DATE('1972-03-01','YYYY-MM-DD'), 'thriller', 0);

/*Add a new customer the store.*/
-- does not have join date, address needs some work 
INSERT INTO MOVIECUSTOMERS 
VALUES(0001,'Eric', 'Hughes', '123-456-7880', '123 some other fake street', 80.00 );

/*Rent out a movie to a customer.*/
INSERT INTO Rentals
VALUES(0001, TO_DATE('2017-04-27','YYYY-MM-DD'), TO_DATE('2017-05-01','YYYY-MM-DD'), 2, 1, 4.99, 0, 4.99, 1);

/*What roles should exist in your database? What privileges should each role have?
 *A: db_owner: SysAdmin and has root privileges (he is god)
 *   DDL_ADMIN: Any developper who isn't the owner but needs database permission
				Can insert, read and modify table data
	Data Reader: Can only read data
*/

/*Explain in briefly in English some of the forms and reports that will be necessary on a regular basis to present and enter data into the database.
 *A: PunchIn/PunchOut: A form the employee will enter with their employeeID at the beginning and end of each day
 *   Rental: A form that the employee fills in on the cash when renting out a movie
 *   Receipt: A report the customer will receive after the rental form is filled out and the movie is paid for
 *   Returned: A form the manager will fill out once a movie is retreived from the return slot
	 Cash Log: A form the manager fills out at the end of the day after the store closes to make sure the money in the cash is the proper amount for the day
 */