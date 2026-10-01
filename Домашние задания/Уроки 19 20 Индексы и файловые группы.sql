-- Уроки 19-20. Индексы и файловые группы.
-- В SSMS при первом запуске замените пути к .ndf-файлам на существующую папку SQL Server.
CREATE DATABASE Homework19_20_Indexes;
GO
ALTER DATABASE Homework19_20_Indexes ADD FILEGROUP FG_Slow;
ALTER DATABASE Homework19_20_Indexes ADD FILEGROUP FG_Fast;
GO
ALTER DATABASE Homework19_20_Indexes ADD FILE
(
    NAME = Homework19_20_Slow,
    FILENAME = 'C:\SQLData\Homework19_20_Slow.ndf',
    SIZE = 8MB,
    FILEGROWTH = 8MB
) TO FILEGROUP FG_Slow;
ALTER DATABASE Homework19_20_Indexes ADD FILE
(
    NAME = Homework19_20_Fast,
    FILENAME = 'C:\SQLData\Homework19_20_Fast.ndf',
    SIZE = 8MB,
    FILEGROWTH = 8MB
) TO FILEGROUP FG_Fast;
GO
USE Homework19_20_Indexes;
GO

CREATE TABLE dbo.ArchiveOrders
(
    OrderId INT IDENTITY(1,1) NOT NULL,
    CustomerId INT NOT NULL,
    StatusCode VARCHAR(20) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    CreatedAt DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
) ON FG_Slow;
GO
CREATE TABLE dbo.ActiveOrders
(
    OrderId INT IDENTITY(1,1) NOT NULL,
    CustomerId INT NOT NULL,
    StatusCode VARCHAR(20) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    CreatedAt DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
) ON FG_Fast;
GO

INSERT INTO dbo.ActiveOrders (CustomerId, StatusCode, Amount, CreatedAt) VALUES
(1, 'New', 199.00, '2026-09-01'), (1, 'Paid', 399.00, '2026-09-02'),
(2, 'New', 149.00, '2026-09-03'), (3, 'Cancelled', 79.00, '2026-09-04'),
(4, 'Paid', 850.00, '2026-09-05');
GO

-- Кластерный индекс задаёт физический порядок основной таблицы.
CREATE CLUSTERED INDEX CIX_ActiveOrders_OrderId ON dbo.ActiveOrders(OrderId);
-- Некластерный индекс ускоряет поиск заказов конкретного клиента.
CREATE NONCLUSTERED INDEX IX_ActiveOrders_CustomerId ON dbo.ActiveOrders(CustomerId)
INCLUDE (StatusCode, Amount, CreatedAt);
-- Фильтрованный индекс хранит только активные статусы и занимает меньше места.
CREATE NONCLUSTERED INDEX IX_ActiveOrders_Open
ON dbo.ActiveOrders(CustomerId, CreatedAt)
INCLUDE (Amount)
WHERE StatusCode IN ('New', 'Paid');
GO

-- Некластерный колоночный индекс подходит для агрегатных аналитических запросов.
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_ActiveOrders_Analytics
ON dbo.ActiveOrders(CustomerId, StatusCode, Amount, CreatedAt);
GO

SELECT CustomerId, COUNT(*) AS OrderCount, SUM(Amount) AS TotalAmount
FROM dbo.ActiveOrders
WHERE StatusCode IN ('New', 'Paid')
GROUP BY CustomerId;
GO
