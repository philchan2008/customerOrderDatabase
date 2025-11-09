--Customers
DECLARE @i INT = 0
WHILE @i < 10
BEGIN
    INSERT INTO Customers (
        FirstName,
        LastName,
        PhoneNumber,
        EmailAddress,
        DateOfBirth
    )
    VALUES (
        -- FullName = FirstName + LastName
        LEFT(CONVERT(NVARCHAR(255), NEWID()), 5),
        LEFT(CONVERT(NVARCHAR(255), NEWID()), 6),
        '07700' + CAST(ABS(CHECKSUM(NEWID())) % 900000 AS NVARCHAR),
        LEFT(CONVERT(NVARCHAR(255), NEWID()), 8) + '@example.com',
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 12000, GETDATE()) -- Random DOB in past ~30 years
    )
    SET @i = @i + 1
END;
GO

DECLARE @i INT = 0
DECLARE @CustomerID BIGINT
WHILE @i < 10
BEGIN
	-- Random CustomerID
    SELECT TOP 1 @CustomerID = CustomerID
    FROM Customers c
    WHERE CustomerID % 2 = 0
	AND NOT EXISTS (SELECT * FROM CustomerAddresses x
		WHERE x.CustomerID = c.CustomerID)
    ORDER BY NEWID();
    INSERT INTO CustomerAddresses (
        AddressTypeID, 
		CustomerID,
		AddressLine,
		City,
		County,
		PostCode,
		EffectiveDate
    )
    VALUES (
        1, --Billing address
        @CustomerID,
        CAST(ABS(CHECKSUM(NEWID())) % 100 AS NVARCHAR) + ' Random Street',
        CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1, 'London', 'Manchester', 'Leeds', 'Bristol', 'Nottingham'),
        CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1, 'Greater London', 'Greater Manchester', 'Yorkshire', 'Birmingham', 'Nottinghamshire'),
        CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) +
			CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) +
			CAST(ABS(CHECKSUM(NEWID())) % 10 AS NVARCHAR) + ' ' +
			CAST(ABS(CHECKSUM(NEWID())) % 10 AS NVARCHAR) +
			CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) +
			CHAR(65 + ABS(CHECKSUM(NEWID())) % 26),
        '2020-01-01'
    )
    SET @i = @i + 1
END;
GO

--delete from Products;
--DBCC CHECKIDENT ('Products', RESEED, 0);

--Products
DECLARE @i INT = 0
WHILE @i < 10  -- Change this number to insert more rows
BEGIN
    INSERT INTO Products (
        ProductName,
        Description,
        Price,
        StockQuantity
    )
    VALUES (
        'Product_' + CAST(@i AS NVARCHAR),
        'Description for product ' + CAST(@i AS NVARCHAR),
        ROUND(RAND(CHECKSUM(NEWID())) * 500 + 10, 2),  -- Price between 10.00 and 510.00
        0 --ABS(CHECKSUM(NEWID())) % 1000  -- Stock between 0 and 999
    )
    SET @i = @i + 1
END;
GO
--select * from Products;

--delete OrderDetails
--delete Orders

--Orders
DECLARE @i INT = 0
DECLARE @CustomerID BIGINT
DECLARE @OrderDate DATE
WHILE @i < 10  -- Number of orders to generate
BEGIN
    -- Random CustomerID
    SELECT TOP 1 @CustomerID = CustomerID
    FROM Customers
    WHERE CustomerID % 2 = 0
    ORDER BY NEWID()
    -- Random OrderDate in last 90 days
    SET @OrderDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 90), GETDATE())
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, StatusID)
    VALUES (@CustomerID, @OrderDate, 0.00, 2)  -- TotalAmount will be updated later
    SET @i = @i + 1
END;

--select * from Orders;

--OrderDetails
DECLARE @OrderID BIGINT
DECLARE @ProductID BIGINT
DECLARE @ProductName NVARCHAR(255)
DECLARE @UnitPrice DECIMAL(18,2)
DECLARE @Quantity INT
DECLARE @TotalAmount DECIMAL(18,2)
-- Loop through each order
DECLARE OrderCursor CURSOR FOR
	SELECT OrderID FROM Orders
OPEN OrderCursor
FETCH NEXT FROM OrderCursor INTO @OrderID
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TotalAmount = 0
    DECLARE @j INT = 0
    WHILE @j < 3  -- 3 items per order
    BEGIN
        -- Random Product
        SELECT TOP 1
            @ProductID = ProductID,
            @ProductName = ProductName,
            @UnitPrice = Price
        FROM Products
        WHERE Price IS NOT NULL
        ORDER BY NEWID()
        SET @Quantity = ABS(CHECKSUM(NEWID()) % 5) + 1
        --SET @LineTotal = ROUND(@UnitPrice * @Quantity, 2)
        --SET @TotalAmount = @TotalAmount + @LineTotal
        INSERT INTO OrderDetails (OrderID, ProductID, ProductName, Quantity, UnitPrice)
        VALUES (@OrderID, @ProductID, @ProductName, @Quantity, @UnitPrice)
        SET @j = @j + 1
    END
    -- Update TotalAmount in Orders
    --UPDATE Orders SET TotalAmount = @TotalAmount WHERE OrderID = @OrderID
    FETCH NEXT FROM OrderCursor INTO @OrderID
END
CLOSE OrderCursor
DEALLOCATE OrderCursor
go

--select * from Orders

--delete CustomerAccountBalanceTransactions

INSERT INTO CustomerAccountBalanceTransactions (
    CustomerID,
	TransactionType,
    TransactionDate,
    TransactionAmount,
    Reference,
    Notes
)
SELECT
    C.CustomerID,
	1, --Credit
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()), -- random date within past year
    ABS(CAST((RAND(CHECKSUM(NEWID())) * 200 - 100) AS DECIMAL(18,2))), -- random amount between -100 and +100
    '<ref><refNo>' + CAST(CAST((RAND(CHECKSUM(NEWID())) * 10000) AS INT) as VARCHAR(10)) + '</refNo></ref>', -- or use '<ref>Sample</ref>' if you want XML
    CONCAT('Sample transaction for ', C.FullName)
FROM (
    SELECT TOP 5000 CustomerID, FullName
    FROM Customers c
	WHERE NOT EXISTS (select 1 from CustomerAccountBalanceTransactions x
		WHERE x.CustomerID = c.CustomerID)
    ORDER BY NEWID()
) C;
GO

/*
delete ProductStockQuantityUpdateLog
delete ProductTransactions

select * from ProductTransactions

select * from Products where ProductID = 6
*/

--delete ProductTransactions
INSERT INTO ProductTransactions (
    ProductID,
    TransactionDate,
    TransactionType,
    TransactionQuantity,
    UnitPrice,
    Reference,
    Notes
)
SELECT 
    OD.ProductID,
    O.OrderDate,
    2, -- Purchase
    ABS(OD.Quantity * 10),
    OD.UnitPrice,
    CAST('<OrderID>' + CAST(OD.OrderID AS NVARCHAR) + '</OrderID>' +
         '<OrderDetailID>' + CAST(OD.OrderDetailID AS NVARCHAR) + '</OrderDetailID>' +
         '<ProductName>' + OD.ProductName + '</ProductName>' AS XML),
    'Generated from OrderDetails'
FROM OrderDetails OD
INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE OD.ProductID IS NOT NULL;


INSERT INTO ProductTransactions (
    ProductID,
    TransactionDate,
    TransactionType,
    TransactionQuantity,
    UnitPrice,
    Reference,
    Notes
)
SELECT
    OD.ProductID,
    O.OrderDate,
    1, -- Sale
    ABS(OD.Quantity),
    OD.UnitPrice,
    CAST('<OrderID>' + CAST(OD.OrderID AS NVARCHAR) + '</OrderID>' +
         '<OrderDetailID>' + CAST(OD.OrderDetailID AS NVARCHAR) + '</OrderDetailID>' +
         '<ProductName>' + OD.ProductName + '</ProductName>' AS XML),
    'Generated from OrderDetails'
FROM OrderDetails OD
INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE OD.ProductID IS NOT NULL;
GO

/*
select * from OrderDetails;
select * from Orders;

select o.OrderID , count(*)
from Orders o
join OrderDetails od on o.OrderID = od.OrderID
group by o.OrderID

select o.CustomerID , count(*)
from Orders o
join OrderDetails od on o.OrderID = od.OrderID
group by o.CustomerID


with result1 (CustomerID, OrderDate, OrderID, ProductID, ProductName, TotalCostByOrder) as
(
	select
        c.CustomerID,
        o.OrderDate,
        o.OrderID, --for getting total cost of each order
        p.ProductID,
        p.ProductName,
        sum(od.LineTotal) as TotalCostByOrder
    from Customers c
    right join Orders o on o.CustomerID = c.CustomerID
    join OrderDetails od on od.OrderID = o.OrderID
    join Products p on p.ProductID = od.ProductID
    where o.StatusID = 2 -- Completed
     group by c.CustomerID,
        o.OrderDate,
        o.OrderID,
        p.ProductID,
        p.ProductName
)
select c.CustomerID , r.OrderDate, r.OrderID, r.ProductID, r.ProductName, r.TotalCostByOrder
from Customers c
left join result1 r on c.CustomerID = r.CustomerID
;


--List customers who has order in the system
select * from  dbo.fn_CustomerProductByOrder('2025-09-01','2025-09-30', 0);

--List all customers
select * from  dbo.fn_CustomerProductByOrder('2025-09-01','2025-09-30', 1);

*/