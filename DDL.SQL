--Create a table named "employees" with columns: id (integer), name (varchar), and salary (decimal).

CREATE TABLE employees2002 (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10, 2)
);

--Add a column named "age" to the "employees" table with the data type integer.

ALTER TABLE employees
ADD age INT;

---- Create the "employees2022" table without the primary key 

CREATE TABLE employees2003 (
    id INT not null,
    name VARCHAR(100),
    salary DECIMAL(10, 2),
    age INT
);

--Create a primary key constraint on the "id" column of the "employees" table.

ALTER TABLE employees2003
ADD CONSTRAINT PK_employees2003 PRIMARY KEY (id);

---- Add the "dept_id" column to the "employees2003" table

ALTER TABLE employees2003
ADD dept_id INT;

--Remove the "salary" column from the "employees2003" table.

ALTER TABLE employees2003
DROP COLUMN salary;

--Rename the "name" column in the "employees2003" table to "full_name".

EXEC sp_rename 'employees2003.name', 'full_name', 'COLUMN';

-- Add the "salary" column to the "employees2003" table
ALTER TABLE employees2003
ADD salary DECIMAL(10, 2);

--Create a new table named "departments" with columns: dept_id (integer) and dept_name (varchar).

CREATE TABLE departments (
    dept_id INT,
    dept_name VARCHAR(100)
);

---- Update the "dept_id" column from allowing NULL to NOT NULL
ALTER TABLE departments
ALTER COLUMN dept_id INT NOT NULL;

---add a primary key
ALTER TABLE departments
ADD CONSTRAINT PK_departments PRIMARY KEY (dept_id);

--Add a foreign key constraint to link the "employees2003" table's "dept_id" column to the "dept_id" column in the "departments" table.

ALTER TABLE employees2003
ADD CONSTRAINT FK_employees2003_departments
FOREIGN KEY (dept_id) REFERENCES departments(dept_id);

--Create a unique constraint on the "full_name" column of the "employees2003" table.

ALTER TABLE employees2003
ADD CONSTRAINT UK_employees2003_full_name UNIQUE (full_name);

---Add a default value of 0 to the "age" column of the "employees2003" table.
---Note:-The ALTER COLUMN statement alone cannot be used to modify the default value of an existing column

-- Drop the existing "age" column in the "employees2003" table
ALTER TABLE employees2003
DROP COLUMN age;

-- Add the "age" column with a default value of 0 to the "employees2003" table
ALTER TABLE employees2003
ADD age INT NOT NULL DEFAULT 0;

---Create an index on the "salary" column of the "employees2003" table.

CREATE INDEX IX_employees2003_salary ON employees2003 (salary);

-- Create a check constraint on the "age" column in the "employees2003" table

ALTER TABLE employees2003
ADD CONSTRAINT CHK_employees2003_age CHECK (age >= 18);

-- Remove the primary key constraint from the "employees2003" table

ALTER TABLE employees2003
DROP CONSTRAINT PK_employees2003;

-- Drop the "departments" table

-- Drop the foreign key constraint in the child table
-- 1st Find the foreign key constraints referencing the "departments" table
SELECT OBJECT_NAME(f.parent_object_id) AS child_table,
       f.name AS constraint_name
FROM sys.foreign_keys f
INNER JOIN sys.tables t ON f.referenced_object_id = t.object_id
WHERE t.name = 'departments';

/*This query will return the names of the foreign key constraints in 
the child tables that reference the "departments" table. Once you have
the correct constraint names, 
you can drop them using the ALTER TABLE statement as shown earlier:*/

-- Drop the foreign key constraint in the child table
ALTER TABLE employees2003
DROP CONSTRAINT FK_employees2003_departments;

---Now we can drop departments table 

DROP TABLE departments;

-- Rename the "employees2003" table to "staff"
EXEC sp_rename 'employees2003', 'staff';

--Create a new schema named "sales" to hold tables related to the sales department.

CREATE SCHEMA sales;

--Move the "staff" table to the "sales" schema.
-- Move the "staff" table to the "sales" schema
/*To move the "staff" table from the default schema to the "sales" 
schema in SQL Server Management Studio 
(SSMS), you can use the following SQL code:*/

ALTER SCHEMA sales TRANSFER dbo.staff;

-- Modify the data type of the "salary" column to be a float
/*you cannot directly modify the data type of the "salary" column in the "staff" 
table because there are dependencies on that column, such as an index, which is preventing the alteration.
Before altering the data type of the "salary" column, you need to drop the dependent objects 
(e.g., indexes) and then re-create them after 
the data type change. Here's the correct sequence of steps:*/

--1st. Drop the index 'IX_employees2003_salary' on the "salary" column
DROP INDEX IX_employees2003_salary ON sales.staff;

--2nd -- Modify the data type of the "salary" column to FLOAT
ALTER TABLE sales.staff
ALTER COLUMN salary FLOAT;

-- 3rd Recreate the index 'IX_employees2003_salary' on the "salary" column
CREATE INDEX IX_employees2003_salary ON sales.staff (salary);

--Create a view named "high_salary_employees" that includes only employees with a salary greater than $50,000.

-- Create the view "high_salary_employees"
CREATE VIEW high_salary_employees AS
SELECT *
FROM sales.staff
WHERE salary > 50000;

--Once you create this view, you can query it as if it were a regular table to retrieve high-salary employees:

SELECT * FROM high_salary_employees;

--Grant SELECT permission on the "high_salary_employees" view to a user named "analyst".

GRANT SELECT ON high_salary_employees TO analyst;

--Revoke the SELECT permission on the "high_salary_employees" view from the user "analyst".

REVOKE SELECT ON high_salary_employees FROM analyst;