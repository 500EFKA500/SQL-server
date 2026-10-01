-- Уроки 15-16. Сравнение поиска до и после кластерного индекса.
CREATE DATABASE Homework15_16_ClusteredIndexes;
GO
USE Homework15_16_ClusteredIndexes;
GO

CREATE TABLE dbo.SalesLog (
    LogId INT IDENTITY(1, 1) NOT NULL,
    ClientCode INT NOT NULL,
    ProductCode INT NOT NULL,
    Quantity SMALLINT NOT NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SalesLog_CreatedAt DEFAULT SYSDATETIME()
);
GO

-- Рекурсивные CTE формируют 1 000 000 строк без ручного ввода.
;WITH N AS (
    SELECT TOP (1000000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Number
    FROM sys.all_objects AS a CROSS JOIN sys.all_objects AS b
)
INSERT INTO dbo.SalesLog (ClientCode, ProductCode, Quantity, CreatedAt)
SELECT
    (Number * 7919) % 1000000 + 1,
    Number % 5000 + 1,
    Number % 20 + 1,
    DATEADD(MINUTE, Number, '2026-01-01')
FROM N;
GO

SET STATISTICS IO ON;
GO
-- В SSMS включить Actual Execution Plan, выполнить запрос и записать его показатели.
SELECT LogId, ClientCode, ProductCode, Quantity, CreatedAt
FROM dbo.SalesLog
WHERE ClientCode = 777777;
GO
-- До индекса: Table Scan; фактическое число логических чтений зависит от версии SQL Server.

CREATE CLUSTERED INDEX CIX_SalesLog_ClientCode
    ON dbo.SalesLog (ClientCode);
GO

SELECT LogId, ClientCode, ProductCode, Quantity, CreatedAt
FROM dbo.SalesLog
WHERE ClientCode = 777777;
GO
-- После индекса: Clustered Index Seek; сравнить Logical reads и число уровней дерева в SSMS.
SET STATISTICS IO OFF;
GO
