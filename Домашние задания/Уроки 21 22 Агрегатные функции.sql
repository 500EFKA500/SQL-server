-- Уроки 21-22. Агрегатные функции SQL Server.
CREATE DATABASE Homework21_22_Aggregates;
GO
USE Homework21_22_Aggregates;
GO
CREATE TABLE dbo.Sales
(
    SaleId INT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(50) NOT NULL,
    Seller NVARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount > 0),
    SoldAt DATE NOT NULL
);
GO
INSERT INTO dbo.Sales (Category, Seller, Amount, SoldAt) VALUES
(N'Ноутбуки', N'Анна', 85000, '2026-09-01'),
(N'Ноутбуки', N'Иван', 92000, '2026-09-02'),
(N'Аксессуары', N'Анна', 3500, '2026-09-02'),
(N'Аксессуары', N'Олег', 4200, '2026-09-03'),
(N'Мониторы', N'Иван', 28000, '2026-09-04'),
(N'Мониторы', N'Олег', 31500, '2026-09-05');
GO

-- COUNT, SUM, AVG, MIN и MAX по всем продажам.
SELECT COUNT(*) AS SalesCount, SUM(Amount) AS Revenue,
       AVG(Amount) AS AverageSale, MIN(Amount) AS MinimumSale,
       MAX(Amount) AS MaximumSale
FROM dbo.Sales;
GO
-- Группировка и фильтрация групп условием HAVING.
SELECT Category, COUNT(*) AS SalesCount, SUM(Amount) AS Revenue,
       AVG(Amount) AS AverageSale
FROM dbo.Sales
GROUP BY Category
HAVING SUM(Amount) >= 30000
ORDER BY Revenue DESC;
GO
SELECT Seller, COUNT(*) AS SalesCount, SUM(Amount) AS Revenue
FROM dbo.Sales
GROUP BY Seller
ORDER BY Revenue DESC;
GO
