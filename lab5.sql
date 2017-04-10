/*
1.	Create a getConnection method that obtains a connection the database. 
You will be connecting to the URL “jdbc:oracle:thin:@198.168.52.73:1521:orad11g”.
*/
/*
2.	Create objects to hold Customers, 
Orders, Books, Authors and Publishers. 
*/
/*
3.	Create a method that takes an ISBN and 
returns a populated Book object for the book that has that ISBN.
*/
/*
4.	Create a method that takes Book object and adds that Book to the database. 
(Several tables may need to be modified – use transactions).
*/

SELECT customer# FROM Customers JOIN orders USING(customer#);

SELECT * FROM books WHERE isbn = '1059831198';