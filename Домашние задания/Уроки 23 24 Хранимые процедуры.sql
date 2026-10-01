-- Уроки 23-24. Хранимые процедуры в MS SQL Server.
CREATE DATABASE Homework23_24_StoredProcedures;
GO
USE Homework23_24_StoredProcedures;
GO
CREATE TABLE dbo.Products
(
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Price DECIMAL(12,2) NOT NULL CHECK (Price > 0),
    Stock INT NOT NULL CONSTRAINT DF_Products_Stock DEFAULT 0 CHECK (Stock >= 0)
);
GO

CREATE OR ALTER PROCEDURE dbo.AddProduct
    @ProductName NVARCHAR(100), @Category NVARCHAR(50),
    @Price DECIMAL(12,2), @Stock INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Products (ProductName, Category, Price, Stock)
    VALUES (@ProductName, @Category, @Price, @Stock);
    SELECT SCOPE_IDENTITY() AS NewProductId;
END;
GO
CREATE OR ALTER PROCEDURE dbo.GetProductsByCategory
    @Category NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductId, ProductName, Price, Stock
    FROM dbo.Products WHERE Category = @Category ORDER BY ProductName;
END;
GO
CREATE OR ALTER PROCEDURE dbo.ChangeProductPrice
    @ProductId INT, @NewPrice DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF @NewPrice <= 0 THROW 50001, 'Цена должна быть больше нуля.', 1;
    UPDATE dbo.Products SET Price = @NewPrice WHERE ProductId = @ProductId;
    IF @@ROWCOUNT = 0 THROW 50002, 'Товар не найден.', 1;
END;
GO

EXEC dbo.AddProduct N'Ноутбук', N'Компьютеры', 89990, 4;
EXEC dbo.AddProduct N'Мышь', N'Аксессуары', 1990, 20;
EXEC dbo.AddProduct N'Клавиатура', N'Аксессуары', 4990, 12;
EXEC dbo.AddProduct N'Монитор', N'Компьютеры', 27990, 8;
EXEC dbo.AddProduct N'Веб-камера', N'Аксессуары', 3590, 15;
GO
EXEC dbo.GetProductsByCategory N'Аксессуары';
EXEC dbo.ChangeProductPrice @ProductId = 2, @NewPrice = 2190;
GO
