/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2005                    */
/* Created on:     11/9/2025 4:45:28 PM                         */
/*==============================================================*/


/*==============================================================*/
/* Table: AccountBalanceTransactionTypes                        */
/*==============================================================*/
create table AccountBalanceTransactionTypes (
   TransactionType      int                  identity,
   TransactionTypeName  nvarchar(100)        not null,
   CreditDebitFlag      int                  not null
      constraint CKC_CREDITDEBITFLAG_ACCOUNTB check (CreditDebitFlag in (1,-1)),
   constraint PK_ACCOUNTBALANCETRANSACTIONTY primary key (TransactionType)
)
go

SET IDENTITY_INSERT AccountBalanceTransactionTypes ON;

INSERT INTO AccountBalanceTransactionTypes (TransactionType, TransactionTypeName, CreditDebitFlag) VALUES
(1, 'Credit', 1),
(2, 'Debit', -1);

SET IDENTITY_INSERT AccountBalanceTransactionTypes OFF;
GO

/*==============================================================*/
/* Table: AddressTypes                                          */
/*==============================================================*/
create table AddressTypes (
   AddressTypeID        int                  identity,
   AddressType          nvarchar(100)        not null,
   constraint PK_ADDRESSTYPES primary key (AddressTypeID)
)
go

SET IDENTITY_INSERT AddressTypes ON;

INSERT INTO AddressTypes (AddressTypeID, AddressType) VALUES
(1, 'Billing'),
(2, 'Shipping');

SET IDENTITY_INSERT AddressTypes OFF;
GO

/*==============================================================*/
/* Table: CustomerAccountBalanceTransactions                    */
/*==============================================================*/
create table CustomerAccountBalanceTransactions (
   TransactionID        bigint               identity,
   CustomerID           bigint               null,
   TransactionType      int                  null,
   TransactionDate      datetime             null,
   TransactionAmount    money                null,
   Reference            xml                  null,
   Notes                nvarchar(1000)       null,
   constraint PK_CUSTOMERACCOUNTBALANCETRANS primary key nonclustered (TransactionID)
)
go

/*==============================================================*/
/* Table: CustomerAccountBalanceUpdateLog                       */
/*==============================================================*/
create table CustomerAccountBalanceUpdateLog (
   LogID                bigint               identity,
   LogDatetime          datetime             null default getdate(),
   TransactionID        bigint               not null,
   CustomerID           bigint               not null,
   TransactionType      int                  not null,
   TransactionAmount    money                not null,
   CreditDebitFlag      int                  not null,
   constraint PK_CUSTACCTBALUPDAT primary key (LogID)
)
go

/*==============================================================*/
/* Table: CustomerAddresses                                     */
/*==============================================================*/
create table CustomerAddresses (
   AddressID            bigint               identity,
   AddressTypeID        int                  not null,
   CustomerID           bigint               null,
   AddressLine          nvarchar(500)        not null,
   City                 nvarchar(100)        null,
   County               nvarchar(100)        null,
   Postcode             nvarchar(20)         not null,
   EffectiveDate        date                 null default getdate(),
   ExpiryDate           date                 null,
   CreatedBy            varchar(50)          null,
   CreatedAt            datetime             null,
   UpdatedBy            varchar(50)          null,
   UpdatedAt            datetime             null,
   constraint PK_CUSTOMERADDRESSES primary key (AddressID)
)
go

/*==============================================================*/
/* Table: Customers                                             */
/*==============================================================*/
create table Customers (
   CustomerID           bigint               identity,
   FullName             AS (isnull(FirstName, '') + N' ' + isnull(LastName,'')),
   FirstName            nvarchar(255)        null,
   LastName             nvarchar(255)        null,
   PhoneNumber          nvarchar(50)         null,
   EmailAddress         nvarchar(255)        null,
   DateOfBirth          date                 null,
   AccountBalance       money                null default 0,
   CreatedBy            varchar(50)          null default user,
   CreatedAt            datetime             null default getdate(),
   UpdatedBy            varchar(50)          null,
   UpdatedAt            datetime             null,
   constraint PK_CUSTOMERS primary key (CustomerID)
)
go

/*==============================================================*/
/* Index: UIX_CUSTOMERSPHONE                                    */
/*==============================================================*/
create unique index UIX_CUSTOMERSPHONE on Customers (
PhoneNumber ASC
)
go

/*==============================================================*/
/* Index: UIX_CUSTOEMRSEMAIL                                    */
/*==============================================================*/
create unique index UIX_CUSTOEMRSEMAIL on Customers (
EmailAddress ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSFULLNAME                                  */
/*==============================================================*/
create index IX_CUSTOMERSFULLNAME on Customers (
FullName ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSLASTNAME                                  */
/*==============================================================*/
create index IX_CUSTOMERSLASTNAME on Customers (
LastName ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSDOB                                       */
/*==============================================================*/
create index IX_CUSTOMERSDOB on Customers (
DateOfBirth ASC
)
go

/*==============================================================*/
/* Table: OrderDetails                                          */
/*==============================================================*/
create table OrderDetails (
   OrderDetailID        bigint               identity,
   OrderID              bigint               null,
   ProductID            bigint               null,
   ProductName          nvarchar(255)        null,
   Quantity             integer              null
      constraint CKC_QUANTITY_ORDERDET check (Quantity is null or (Quantity >= 0)),
   UnitPrice            money                null
      constraint CKC_UNITPRICE_ORDERDET check (UnitPrice is null or (UnitPrice >= 0)),
   LineTotal            AS (Quantity * UnitPrice),
   constraint PK_ORDERDETAILS primary key (OrderDetailID)
)
go

/*==============================================================*/
/* Index: IX_OD_ORDERID                                         */
/*==============================================================*/
create index IX_OD_ORDERID on OrderDetails (
OrderID ASC
)
go

/*==============================================================*/
/* Index: IX_OD_PRODID                                          */
/*==============================================================*/
create index IX_OD_PRODID on OrderDetails (
ProductID ASC
)
go

/*==============================================================*/
/* Index: IX_OD_QTY                                             */
/*==============================================================*/
create index IX_OD_QTY on OrderDetails (
Quantity ASC
)
go

/*==============================================================*/
/* Index: IX_OD_UNITPRICE                                       */
/*==============================================================*/
create index IX_OD_UNITPRICE on OrderDetails (
UnitPrice ASC
)
go

/*==============================================================*/
/* Index: IX_OD_ORDERPROD                                       */
/*==============================================================*/
create index IX_OD_ORDERPROD on OrderDetails (
OrderID ASC,
ProductID ASC
)
go

/*==============================================================*/
/* Table: OrderStatus                                           */
/*==============================================================*/
create table OrderStatus (
   StatusID             int                  identity,
   Status               nvarchar(50)         null,
   constraint PK_ORDERSTATUS primary key (StatusID)
)
go


SET IDENTITY_INSERT OrderStatus ON;

insert OrderStatus (StatusID, Status)
select 1, 'Pending' union
select 2, 'Completed'
;

SET IDENTITY_INSERT OrderStatus OFF;
go

/*==============================================================*/
/* Table: Orders                                                */
/*==============================================================*/
create table Orders (
   OrderID              bigint               identity,
   CustomerID           bigint               null,
   OrderDate            date                 null default getdate(),
   TotalAmount          money                null
      constraint CKC_TOTALAMOUNT_ORDERS check (TotalAmount is null or (TotalAmount >= 0)),
   StatusID             int                  null,
   constraint PK_ORDERS primary key (OrderID)
)
go

CREATE STATISTICS [_dta_stat_1077578877_2_5] ON [dbo].[Orders]([CustomerID], [StatusID])
WITH AUTO_DROP = OFF
go  

/*==============================================================*/
/* Index: IX_ORDERCUSTOMERS                                     */
/*==============================================================*/
create index IX_ORDERCUSTOMERS on Orders (
CustomerID ASC
)
go

/*==============================================================*/
/* Index: IX_ORDERDATE                                          */
/*==============================================================*/
create index IX_ORDERDATE on Orders (
OrderDate ASC
)
go

/*==============================================================*/
/* Index: IX_ORDERSTATUS                                        */
/*==============================================================*/
create index IX_ORDERSTATUS on Orders (
StatusID ASC
)
go

/*==============================================================*/
/* Index: IX_ORDERAMOUNT                                        */
/*==============================================================*/
create index IX_ORDERAMOUNT on Orders (
TotalAmount ASC
)
go

/*==============================================================*/
/* Table: ProductPriceHistory                                   */
/*==============================================================*/
create table ProductPriceHistory (
   PriceHistoryID       bigint               identity,
   TransactionDate      datetime             null default getdate(),
   ProductID            bigint               null,
   OldPrice             money                null,
   NewPrice             money                null,
   constraint PK_PRODUCTPRICEHISTORY primary key (PriceHistoryID)
)
go

/*==============================================================*/
/* Table: ProductStockQuantityUpdateLog                         */
/*==============================================================*/
create table ProductStockQuantityUpdateLog (
   LogID                bigint               identity,
   LogDatetime          datetime             null default getdate(),
   ProductID            bigint               not null,
   TransactionID        bigint               not null,
   TransactionType      int                  not null,
   TransactionQuantity  int                  not null,
   CreditDebitFlag      int                  not null,
   constraint PK_PRODUCTSTOCKQUANTITYUPDATEL primary key (LogID)
)
go

/*==============================================================*/
/* Table: ProductTransactionTypes                               */
/*==============================================================*/
create table ProductTransactionTypes (
   TransactionType      int                  identity,
   TransactionTypeName  nvarchar(100)        not null,
   CreditDebitFlag      int                  not null
      constraint CKC_CREDITDEBITFLAG_PRODUCTT check (CreditDebitFlag in (1,-1)),
   constraint PK_PRODUCTTRANSACTIONTYPES primary key (TransactionType)
)
go

SET IDENTITY_INSERT ProductTransactionTypes ON;

INSERT INTO ProductTransactionTypes 
(TransactionType, TransactionTypeName, CreditDebitFlag) VALUES
(1, 'Sale', -1),
(2, 'Purchase', 1),
(3, 'Return', 1),
(4, 'Damage', -1),
(5, 'Adjustment', 1);

SET IDENTITY_INSERT ProductTransactionTypes OFF;
GO

/*==============================================================*/
/* Table: ProductTransactions                                   */
/*==============================================================*/
create table ProductTransactions (
   TransactionID        bigint               identity,
   ProductID            bigint               not null,
   TransactionDate      datetime             not null,
   TransactionType      int                  null,
   TransactionQuantity  int                  null,
   UnitPrice            money                null,
   Reference            xml                  null,
   Notes                nvarchar(1000)       null,
   constraint PK_PRODUCTTRANSACTIONS primary key (TransactionID)
)
go

/*==============================================================*/
/* Table: Products                                              */
/*==============================================================*/
create table Products (
   ProductID            bigint               identity,
   ProductName          nvarchar(255)        null,
   Description          nvarchar(255)        null,
   Price                money                null default 0
      constraint CKC_PRICE_PRODUCTS check (Price is null or (Price >= 0)),
   StockQuantity        int                  null default 0
      constraint CKC_STOCKQUANTITY_PRODUCTS check (StockQuantity is null or (StockQuantity >= 0)),
   CreatedBy            varchar(50)          null default user,
   CreatedAt            datetime             null default getdate(),
   UpdatedBy            varchar(50)          null,
   UpdatedAt            datetime             null,
   constraint PK_PRODUCTS primary key (ProductID)
)
go

/*==============================================================*/
/* Index: IX_PRODNAME                                           */
/*==============================================================*/
create index IX_PRODNAME on Products (
ProductName ASC
)
go

/*==============================================================*/
/* Index: IX_PRODPRICE                                          */
/*==============================================================*/
create index IX_PRODPRICE on Products (
Price ASC
)
go

/*==============================================================*/
/* Index: IX_PRODSTOCKQTY                                       */
/*==============================================================*/
create index IX_PRODSTOCKQTY on Products (
StockQuantity ASC
)
go

/*==============================================================*/
/* Index: IX_PRODID                                             */
/*==============================================================*/
create index IX_PRODID on Products (
ProductID ASC
)
go

alter table CustomerAccountBalanceTransactions
   add constraint FK_CUSTACCTBALTRAN__ACCTBALTRANTYPES foreign key (TransactionType)
      references AccountBalanceTransactionTypes (TransactionType)
go

alter table CustomerAccountBalanceTransactions
   add constraint FK_CUSTBALTRAN__CUSTOMER2 foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table CustomerAccountBalanceUpdateLog
   add constraint FK_CUSTACCTBALUPDLOG__ACCTBALTRANTYPES foreign key (TransactionType)
      references AccountBalanceTransactionTypes (TransactionType)
go

alter table CustomerAccountBalanceUpdateLog
   add constraint FK_CUSTACCTBAL_TRANID foreign key (TransactionID)
      references CustomerAccountBalanceTransactions (TransactionID)
go

alter table CustomerAccountBalanceUpdateLog
   add constraint FK_CUSTACCTBALUPDLOG__CUSTOMERS foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table CustomerAddresses
   add constraint FK_CUSTADDR__ADDRTYPES foreign key (AddressTypeID)
      references AddressTypes (AddressTypeID)
go

alter table CustomerAddresses
   add constraint FK_CUSTADDR__CUSTOMERS foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table OrderDetails
   add constraint FK_ORDERDET_REF_ORDER_ORDERS foreign key (OrderID)
      references Orders (OrderID)
go

alter table OrderDetails
   add constraint FK_PRODUCTS__ORDERDETAILS foreign key (ProductID)
      references Products (ProductID)
go

alter table Orders
   add constraint FK_ORDERS_REF_CUSTO_CUSTOMER foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table Orders
   add constraint FK_ORDERS_REF_ORDER_ORDERSTA foreign key (StatusID)
      references OrderStatus (StatusID)
go

alter table ProductPriceHistory
   add constraint FK_PRODUCTS__PRODPRICEHIST foreign key (ProductID)
      references Products (ProductID)
go

alter table ProductStockQuantityUpdateLog
   add constraint FK_PRODTRANS__PRODSTKQTYUPDLOG foreign key (TransactionID)
      references ProductTransactions (TransactionID)
go

alter table ProductStockQuantityUpdateLog
   add constraint FK_PRODUCTS_REF_PRODT_PRODUCTT foreign key (TransactionType)
      references ProductTransactionTypes (TransactionType)
go

alter table ProductStockQuantityUpdateLog
   add constraint FK_PRODUCTS__PRODSTKQTYUPDLOG foreign key (ProductID)
      references Products (ProductID)
go

alter table ProductTransactions
   add constraint FK_PRODUCTS__PRODTRANS foreign key (ProductID)
      references Products (ProductID)
go

alter table ProductTransactions
   add constraint FK_TRANSTYPES__PRODTRANS foreign key (TransactionType)
      references ProductTransactionTypes (TransactionType)
go


CREATE FUNCTION dbo.fn_CustomerProductByOrder
(
    @fromDate DATE,
    @toDate DATE,
    @showAllCustomers BIT
)
RETURNS TABLE
AS
RETURN
(
    WITH OrderSummary AS (
        SELECT
            c.CustomerID,
            c.FullName AS CustomerFullName,
            o.OrderDate,
            o.OrderID,
            p.ProductID,
            p.ProductName,
            SUM(od.Quantity) AS TotalQtyByOrder,
            SUM(od.LineTotal) AS TotalCostByOrder
        FROM Customers c
        RIGHT JOIN Orders o ON o.CustomerID = c.CustomerID
        JOIN OrderDetails od ON od.OrderID = o.OrderID
        JOIN Products p ON p.ProductID = od.ProductID
        WHERE o.StatusID = 2
          AND o.OrderDate >= @fromDate
          AND o.OrderDate <= @toDate
        GROUP BY
            c.CustomerID,
            c.FullName,
            o.OrderDate,
            o.OrderID,
            p.ProductID,
            p.ProductName
    )
    SELECT
        c.CustomerID,
        c.FullName AS CustomerFullName,
        os.OrderDate,
        os.OrderID,
        os.ProductID,
        os.ProductName,
        os.TotalQtyByOrder,
        os.TotalCostByOrder
    FROM Customers c
    LEFT JOIN OrderSummary os ON c.CustomerID = os.CustomerID
    WHERE @showAllCustomers = 1

    UNION ALL

    SELECT
        os.CustomerID,
        os.CustomerFullName,
        os.OrderDate,
        os.OrderID,
        os.ProductID,
        os.ProductName,
        os.TotalQtyByOrder,
        os.TotalCostByOrder
    FROM OrderSummary os
    WHERE @showAllCustomers = 0
);
go



CREATE PROCEDURE sbp_ProcessAccountBalance
AS
BEGIN
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
            T.value('(TransactionAmount)[1]', 'MONEY'),
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
END;
GO

checkpoint
go


CREATE QUEUE AccountBalanceUpdateTargetQueue;

ALTER QUEUE AccountBalanceUpdateTargetQueue
WITH ACTIVATION (
    STATUS = ON,
    PROCEDURE_NAME = sbp_ProcessAccountBalance,
    MAX_QUEUE_READERS = 1,
    EXECUTE AS SELF
);
GO


CREATE PROCEDURE sbp_ProcessProductStockQuantity
AS
BEGIN
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
END;
GO

checkpoint
go

CREATE QUEUE StockQtyUpdateTargetQueue;

ALTER QUEUE StockQtyUpdateTargetQueue
WITH ACTIVATION (
    STATUS = ON,
    PROCEDURE_NAME = sbp_ProcessProductStockQuantity,
    MAX_QUEUE_READERS = 1,
    EXECUTE AS SELF
);
GO


create message type [AccountBalanceUpdateMessage] validation = none;

CREATE CONTRACT [AccountBalanceUpdateContract]
(
    [AccountBalanceUpdateMessage] SENT BY INITIATOR
);


CREATE QUEUE AccountBalanceUpdateInitiatorQueue;
CREATE QUEUE AccountBalanceUpdateTargetQueue;

CREATE SERVICE AccountBalanceUpdateInitiator
ON QUEUE AccountBalanceUpdateInitiatorQueue
(
    [AccountBalanceUpdateContract]
);

CREATE SERVICE AccountBalanceUpdateTarget
ON QUEUE AccountBalanceUpdateTargetQueue
(
    [AccountBalanceUpdateContract]
);
GO

create trigger [dbo].[trg_UpdateCustomerBalance]
on [dbo].[CustomerAccountBalanceTransactions] 
for insert
as
begin
    DECLARE @messageBody XML;

    SET @messageBody = (
        SELECT i.CustomerID, i.TransactionID, i.TransactionAmount, i.TransactionType, t.CreditDebitFlag 
        FROM inserted i
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
END;
go


create trigger trg_UpdateOrderTotalAmount on OrderDetails 
after insert, update, delete 
as
begin
    set NOCOUNT ON;

    -- Collect affected OrderIDs from inserted and deleted
    declare @AffectedOrders table (OrderID int);

    insert into @AffectedOrders (OrderID)
    select distinct OrderID from inserted;

    insert into @AffectedOrders (OrderID)
    select distinct OrderID from deleted;

    -- Update TotalAmount for each affected order
    update o
    set o.TotalAmount = ISNULL(agg.Total, 0)
    from Orders o
    join (
        select 
            od.OrderID,
            SUM(od.LineTotal) as Total
        from OrderDetails od
        join @AffectedOrders ao on od.OrderID = ao.OrderID
        group by od.OrderID
    ) agg on o.OrderID = agg.OrderID;

    -- Set TotalAmount to 0 for orders that now have no details
    update o
    set o.TotalAmount = 0
    from Orders o
    left join OrderDetails od on o.OrderID = od.OrderID
    where od.OrderID is null
    and o.OrderID in (select OrderID from @AffectedOrders);
END;
go


create message type [StockQtyUpdateMessage] validation = none;

CREATE CONTRACT [StockQtyUpdateContract]
(
    [StockQtyUpdateMessage] SENT BY INITIATOR
);


CREATE QUEUE StockQtyUpdateInitiatorQueue;
CREATE QUEUE StockQtyUpdateTargetQueue;


CREATE SERVICE StockQtyUpdateInitiator
ON QUEUE StockQtyUpdateInitiatorQueue
(
    [StockQtyUpdateContract]
);

CREATE SERVICE StockQtyUpdateTarget
ON QUEUE StockQtyUpdateTargetQueue
(
    [StockQtyUpdateContract]
);
GO

CREATE TRIGGER trg_ProdTransUpdateStkQty
ON ProductTransactions
for INSERT
AS
BEGIN
    DECLARE @messageBody XML;

    SET @messageBody = (
        SELECT i.TransactionID, i.ProductID, i.TransactionQuantity, i.TransactionType, t.CreditDebitFlag 
        FROM inserted i
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
END;
GO

/*
create trigger [dbo].[trg_ProdTransUpdateStkQty]
on [dbo].[ProductTransactions] 
after insert
as
begin
    set NOCOUNT ON;

    -- Update each affected customer's balance 
    update p
    set p.StockQuantity = isnull(c.StockQuantity,0) + 
                           ( isnull(i.TransQuantity,0) * CreditDebitFlag
    from Products c
    join inserted i on i.ProductID = c.ProductID
    join ProductTransactionTypes t on t.TransactionType = i.TransactionType
    
    insert into ProductStockQuantityUpdateLog (ProductID, TransactionType, TransactionQuantity)
    select ProductID, TransactionType, TransactionQuantity
    from inserted
END;
GO
*/
go


create trigger trg_CreatePriceHistory on Products for insert, update as
begin
    if update(Price)
    begin
        insert ProductPriceHistory (ProductID, TransactionDate, OldPrice, NewPrice)
        select i.ProductID, getdate(), d.Price, i.Price
        from inserted i
        left join deleted d on i.ProductID = d.ProductID
    end
end
go

