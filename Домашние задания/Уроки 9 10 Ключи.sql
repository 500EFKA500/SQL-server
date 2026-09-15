-- Уроки 9-10. Первичный и внешний ключи.
-- Скрипт демонстрирует NULL, PRIMARY KEY, FOREIGN KEY и INSERT с копированием данных.

CREATE SCHEMA Homework9;
GO

CREATE TABLE Homework9.Categories (
    CategoryId INT IDENTITY(1, 1) CONSTRAINT PK_Homework9_Categories PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);

CREATE TABLE Homework9.Products (
    ProductId INT IDENTITY(1, 1) CONSTRAINT PK_Homework9_Products PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NULL,
    CategoryId INT NULL,
    CONSTRAINT FK_Homework9_Products_Categories
        FOREIGN KEY (CategoryId) REFERENCES Homework9.Categories(CategoryId)
);

CREATE TABLE Homework9.ProductsArchive (
    ProductId INT NULL,
    ProductName NVARCHAR(100) NULL,
    Price DECIMAL(10, 2) NULL,
    CategoryId INT NULL
);

INSERT INTO Homework9.Categories (CategoryName)
VALUES (N'Компьютеры'), (N'Периферия');

INSERT INTO Homework9.Products (ProductName, Price, CategoryId)
VALUES
    (N'Ноутбук', 85000.00, 1),
    (N'Монитор', 25000.00, 2),
    (N'Кабель', NULL, 2);

INSERT INTO Homework9.ProductsArchive (ProductId, ProductName, Price, CategoryId)
SELECT ProductId, ProductName, Price, CategoryId
FROM Homework9.Products;

SELECT * FROM Homework9.Products;
SELECT * FROM Homework9.ProductsArchive;
