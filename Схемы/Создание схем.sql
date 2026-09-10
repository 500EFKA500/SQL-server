USE DB5
GO

CREATE SCHEMA Persons;
GO
CREATE SCHEMA Products;
GO

CREATE TABLE Persons.Person1(
	id INT NULL,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	age TINYINT,
)
GO
CREATE TABLE Persons.Person2(
	id INT NULL,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Phone NVARCHAR(20),
)
GO


ALTER TABLE Persons.Person1
DROP COLUMN id
ALTER TABLE Persons.Person1
ADD id INT IDENTITY(1,1) NOT NULL
ALTER TABLE Persons.Person1
ADD CONSTRAINT PK_Person1 PRIMARY KEY (id)

ALTER TABLE Persons.Person2
DROP COLUMN id
ALTER TABLE Persons.Person2
ADD id INT IDENTITY(1,1) NOT NULL
ALTER TABLE Persons.Person2
ADD CONSTRAINT PK_Person1 PRIMARY KEY (id)


CREATE TABLE Products.Product1(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	ProductName NVARCHAR(100),
	Price REAL,
)
GO
CREATE TABLE Products.Product2(
	id INT IDENTITY(1, 1) PRIMARY KEY,
	CategoryName NVARCHAR(100),
	Amount INT
)
GO


INSERT INTO Products.Product1 (ProductName, Price)
VALUES
('Laptop', 1000),
('Deckstop', 2000),
('Phone', 500)
INSERT INTO Products.Product2 (CategoryName, Amount)
VALUES
('Electronics', 10),
('Electronics', 20),
('Accses', 30)
GO

ALTER SCHEMA Persons TRANSFER Products.Product1
ALTER SCHEMA Persons TRANSFER Products.Product2
GO

SELECT * FROM Products.Product1
SELECT * FROM Products.Product2

GO