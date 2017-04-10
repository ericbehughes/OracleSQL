--1.	Create a subprogram that will take as input the ISBN of a book and with 
--give as output the retail price after a tax of 15% has been applied and 
--the discount in the discount field has been applied. 

DECLARE
		booktitle varchar2(30) := '1059831198';
		newTotal NUMBER(5) := 0;
BEGIN
		newTotal := calculateRetailOfBook(booktitle);
		dbms_output.put_line(newTotal);
END;


CREATE or REPLACE FUNCTION calculateRetailOfBook(bookIsbn IN varchar2) RETURN NUMBER
AS
		newTotal NUMBER(5,2) := 0;
BEGIN
    DBMS_OUTPUT.put_line(bookIsbn);
		SELECT  b.COST INTO newTotal FROM BOOKS b WHERE b.ISBN = bookIsbn;
    DBMS_OUTPUT.put_line(newTotal);
    return newTotal;
END;

--2.	Create a subprogram that takes as input a customer ID and cancels any unshipped orders 
--for that customer ID.
create or replace procedure cancelShip(custId in number) as
  type custOrders is varray(10) of number(4);
  cancelOrders custOrders;
  orderNum number(4);
begin
  select order# bulk collect into cancelOrders from orders where customer# = custId and shipdate is null;
  FOR i IN 1..cancelOrders.last LOOP
    delete from orderitems where order# = cancelOrders(i);
    delete from orders where order# = cancelOrders(i);
  END LOOP;

end;

execute cancelShip(1017);
--2a. Create a subprogram that takes an ISBN and gives as output the type of promotion 
--that the book with that ISBN is eligible for.
create or replace procedure proType (bookIsbn in number) as
  custGift VARCHAR2(15);
begin
  SELECT gift into custGift FROM promotion INNER JOIN books ON books.retail between promotion.minretail and promotion.maxretail 
  where isbn = bookIsbn;
  dbms_output.put_line('Gift: ' || custGift);
end;

execute proType('1059831198');
--2b.	 The Justlee database wants to be able to easily determine whether an order 
--is valid for FREE SHIPPING. Use the subprogram written in part 2 to write a 
---subprogram that takes as input an order number and gives as output the string 
--‘FREE SHIPPING’ if the order is eligble for free shipping, or ‘NO FREE SHIPPING’ otherwise.
create or replace procedure freeShipping (orderNum in number) as
  type totalPrice is varray(10) of number(5,2);
  sumPrice totalPrice;
  finalPrice number(5,2) := 0;
  custGift varchar2(15);
begin
  dbms_output.put_line('order# : ' || orderNum);
  select paideach bulk collect into sumPrice from orderitems where order# = orderNum;
  dbms_output.put_line('count : ' || sumPrice.count);
  FOR i IN 1..sumPrice.last LOOP
       finalPrice := finalPrice + sumPrice(i);
      dbms_output.put_line('added : ' || sumPrice(i));
  END LOOP;
  dbms_output.put_line('final price : ' || finalPrice);
  SELECT gift into custGift FROM promotion where finalPrice between promotion.minretail and promotion.maxretail;
  dbms_output.put_line('gift : ' || custGift);
  if (custGift = 'FREE SHIPPING') then
    dbms_output.put_line('FREE SHIPPING!');
  else
    dbms_output.put_line('NOT FREE SHIPPING');
  end if;
end;

execute freeShipping(1001);
---3.	Create a subprogram that creates an order for a book. It should take 
--as input both a client number and an ISBN, as well as all other information necessary 
--to create the order of that book.
CREATE or REPLACE PROCEDURE createBookOrder(clientNo IN NUMBER, bookIsbn IN varchar2 )
AS
  custAddress VARCHAR2(20);
  custCity VARCHAR2(12);
  custState VARCHAR2(2);
  custZip VARCHAR2(5);
  orderNo NUMBER(4);
  itemNo NUMBER(2) := 1;
  
  
BEGIN
  SELECT address, city, state, zip INTO custAddress, custCity, custState,
  custZip FROM customers WHERE customer# = clientNo;
  
  SELECT retail INTO bookPrice FROM books WHERE ISBN = bookISBN;
  
  SELECT MAX(order#)INTO orderNo FROM orders;
  orderNo := orderNo + 1;
  
  INSERT INTO orders VALUES(orderNo, clientNo, SYSDATE, null, custAddress,
  custCity, custState, custZip, null);

  insert into orderitems values(orderNo, itemNo, bookIsbn, 1, bookPrice);
END;

execute createBookOrder(1001, '1059831198');
--4.	Create a subprogram that finds the book of the month. It should take as input a date 
--to find the book of the month for. The book of the month is the book that has been purchased 
--the most times in that month (if two books have been bought an equal number of times, choose one).

DECLARE 
  somevar VARCHAR2(60);
BEGIN
  somevar := getBookOfMonth(TO_DATE('31-MAR-09'));
 dbms_output.put_line(somevar);
END;

CREATE or REPLACE FUNCTION getBookOfMonth(timeWindow IN DATE) RETURN varchar2
AS
-- make array of all books
-- make array of book orders count
  TYPE books IS VARRAY(100) OF VARCHAR2;
  TYPE bookCount IS TABLE OF NUMBER(5) INDEX BY VARCHAR2(10);
  bookIsbnArray books; -- array of isbns for each book as varchar
  bookCountArray bookCount; -- array of isbn order count indexed by ISBN
  indice varchar2(10); -- isbn index of books
  quantitee Number(5);
  mostPopular varchar2(10);
  bookMax Number(5) := 0;
BEGIN
-- get all isbns where order date is between timeframe into array 
-- the array type of this is VARRAY of 
    SELECT distinct isbn BULK COLLECT INTO bookIsbnArray FROM orderitems
    JOIN orders USING(order#) WHERE substr(orderdate, 4,3) = substr(timeWindow, 4,3);
    
    --create array of isbn orders indexed by isbn
    FOR i IN 1 .. bookIsbnArray.count LOOP
    SELECT sum(quantity) INTO quantitee FROM orderitems WHERE isbn = bookIsbnArray(i);
    bookCountArray(bookIsbnArray(i)) := quantitee;
  END LOOP;
  
  indice := bookCountArray.FIRST;
  WHILE indice IS NOT NULL LOOP
      quantitee := bookCountArray(indice);

        IF(quantitee >  bookMax) THEN
          mostPopular := indice;
          bookMax := quantitee;
        END IF;
      indice := bookCountArray.NEXT(indice);
  END LOOP;
          
  RETURN mostPopular;
END;

--5.	Create a procedure that takes as input a category and a discount amount and applies a discount 
--to all the books in the given category 
CREATE or REPLACE PROCEDURE makeDiscount( newCategory IN varchar2, newDiscount IN number ) AS
BEGIN
 update books set discount = newDiscount where category = newCategory;
END;

execute makeDiscount('FITNESS', .15);
