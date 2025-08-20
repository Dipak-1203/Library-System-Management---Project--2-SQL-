📚 Library Management System (PostgreSQL)
📖 Overview

A Library Management System built with PostgreSQL that handles book inventory, members, issue/return records, and staff operations.
This project demonstrates CRUD operations, multi-table joins, analytical queries, and stored procedures – similar to real-world company-level database use cases.

🛠 Tech Stack

Database: PostgreSQL

SQL Concepts:

CRUD Operations

Joins (INNER, LEFT JOIN)

Aggregate Functions

Subqueries & Analytics

Stored Procedures (PL/pgSQL)

🗂 Database Schema

Tables Used:

books – Book details (ISBN, Title, Author, Publisher, Status)

members – Library members with addresses and IDs

issued_status – Records of issued books

return_status – Records of returned books

🔑 Features

✔ Manage Books (Add, Update, Delete, Track Availability)
✔ Manage Members (Details, Address Updates)
✔ Record Book Issues & Returns
✔ Overdue Tracking (auto-calculate days overdue)
✔ Reports (Top issued books, Monthly usage)
✔ Stored Procedures for automated workflows

⚡ Example Queries
1️⃣ CRUD Operations

-- Q1)Create a New Book Record "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', '3.8. Lippincott & co.')"

INSERT INTO books (isbn , book_title , category , rental_price , status , author , publisher) 
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & co.');


-- Q2 Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';


--Q3): Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';


--Q13)Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period).
--Display the member's_id, member's name, book title, issue date, and days overdue.



2️⃣ Multi-Join Query – Identify Overdue Books
SELECT 
     ist.issued_member_id,
     mb.member_name,
     bk.book_title,
     ist.issued_date,
     CURRENT_DATE - ist.issued_date AS over_due_days
FROM issued_status AS ist 
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
JOIN members AS mb ON ist.issued_member_id = mb.member_id	
LEFT JOIN return_status AS rst ON rst.issued_id = ist.issued_id
WHERE rst.return_date IS NULL
  AND (CURRENT_DATE - ist.issued_date) > 30 
ORDER BY 1;




--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned 
--(based on entries in the return_status table).


3️⃣ Stored Procedure – Automating Book Returns
CREATE OR REPLACE PROCEDURE add_return_records(
   p_return_id VARCHAR(5), 
   p_issued_id VARCHAR(5), 
   p_book_quality VARCHAR(30)
) LANGUAGE plpgsql
AS $$
DECLARE 
   v_isbn VARCHAR(20);
   v_book_name VARCHAR(80);
BEGIN 
   -- Insert new return record
   INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
   VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
       
   -- Fetch book info
   SELECT issued_book_isbn, issued_book_name
   INTO v_isbn, v_book_name
   FROM issued_status
   WHERE issued_id = p_issued_id;

   -- Update availability
   UPDATE books 
   SET status = 'yes'
   WHERE isbn = v_isbn;

   RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;


Test Call:

CALL add_return_records('RS126','IS135','GOOD');

📊 Example Reports

**Top 5 Most Issued Books

SELECT b.book_title, COUNT(*) AS issue_count
FROM issue_records i
JOIN books b ON i.book_id = b.book_id
GROUP BY b.book_title
ORDER BY issue_count DESC
LIMIT 5;


Monthly Books Issued Report

SELECT TO_CHAR(issue_date, 'YYYY-MM') AS month, COUNT(*) AS total_issued
FROM issue_records
GROUP BY TO_CHAR(issue_date, 'YYYY-MM')
ORDER BY month;

🚀 How to Run

Install PostgreSQL
.

Create a new database:

CREATE DATABASE library_db;


Import schema & tables (books, members, issued_status, return_status).

Run example queries & stored procedures from the SQL scripts.

📌 Key Learning

This project demonstrates end-to-end database management with PostgreSQL – covering CRUD operations, business queries, joins, and stored procedures, making it highly relevant for Data Analyst & Backend Developer roles.
