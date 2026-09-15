-- Уроки 11-12. Вторичный ключ и ограничители.
-- Скрипт выполняет все пункты задания в отдельной базе данных.

CREATE DATABASE Homework11_12;
GO
USE Homework11_12;
GO

CREATE SCHEMA Persons;
GO
CREATE SCHEMA Products;
GO

CREATE TABLE Persons.Person1 (
    Id INT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Age TINYINT NULL,
    Email NVARCHAR(100) NULL
);

CREATE TABLE Persons.Person2 (
    Id INT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20) NULL,
    BirthDate DATE NULL
);

ALTER TABLE Persons.Person1 DROP COLUMN Id;
ALTER TABLE Persons.Person1 ADD Id INT IDENTITY(1, 1) NOT NULL;
ALTER TABLE Persons.Person1 ADD CONSTRAINT PK_Homework11_Person1 PRIMARY KEY (Id);

ALTER TABLE Persons.Person2 DROP COLUMN Id;
ALTER TABLE Persons.Person2 ADD Id INT IDENTITY(1, 1) NOT NULL;
ALTER TABLE Persons.Person2 ADD CONSTRAINT PK_Homework11_Person2 PRIMARY KEY (Id);

CREATE TABLE Products.Product1 (
    Id INT IDENTITY(1, 1) CONSTRAINT PK_Homework11_Product1 PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Products.Product2 (
    Id INT IDENTITY(1, 1) CONSTRAINT PK_Homework11_Product2 PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Amount INT NOT NULL
);

INSERT INTO Products.Product1 (ProductName, Price)
VALUES (N'Ноутбук', 1000.00), (N'Монитор', 2000.00), (N'Телефон', 500.00);

INSERT INTO Products.Product2 (CategoryName, Amount)
VALUES (N'Электроника', 10), (N'Аксессуары', 30);

ALTER SCHEMA Persons TRANSFER Products.Product1;
ALTER SCHEMA Persons TRANSFER Products.Product2;
GO

SELECT * FROM Persons.Product1;
SELECT * FROM Persons.Product2;
