-- Уроки 13-14. Создание кластера таблиц: интернет-магазин Shop.
-- Пять таблиц, первичные и внешние ключи, а также тестовые данные.

CREATE DATABASE Homework13_14_Shop;
GO
USE Homework13_14_Shop;
GO

CREATE SCHEMA Shop;
GO

CREATE TABLE Shop.Categories (
    CategoryId INT IDENTITY(1, 1) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Shop_Categories PRIMARY KEY (CategoryId),
    CONSTRAINT UQ_Shop_Categories_CategoryName UNIQUE (CategoryName)
);

CREATE TABLE Shop.Customers (
    CustomerId INT IDENTITY(1, 1) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(120) NOT NULL,
    Phone NVARCHAR(30) NULL,
    CONSTRAINT PK_Shop_Customers PRIMARY KEY (CustomerId),
    CONSTRAINT UQ_Shop_Customers_Email UNIQUE (Email)
);

CREATE TABLE Shop.Products (
    ProductId INT IDENTITY(1, 1) NOT NULL,
    CategoryId INT NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    CONSTRAINT PK_Shop_Products PRIMARY KEY (ProductId),
    CONSTRAINT FK_Shop_Products_Categories
        FOREIGN KEY (CategoryId) REFERENCES Shop.Categories (CategoryId),
    CONSTRAINT CK_Shop_Products_UnitPrice CHECK (UnitPrice > 0),
    CONSTRAINT CK_Shop_Products_StockQuantity CHECK (StockQuantity >= 0)
);

CREATE TABLE Shop.Orders (
    OrderId INT IDENTITY(1, 1) NOT NULL,
    CustomerId INT NOT NULL,
    OrderDate DATETIME2 NOT NULL CONSTRAINT DF_Shop_Orders_OrderDate DEFAULT SYSDATETIME(),
    OrderStatus NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Shop_Orders PRIMARY KEY (OrderId),
    CONSTRAINT FK_Shop_Orders_Customers
        FOREIGN KEY (CustomerId) REFERENCES Shop.Customers (CustomerId),
    CONSTRAINT CK_Shop_Orders_Status CHECK (OrderStatus IN (N'Новый', N'Оплачен', N'Отправлен', N'Завершён'))
);

CREATE TABLE Shop.OrderItems (
    OrderItemId INT IDENTITY(1, 1) NOT NULL,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_Shop_OrderItems PRIMARY KEY (OrderItemId),
    CONSTRAINT FK_Shop_OrderItems_Orders
        FOREIGN KEY (OrderId) REFERENCES Shop.Orders (OrderId),
    CONSTRAINT FK_Shop_OrderItems_Products
        FOREIGN KEY (ProductId) REFERENCES Shop.Products (ProductId),
    CONSTRAINT UQ_Shop_OrderItems_Order_Product UNIQUE (OrderId, ProductId),
    CONSTRAINT CK_Shop_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_Shop_OrderItems_UnitPrice CHECK (UnitPrice > 0)
);
GO

INSERT INTO Shop.Categories (CategoryName)
VALUES (N'Ноутбуки'), (N'Периферия'), (N'Аксессуары');

INSERT INTO Shop.Customers (FullName, Email, Phone)
VALUES
    (N'Иван Петров', N'ivan.petrov@example.com', N'+7 900 111-22-33'),
    (N'Анна Смирнова', N'anna.smirnova@example.com', N'+7 900 444-55-66'),
    (N'Максим Орлов', N'maxim.orlov@example.com', NULL);

INSERT INTO Shop.Products (CategoryId, ProductName, UnitPrice, StockQuantity)
VALUES
    (1, N'Ноутбук 15', 74990.00, 8),
    (1, N'Ноутбук 14', 89990.00, 5),
    (2, N'Беспроводная мышь', 2490.00, 35),
    (2, N'Механическая клавиатура', 6990.00, 14),
    (3, N'Рюкзак для ноутбука', 3290.00, 20);

INSERT INTO Shop.Orders (CustomerId, OrderDate, OrderStatus)
VALUES
    (1, '2026-09-16T10:30:00', N'Оплачен'),
    (2, '2026-09-16T15:10:00', N'Новый'),
    (1, '2026-09-17T09:00:00', N'Отправлен');

INSERT INTO Shop.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
VALUES
    (1, 1, 1, 74990.00),
    (1, 3, 1, 2490.00),
    (2, 4, 1, 6990.00),
    (2, 5, 2, 3290.00),
    (3, 2, 1, 89990.00);
GO

-- Проверка связей и добавленных строк.
SELECT
    o.OrderId,
    c.FullName AS Customer,
    o.OrderDate,
    o.OrderStatus,
    p.ProductName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Quantity * oi.UnitPrice AS LineTotal
FROM Shop.Orders AS o
INNER JOIN Shop.Customers AS c ON c.CustomerId = o.CustomerId
INNER JOIN Shop.OrderItems AS oi ON oi.OrderId = o.OrderId
INNER JOIN Shop.Products AS p ON p.ProductId = oi.ProductId
ORDER BY o.OrderId, oi.OrderItemId;
GO
