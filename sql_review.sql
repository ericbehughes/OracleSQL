SELECT firstname, lastname, referred FROM CUSTOMERS;

SELECT c1.firstname, c1.lastname, c1.referred AS "REFERREDBY", c2.firstname, c2.lastname
 FROM CUSTOMERS c1 
INNER JOIN CUSTOMERS c2 ON c1.referred = c2.customer#;

-- show a list of books and the promotional gift that would be given for buying that book
--SELECT b.title, b.retail,NVL(b.retail-b.discount,0) AS "PROMO" FROM BOOKS b;
SELECT b.title, p.gift FROM books b JOIN promotion p 
ON b.retail BETWEEN p.minretail and p.maxretail;

-- how can we find all books published by either printing is us or publish our way
SELECT pub.PUBID, pub.NAME, b.Title FROM PUBLISHER pub 
JOIN BOOKS b ON pub.PUBID = b.PUBID 
WHERE pub.NAME IN ('PRINTING IS US' ,'PUBLISH OUR WAY');

-- show all books published by printing is us, 
--which are written by which are on order by james austin
(SELECT title FROM books INNER JOIN publisher 
ON books.PUBID = publisher.PUBID 
WHERE publisher.NAME = 'PRINTING IS US')
UNION 
(SELECT title FROM books INNER JOIN bookauthor
ON books.ISBN = bookauthor.isbn INNER JOIN author ON
author.authorID = bookauthor.authorID
WHERE author.LNAME = 'AUSTIN');

--which books were published by american publishing AND writren by james austin
(SELECT title FROM books JOIN publisher
ON books.PUBID = publisher.PUBID
WHERE publisher.NAME = 'AMERICAN PUBLISHING')
INTERSECT
(SELECT title FROM books b JOIN BOOKAUTHOR ba
ON b.ISBN = ba.ISBN JOIN AUTHOR a ON ba.AUTHORID
= a.AUTHORID WHERE a.LNAME='AUSTIN');

SELECT customer# FROM customers
INTERSECT
SELECT CUSTOMER# FROM orders;

SELECT order#,customer# FROM orders
UNION ALL
SELECT customer#,referred FROM customers;

-- aggregate functions
--we want to know the average retail price of alll books we have for sale
SELECT ROUND(AVG(b.retail),2) AS RETAIL FROM books b;

--what if we want to show the average price of each book 
-- in each category.
SELECT AVG(b.retail) AS AVERAGE FROM books b
WHERE b.CATEGORY = 'COMPUTER'
GROUP BY b.CATEGORY;

-- for every publisher, how many books do we sell in each category
SELECT CATEGORY, PUBID, COUNT(title) FROM books
GROUP BY CATEGORY, PUBID;

SELECT category, AVG(retail) FROM books 
GROUP BY category HAVING (retail>AVG(retail));

/*GROUP BY allows us to answer more complex questions:

What is the average price of books in each category?
What is the oldest book in each category?
What is the sum of the cost of all of an author’s books?
*/

--We want to show those teachers who are being paid more than the lowest paid 
--teacher in the biology department.

SELECT FULLNAME FROM uni_lecturer
WHERE salary >
(SELECT MIN(salary) FROM uni_lecturer
JOIN uni_department USING(dept_id)
WHERE uni_department.NAME = 'Biology');

-- show teachers who are over budget

SELECT fullname FROM uni_lecturer
WHERE dept_id IN (SELECT d.dept_id FROM uni_department d 
JOIN uni_lecturer l ON l.dept_id = d.dept_id
GROUP BY d.budget,d.dept_id
HAVING SUM(salary) > budget);

-- finding lecturers who are being paid less than 
-- the average for their department
/*
SELECT l.fullname FROM uni_lecturer l
JOIN 	(SELECT dept_id, AVG(salary) FROM uni_department
			JOIN uni_lecturer USING (dept_id))
WHERE l.salary < 
  (SELECT avg(sl.salary) FROM uni_lecturer sl
  WHERE sl.dept_id = l.dept_id);
  */

/*
SELECT S.ID, S.name
FROM student S
WHERE NOT EXISTS ((SELECT courseid FROM course
					WHERE dept_name = 'Biology') 
	    		    EXCEPT 
				   ((SELECT T.course_id
					 FROM takes AS T
					 WHERE S.ID = T.ID);

*/

WITH maxbudget (value) AS 
	(SELECT MAX(budget)
 	FROM uni_department)
SELECT budget
FROM uni_department, maxbudget
WHERE uni_department.budget = maxbudget.value;

--Consider we want to find all lecturers who are paid more than everyone in the 
--History department. How can we split this up?

SELECT * FROM uni_lecturer 
WHERE salary > 
(SELECT MAX(salary) FROM uni_lecturer  JOIN uni_department 
USING(dept_id) WHERE uni_department.NAME = 'History');

-- find students who have not failed any courses
-- for each student find the courses they have failed
-- select those students where do not exist in any failed classes 

SELECT s.fullname FROM uni_student s WHERE NOT EXISTS
(SELECT e.course_id FROM uni_student ss 
JOIN uni_enrollment e ON e.stud_id = ss.stud_id
WHERE grade <60 AND ss.stud_id = s.stud_id);

SELECT b.title, a.fname FROM books b JOIN
bookauthor ba USING(ISBN) JOIN author a USING(AUTHORID);

-- list all customer who has ordered one of jack baker's books
-- each customer should appear only once
SELECT customer# FROM customers c JOIN orders USING (customer#)
JOIN orderitems oi USING(order#)
JOIN bookauthor ba USING(ISBN)
JOIN author a USING(authorID)
WHERE a.LNAME = 'BAKER';

-- produce a list of all customers who live in florida and have ordered books about
-- computers

SELECT * FROM customers c JOIN orders o USING(customer#)
JOIN orderitems oi USING(order#) JOIN books b USING(ISBN)
WHERE category = 'COMPUTER' AND c.STATE = 'FL';

-- show names of all authors and shows name of publishers which 
-- have published them
SELECT DISTINCT a.FNAME, a.LNAME, p.NAME FROM author a JOIN bookauthor ba USING(authorID)
JOIN books b USING(ISBN) JOIN publisher p USING(pubID);

-- show titles of books jake lucas has ordered, showing each only once
SELECT * FROM customers c JOIN orders o USING(customer#)
JOIN orderitems oi USING(order#) JOIN books b USING(ISBN)
WHERE c.FIRSTNAME =UPPER('Jake') AND c.LASTNAME = UPPER('Lucas');

-- show a list of customers and the titles of books which the person 
-- who referred them has ordered 
SELECT * FROM customers c1 JOIN customers c2 USING(customer#)
JOIN orders o ON c1.REFERRED = o.CUSTOMER#;

-- for each order number list which promotional gifts should be sent with that order
SELECT ot.ORDER#, p.GIFT FROM ORDERITEMS ot INNER JOIN BOOKS b
ON ot.ISBN = b.ISBN
INNER JOIN PROMOTION p
ON b.RETAIL BETWEEN p.MINRETAIL AND p.MAXRETAIL;

-- using set operators show a list of promotional gifts that can be acquired
-- from books published by printing is us or written by jack baker
SELECT promo.gift FROM author a JOIN bookauthor ba USING(authorid)
JOIN books b USING(ISBN) JOIN promotion promo ON b.retail BETWEEN promo.minretail AND promo.maxretail
WHERE a.FNAME = UPPER('Jack') AND a.LNAME = UPPER('Baker')
UNION
SELECT promo.gift FROM publisher p JOIN books b USING(pubid)
JOIN promotion promo ON b.retail BETWEEN promo.minretail AND promo.maxretail
WHERE p.name = 'PRINTING IS US'; 

-- for each department show the name of the department and the difference in salary 
-- between their highest and least paid 
SELECT ud.name, MAX(salary) - MIN(salary) FROM uni_lecturer ul JOIN uni_department ud
USING(dept_id)
GROUP BY NAME;

-- for each course show the title of the course and the number of students who 
-- have taken the course or are currently enrolled
SELECT TITLE, COUNT(S.STUD_ID) FROM UNI_STUDENT S 
JOIN UNI_ENROLLMENT E ON E.STUD_ID = S.STUD_ID
JOIN UNI_COURSE C ON C.COURSE_ID = E.COURSE_ID 
GROUP BY TITLE;

SELECT fullname, AVG(grade) FROM uni_student s JOIN uni_enrollment e
USING(stud_id) WHERE grade IS NOT NULL
GROUP BY fullname;

-- show names of departments whose budget is over 100 000 
SELECT distinct d.name, d.budget FROM uni_department d JOIN uni_lecturer l 
USING(dept_id) WHERE budget > 100000
HAVING SUM(salary) > budget;-- come back to this question

-- show the title of courses whose class average is over 80 or which are 
--taught by lecturers in the comp sci department
(SELECT TITLE FROM UNI_COURSE C JOIN UNI_ENROLLMENT E
ON C.COURSE_ID = E.COURSE_ID GROUP BY TITLE HAVING AVG(E.GRADE) > 80)
UNION
(SELECT TITLE FROM UNI_COURSE C JOIN UNI_LECTURER L 
ON C.LEC_ID = L.LEC_ID JOIN UNI_DEPARTMENT D ON L.DEPT_ID = D.DEPT_ID
WHERE D.NAME = 'Computer Science');

-- show the name and age (in years) of each student with an avergae over 80

SELECT s.fullname, avg(grade), ROUND((MONTHS_BETWEEN(CURRENT_DATE, s.DOB)/12)) 
FROM uni_student s JOIN uni_enrollment e USING(stud_id)
HAVING AVG(grade) > 80 GROUP BY s.fullname, ROUND((MONTHS_BETWEEN(CURRENT_DATE, s.DOB)/12));

-- show the names of students that have taken courses in the history department
-- and names of lecturers in the history department
SELECT s.FULLNAME FROM uni_student s JOIN uni_enrollment e USING(stud_id)
JOIN uni_course c USING(course_id) JOIN uni_department d USING(dept_id) WHERE
d.NAME = 'History'
UNION 
SELECT l.FULLNAME FROM uni_lecturer l JOIN uni_department d USING(dept_id)
WHERE d.NAME = 'History';

-- for each course being taught by a professor outside of their department
-- show the title of the course with each instance of  'bio being replaced with 'Quantum'
SELECT REPLACE(C.TITLE, 'Bio', 'Quantum') 
FROM UNI_STUDENT S JOIN UNI_ENROLLMENT E ON S.STUD_ID = E.STUD_ID 
RIGHT JOIN UNI_COURSE C ON E.COURSE_ID = C.COURSE_ID 
JOIN UNI_LECTURER L ON C.LEC_ID = L.LEC_ID 
WHERE  C.DEPT_ID != L.DEPT_ID GROUP BY C.TITLE;

SELECT DISTINCT  title FROM uni_course left JOIN uni_enrollment USING(course_id);

-- show the names of students who are in one of mort mortensons classes
-- find all courses that mort teaches as list
-- search all enrolled students who are in list

SELECT distinct s.fullname FROM uni_student s JOIN uni_enrollment e USING(stud_id)
WHERE e.COURSE_ID IN ( 
SELECT c.COURSE_ID FROM uni_course c JOIN uni_lecturer l USING(lec_id)
WHERE l.FULLNAME = 'Mort Mortenson');

-- for each class, list the class name and the names of students who earned an above
-- average grade
SELECT S.FULLNAME, C.TITLE 
FROM UNI_COURSE C JOIN UNI_ENROLLMENT E ON E.COURSE_ID = C.COURSE_ID 
JOIN UNI_STUDENT S ON E.STUD_ID = S.STUD_ID JOIN
(SELECT E.COURSE_ID, AVG(E.GRADE) AS CLASSAVG FROM UNI_ENROLLMENT E JOIN UNI_COURSE C ON E.COURSE_ID = C.COURSE_ID 
GROUP BY E.COURSE_ID, C.TITLE) CA
ON E.COURSE_ID  = CA.COURSE_ID
WHERE E.GRADE > CA.CLASSAVG;

-- for each department, list the names of instructors who are teaching an above average 
-- number of courses

-- find the number of courses each lecturer teaches
-- find the average of that count
-- join each lecturer 
SELECT fullname FROM uni_lecturer l JOIN uni_course c USING (lec_id)
JOIN 
(SELECT dept_id, avg(course#) avgcourses FROM uni_department  JOIN
(SELECT l.dept_id, count(l.fullname) AS course# 
FROM uni_lecturer l JOIN uni_course c USING (lec_id) 
GROUP BY l.fullname, l.dept_id) 
USING (dept_id) GROUP BY dept_id) sq
ON sq.dept_id = l.dept_id
GROUP BY l.fullname, avgcourses 
HAVING count(l.fullname) > avgcourses;

SELECT AVG(numofcourses) FROM uni_department d JOIN (
SELECT l.fullname, COUNT(l.fullname) as numofcourses FROM uni_lecturer l JOIN uni_course c
USING(lec_id) GROUP BY l.fullname) coursecount;



-- average price of books published by each publisher
select distinct pubid, avg(retail) from books 
join publisher using(pubid)
group by pubid;

-- how many books has each author written
select authorid, count(isbn) from author
join bookauthor using(authorid)
join books using(isbn)
group by authorid;

--What is the total amount of money each customer 
--has paid throughout all of their orders?
select customer#, sum(quantity*paideach) from orderitems
join orders using(order#) 
join customers using(customer#)
group by customer#
order by customer#;
