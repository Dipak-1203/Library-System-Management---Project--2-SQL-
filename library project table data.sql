CREATE TABLE books 
                   (
				    isbn VARCHAR(20) PRIMARY KEY,
				    book_title	VARCHAR(25),
					category VARCHAR(10),	
					rental_price FLOAT,	
					status VARCHAR(20),	
					author VARCHAR(20),	
					publisher VARCHAR(25) 
				   )

ALTER TABLE BOOKS
ALTER COLUMN book_title type varchar(60);
ALTER TABLE BOOKS
ALTER COLUMN category type varchar(30);
ALTER TABLE BOOKS
ALTER COLUMN author type varchar(30);

-- CREATE TABLE branch

CREATE TABLE branch
                   (
				    ranch_id VARCHAR(10) PRIMARY KEY,	
				    manager_id	VARCHAR(10),
					branch_address VARCHAR(15),	
					contact_no VARCHAR(20)
				   )

-- CREATE TABLE EMPLOYEES

drop table employees;
CREATE TABLE employees 
                    ( 
					  emp_id VARCHAR(5) PRIMARY KEY ,
					  emp_name VARCHAR(20),
					  position VARCHAR(10),
					  salary FLOAT,
					  branch_id VARCHAR(5)
					)


-- CREATE TABLE MEMBERS 

CREATE TABLE members 
                    ( 
					  member_id	VARCHAR(5) PRIMARY KEY,
					  member_name VARCHAR(15),
					  member_address VARCHAR(15),	
					  reg_date DATE
					)


-- CREATE TABLE ISSUDE_STATUS

CREATE TABLE issued_status
                         ( 
                          issued_id	VARCHAR(5) PRIMARY KEY,
						  issued_member_id VARCHAR(4),
						  issued_book_name VARCHAR(55),	
						  issued_date DATE,	
						  issued_book_isbn VARCHAR(20),	
						  issued_emp_id VARCHAR(4)
						 )

--CREATE TABLE RETURN_STSTUS

CREATE TABLE return_status
                          (
						    return_id VARCHAR(5) PRIMARY KEY ,
							issued_id VARCHAR(5),	
							return_book_name VARCHAR(4),
							return_date	DATE,
							return_book_isbn VARCHAR(4)
						  )

ALTER TABLE return_status
ALTER COLUMN return_book_name type varchar(20);
ALTER TABLE return_status
ALTER COLUMN return_book_isbn type varchar(30);
						  

-- employees → branch
ALTER TABLE employees
ADD CONSTRAINT fk_emp_branch
FOREIGN KEY (branch_id)
REFERENCES branch(ranch_id);

-- issued_status → members
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

-- issued_status → books
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

-- issued_status → employees
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- return_status → books
ALTER TABLE return_status
ADD CONSTRAINT fk_return_book
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);


DELETE FROM return_status
WHERE return_book_isbn IS NULL
   OR return_book_isbn NOT IN (SELECT isbn FROM books);

UPDATE return_status
SET return_book_isbn = 'VALID_ISBN'
WHERE return_book_isbn IS NULL
   OR return_book_isbn NOT IN (SELECT isbn FROM books);			



-- Q1)  
