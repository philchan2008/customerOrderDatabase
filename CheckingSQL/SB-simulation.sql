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
    SELECT TOP 1 CustomerID, FullName
    FROM Customers c
	WHERE NOT EXISTS (select 1 from CustomerAccountBalanceTransactions x
		WHERE x.CustomerID = c.CustomerID)
    ORDER BY NEWID()
) C;
GO

SELECT COUNT(*) FROM AccountBalanceUpdateTargetQueue;

select count(*) from [dbo].[CustomerAccountBalanceUpdateLog]

SELECT 
    is_activation_enabled,
    activation_procedure,
    execute_as_principal_id
FROM sys.service_queues
WHERE name = 'AccountBalanceUpdateTargetQueue';

SELECT * FROM sys.transmission_queue
WHERE to_service_name = 'AccountBalanceUpdateTarget';

select * from ErrorLog

select * from  CustomerAccountBalanceTransactions i

select * from Customers where CustomerID = 7022
GO

DECLARE @messageBody XML;

    SET @messageBody = (
        SELECT i.CustomerID, i.TransactionID, i.TransactionAmount, i.TransactionType, t.CreditDebitFlag
        FROM CustomerAccountBalanceTransactions i
		JOIN AccountBalanceTransactionTypes t on i.TransactionType = t.TransactionType
        FOR XML PATH('Transaction'), ROOT('Transactions')
    );

    DECLARE @dialogHandle UNIQUEIDENTIFIER;

    BEGIN DIALOG CONVERSATION @dialogHandle
    FROM SERVICE AccountBalanceUpdateInitiator
    TO SERVICE 'AccountBalanceUpdateTarget'
    ON CONTRACT AccountBalanceUpdateContract
    WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @dialogHandle
    MESSAGE TYPE AccountBalanceUpdateMessage (@messageBody);
GO

DECLARE @messageBody XML;
    DECLARE @CustomerID INT;
    DECLARE @TransactionAmount INT;
    DECLARE @TransactionID INT;
    DECLARE @TransactionType INT;
    DECLARE @CreditDebitFlag INT;

    WHILE (1 = 1)
    BEGIN
        WAITFOR (
            RECEIVE TOP(1)
                @messageBody = message_body
            FROM AccountBalanceUpdateTargetQueue
        ), TIMEOUT 1000;

        IF @messageBody IS NULL BREAK;

        -- Parse and apply updates
        DECLARE @cursor CURSOR;
        SET @cursor = CURSOR FOR
        SELECT
            T.value('(CustomerID)[1]', 'INT'),
            T.value('(TransactionID)[1]', 'INT'),
            T.value('(TransactionAmount)[1]', 'money'),
            T.value('(TransactionType)[1]', 'INT'),
            T.value('(CreditDebitFlag)[1]', 'INT')
        FROM @messageBody.nodes('/Transactions/Transaction') AS X(T);

        OPEN @cursor;
        FETCH NEXT FROM @cursor INTO @CustomerID, @TransactionID, @TransactionAmount, @TransactionType, @CreditDebitFlag;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Customers
            SET AccountBalance = ISNULL(AccountBalance, 0) + @TransactionAmount * @CreditDebitFlag
            WHERE CustomerID = @CustomerID;

            INSERT INTO CustomerAccountBalanceUpdateLog
                  (LogDatetime, CustomerID, TransactionID, TransactionAmount, TransactionType, CreditDebitFlag)
            SELECT getdate(), @CustomerID, @TransactionID, @TransactionAmount, @TransactionType, @CreditDebitFlag

            FETCH NEXT FROM @cursor INTO @CustomerID, @TransactionID, @TransactionAmount, @TransactionType, @CreditDebitFlag;
        END

        CLOSE @cursor;
        DEALLOCATE @cursor;
    END
go


--Product
INSERT INTO ProductTransactions (
    ProductID,
    TransactionDate,
    TransactionType,
    TransactionQuantity,
    UnitPrice,
    Reference,
    Notes
)
SELECT top 1
    OD.ProductID,
    O.OrderDate,
    2, -- Assuming TransType = 2 means "Stock Out"
    OD.Quantity * 10,
    OD.UnitPrice,
    CAST('<OrderID>' + CAST(OD.OrderID AS NVARCHAR) + '</OrderID>' +
         '<OrderDetailID>' + CAST(OD.OrderDetailID AS NVARCHAR) + '</OrderDetailID>' +
         '<ProductName>' + OD.ProductName + '</ProductName>' AS XML),
    'Generated from OrderDetails'
FROM OrderDetails OD
INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE OD.ProductID IS NOT NULL;
go

DECLARE @messageBody XML;

    SET @messageBody = (
        SELECT top 1  i.TransactionID, i.ProductID, i.TransactionQuantity, i.TransactionType, t.CreditDebitFlag
        FROM ProductTransactions i
		JOIN ProductTransactionTypes t on i.TransactionType = t.TransactionType
        FOR XML PATH('Transaction'), ROOT('Transactions')
    );

    DECLARE @dialogHandle UNIQUEIDENTIFIER;

    BEGIN DIALOG CONVERSATION @dialogHandle
    FROM SERVICE StockQtyUpdateInitiator
    TO SERVICE 'StockQtyUpdateTarget'
    ON CONTRACT StockQtyUpdateContract
    WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @dialogHandle
    MESSAGE TYPE StockQtyUpdateMessage (@messageBody);
go

DECLARE @messageBody XML;
    DECLARE @ProductID INT;
    DECLARE @TransactionQuantity INT;
    DECLARE @TransactionID INT;
    DECLARE @TransactionType INT;
    DECLARE @CreditDebitFlag INT;

    WHILE (1 = 1)
    BEGIN
        WAITFOR (
            RECEIVE TOP(1)
                @messageBody = message_body
            FROM StockQtyUpdateTargetQueue
        ), TIMEOUT 1000;

        IF @messageBody IS NULL BREAK;

        -- Parse and apply updates
        DECLARE @cursor CURSOR;
        SET @cursor = CURSOR FOR
        SELECT
            T.value('(ProductID)[1]', 'INT'),
            T.value('(TransactionID)[1]', 'INT'),
            T.value('(TransactionQuantity)[1]', 'INT'),
            T.value('(TransactionType)[1]', 'INT'),
            T.value('(CreditDebitFlag)[1]', 'INT')
        FROM @messageBody.nodes('/Transactions/Transaction') AS X(T);

        OPEN @cursor;
        FETCH NEXT FROM @cursor INTO @ProductID, @TransactionID, @TransactionQuantity, @TransactionType, @CreditDebitFlag;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Products
            SET StockQuantity = ISNULL(StockQuantity, 0) + @TransactionQuantity * @CreditDebitFlag
            WHERE ProductID = @ProductID;

            INSERT INTO ProductStockQuantityUpdateLog
                  (LogDatetime, ProductID, TransactionID, TransactionQuantity, TransactionType, CreditDebitFlag)
            SELECT getdate(), @ProductID, @TransactionID, @TransactionQuantity, @TransactionType, @CreditDebitFlag

            FETCH NEXT FROM @cursor INTO @ProductID, @TransactionID, @TransactionQuantity, @TransactionType, @CreditDebitFlag;
        END

        CLOSE @cursor;
        DEALLOCATE @cursor;
    END
go

select * from ProductStockQuantityUpdateLog



SELECT COUNT(*) FROM StockQtyUpdateTargetQueue;

select count(*) from [dbo].[ProductStockQuantityUpdateLog]

SELECT 
    is_activation_enabled,
    activation_procedure,
    execute_as_principal_id
FROM sys.service_queues
WHERE name = 'StockQtyUpdateTargetQueue';

SELECT * FROM sys.transmission_queue
WHERE to_service_name = 'StockQtyUpdateTarget';

select * from ErrorLog;