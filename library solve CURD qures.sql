SELECT * FROM issued_status;
select * from books;
SELECT * FROM employees;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM return_status;


--- PROJECT TASKS

-- CURD OPRATION

-- Q1)Create a New Book Record "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', '3.8. Lippincott & co.')"

INSERT INTO books (isbn , book_title , category , rental_price , status , author , publisher) 
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & co.');
select * from books;


-- Q2 Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
select * from members;


--Q3): Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;


--Q4): Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Q5): List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select 
     issued_emp_id,
	 count(issued_id) as total_book_issued
from issued_status
group by (issued_emp_id)
having count (issued_id) > 1

-- Q6): CTAS 
-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_count 


create table books_sales_count
as
select 
     b.isbn,
	 b.book_title,
	 count(ist.issued_id) as book_count
from  books as b
join 
issued_status as ist 
on ist.issued_book_isbn = b.isbn --- cocatination between two table 
group by 1,2

select * from books_sales_count;	


-- Q7). Retrieve All Books in a Specific Category:

select * from books
where category = 'History';

-- Q8): Find Total Rental Income by Category:



select
     b.category,
	 sum(b.rental_price),	
	 count(*)
from books as b
join 
issued_status as ist 
on ist.issued_book_isbn = b.isbn --- cocatination between two table 
group by 1  ;

-- Q9) List Members Who Registered in the Last 180 Days:

select * from members 
where reg_date >= CURRENT_DATE - INTERVAL '180 DAYS' ;

-- Q10) List Employees with Their Branch Manager's Name and their branch details:
--- thats my logic 
SELECT *
FROM branch as b
join 
employees as emp
on b.ranch_id = emp.branch_id ;
--- that actual logic
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.ranch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
 

--Q11) . Create a Table of Books with Rental Price Above a Certain Threshold 7USD; 

CREATE TABLE expensive_books as
SELECT * FROM books
WHERE rental_price > 7

drop table  if  exists expensive_books;
SELECT * FROM expensive_books

-- Q12: Retrieve the List of Books Not Yet Returned
	

SELECT 
   DISTINCT ist.issued_book_name
FROM issued_status as ist
left join 
return_status as rs
on ist.issued_id = rs.issued_id 
where rs.return_id  is null;







--- ADVANCED PROBLEM -------------------------------------------------------------------



SELECT * FROM issued_status;
select * from books;
SELECT * FROM employees;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM return_status;



--Q13)Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period).
--Display the member's_id, member's name, book title, issue date, and days overdue.


-- we need all this tables 
SELECT * FROM books;
SELECT * FROM return_status;
SELECT * FROM members;
SELECT * FROM issued_status;

-- multiple joins here
-- issued_status  == books == members == return_status

SELECT 
     ist.issued_member_id,
	 mb.member_name,
	 bk.book_title,
	 ist.issued_date,
	-- rst.return_date,
	 CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist 
JOIN
books as bk
ON ist.issued_book_isbn = bk.isbn
JOIN 
members as mb
on ist.issued_member_id = mb.member_id	
LEFT JOIN
return_status as rst
on rst.issued_id = ist.issued_id
WHERE rst.return_date is null
    AND 
	(CURRENT_DATE - ist.issued_date) > 30 
ORDER BY 1



--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned 
--(based on entries in the return_status table).



SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2'

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2'

UPDATE books 
SET status = 'No'
WHERE isbn = '978-0-451-52994-2'

SELECT * FROM return_status
WHERE issued_id = 'IS130'


INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
VALUES 
('RS125','IS130',CURRENT_DATE,'Good');
SELECT * FROM return_status
WHERE issued_id = 'IS130'

UPDATE books 
SET status = 'YES'
WHERE isbn = '978-0-451-52994-2'


-- STORE PROCEDURES


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(5), p_issued_id VARCHAR(5), p_book_quality VARCHAR(30))
   LANGUAGE plpgsql
   AS $$
   DECLARE 
         v_isbn      VARCHAR(20);
		 V_book_name VARCHAR(80);
		  
   BEGIN 

           -- all your logic and code
           -- inserting into returns based on users input
           INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
           VALUES
           (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
       
           SELECT 
              issued_book_isbn,
              issued_book_name
           INTO
              v_isbn,
              v_book_name
           FROM issued_status
           WHERE issued_id = p_issued_id;

		   
	       UPDATE books 
           SET status = 'yes'
           WHERE isbn = v_isbn;

		   RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
   END ; 
  $$
call add_return_records()


-- TESTING FUNCATION =  add_return_records()

CALL add_return_records('RS126','IS135','GOOD');


SELECT * FROM books
where isbn = '978-0-307-58837-1'

SELECT * FROM issued_status 
WHERE issued_book_isbn = '978-0-307-58837-1'

SELECT * FROM return_status 
WHERE issued_id = 'IS135'



-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, 
-- the number of books returned,
-- and the total revenue generated from book rentals.

SELECT * FROM branch 
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status
SELECT * FROM books


CREATE TABLE brench_detail 
AS
SELECT 
   br.ranch_id,
   COUNT(ist.issued_book_name) as issued_books,
   COUNT(rst.return_id) as return_books,
   SUM(bk.rental_price) as total_book_revenue
FROM 
branch as br
JOIN
employees as emp 
on br.ranch_id = emp.branch_id
JOIN 
issued_status as ist
on emp.emp_id = ist.issued_emp_id
LEFT JOIN
return_status as rst 
on ist.issued_id = rst.issued_id
JOIN
books as bk 
ON ist.issued_book_isbn = bk.isbn 
GROUP BY 1;


SELECT * FROM brench_detail;


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table 
-- active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members
AS
SELECT * from members
WHERE member_id in(SELECT 
					      DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date >= CURRENT_DATE - INTERVAL '2 MONTH'
					)


SELECT * FROM active_members;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, 
-- number of books processed, 
-- and their branch.

SELECT 
    emp.emp_name,
	br.*,
	COUNT(ist.issued_book_name) as Totol_book_issued
FROM employees as emp 
JOIN 
issued_status as ist
on emp.emp_id = ist.issued_emp_id
JOIN  
books as bk
on bk.isbn = ist.issued_book_isbn
JOIN 
branch as br
on emp.branch_id= br.ranch_id 
group by 1 , 2



-- Task 18: Identify Members Issuing High-Risk Books
-- with the status "damaged" in the books table.
-- Display the member name,
-- book title,
-- and the number of times they've issued damaged books.


SELECT  
     mb.member_name,
	  bk.book_title		
FROM issued_status as ist 
LEFT JOIN  
return_status as rst
ON ist.issued_id = rst.issued_id
JOIN members as mb 
ON mb.member_id = ist.issued_member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
JOIN employees as emp 
ON emp.emp_id = ist.issued_emp_id
JOIN branch as br 
ON br.ranch_id = emp.branch_id
where rst.book_quality = 'Damaged'
GROUP BY 1 ,2 


