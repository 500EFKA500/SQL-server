/*
    Уроки 5–6. Операторы, условия и встроенные функции SQL Server.
*/

USE HomeworkLessons3_4;
GO

CREATE TABLE dbo.Orders
(
    OrderId INT IDENTITY(1, 1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CONSTRAINT CK_Orders_Amount CHECK (Amount >= 0),
    DiscountPercent INT NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSDATETIME()
);

INSERT INTO dbo.Orders (CustomerName, Amount, DiscountPercent, CreatedAt)
VALUES
    (N'Анна', 1500.00, 10, '2026-09-01T10:15:00'),
    (N'Борис', 850.00, NULL, '2026-09-02T12:30:00'),
    (N'Виктория', 2200.00, 15, '2026-09-03T09:45:00');

-- Арифметические и логические операторы, CASE и ISNULL.
SELECT
    OrderId,
    UPPER(CustomerName) AS CustomerNameUpper,
    Amount,
    ISNULL(DiscountPercent, 0) AS DiscountPercent,
    Amount * (1 - ISNULL(DiscountPercent, 0) / 100.0) AS AmountAfterDiscount,
    CASE
        WHEN Amount >= 2000 THEN N'Крупный заказ'
        WHEN Amount >= 1000 THEN N'Средний заказ'
        ELSE N'Небольшой заказ'
    END AS OrderCategory,
    CONVERT(DATE, CreatedAt) AS OrderDate,
    DATEPART(WEEKDAY, CreatedAt) AS WeekDayNumber
FROM dbo.Orders
WHERE Amount >= 1000 OR DiscountPercent IS NOT NULL;

-- Агрегатные функции.
SELECT
    COUNT(*) AS OrdersCount,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AverageAmount,
    MIN(Amount) AS MinAmount,
    MAX(Amount) AS MaxAmount
FROM dbo.Orders;
