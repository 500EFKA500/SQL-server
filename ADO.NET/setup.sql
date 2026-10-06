-- Run once in SSMS against a local SQL Server instance.
IF DB_ID(N'AcademyAdo') IS NULL CREATE DATABASE AcademyAdo;
GO
USE AcademyAdo;
GO
IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        Id INT IDENTITY(1,1) CONSTRAINT PK_AcademyAdo_Products PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Price DECIMAL(12,2) NOT NULL CONSTRAINT CK_AcademyAdo_Price CHECK (Price > 0)
    );
    INSERT INTO dbo.Products(Name, Price) VALUES
    (N'Laptop', 85000), (N'Mouse', 1500), (N'Keyboard', 3500),
    (N'Monitor', 25000), (N'Headphones', 6000);
END;
GO
SELECT Id, Name, Price FROM dbo.Products;
