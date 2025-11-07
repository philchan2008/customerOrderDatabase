/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2005                    */
/* Created on:     11/7/2025 2:56:03 PM                         */
/*==============================================================*/
/*==============================================================*/
/* Table: CustomerAccountBalance                                */
/*==============================================================*/
create table CustomerAccountBalance (
   TransactionID        bigint               not null,
   CustomerID           bigint               null,
   TransactionDate      datetime             null,
   AccountBalance       decimal(18,2)        null,
   TransactionAmount    decimal(18,2)        null,
   constraint PK_CUSTOMERACCOUNTBALANCE primary key (TransactionID)
)
go

/*==============================================================*/
/* Table: Customers                                             */
/*==============================================================*/
create table Customers (
   CustomerID           bigint               identity,
   FullName             nvarchar(255)        null,
   FirstName            nvarchar(255)        null,
   LastName             nvarchar(255)        null,
   AddressLine          nvarchar(500)        null,
   City                 nvarchar(100)        null,
   County               nvarchar(100)        null,
   Postcode             nvarchar(20)         null,
   PhoneNumber          nvarchar(50)         null,
   EmailAddress         nvarchar(255)        null,
   DateOfBirth          date                 null,
   constraint PK_CUSTOMERS primary key (CustomerID)
)
go

/*==============================================================*/
/* Table: DimDate                                               */
/*==============================================================*/
create table DimDate (
   DateKey              int                  not null,
   FullDate             date                 null,
   Day                  int                  null,
   Month                int                  null,
   Year                 int                  null,
   Week                 int                  null,
   Quarter              int                  null,
   IsWeekend            bit                  null,
   IsHoliday            bit                  null,
   DayName              nvarchar(100)        null,
   MonthName            nvarchar(100)        null,
   constraint PK_DIMDATE primary key (DateKey)
)
go

/*==============================================================*/
/* Table: FactSales                                             */
/*==============================================================*/
create table FactSales (
   SalesID              bigint               identity(1,1),
   OrderID              bigint               null,
   OrderDetailID        bigint               null,
   CustomerID           bigint               null,
   ProductID            bigint               null,
   DateKey              int                  null,
   Quantity             int                  null,
   SalesAmount          decimal(18,2)        null,
   Status               nvarchar(50)         null,
   constraint PK_FACTSALES primary key (SalesID)
)
go

/*==============================================================*/
/* Table: Holidays                                              */
/*==============================================================*/
create table Holidays (
   HolidayDate          date                 not null,
   HolidayDesc          nvarchar(50)         null,
   constraint PK_HOLIDAYS primary key (HolidayDate)
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
   Quantity             integer              null,
   UnitPrice            decimal(18,2)        null,
   LineAmount           decimal(18,2)        null,
   constraint PK_ORDERDETAILS primary key (OrderDetailID)
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
--
insert OrderStatus (StatusID, Status)
select 1, 'Pending' union
select 2, 'Completed'
;
--
SET IDENTITY_INSERT OrderStatus OFF;
go

/*==============================================================*/
/* Table: Orders                                                */
/*==============================================================*/
create table Orders (
   OrderID              bigint               identity,
   CustomerID           bigint               null,
   OrderDate            date                 null,
   TotalAmount          decimal(18,2)        null,
   StatusID             int                  null,
   constraint PK_ORDERS primary key (OrderID)
)
go

/*==============================================================*/
/* Table: ProducTransactions                                    */
/*==============================================================*/
create table ProducTransactions (
   TransactionID        bigint               identity,
   ProductID            bigint               not null,
   TransDate            datetime             not null,
   TransType            int                  null,
   TransQuantity        integer              null,
   UnitPrice            decimal(18,2)        null,
   Reference            nvarchar(100)        null,
   Notes                nvarchar(1000)       null,
   constraint PK_PRODUCTRANSACTIONS primary key (TransactionID)
)
go

/*==============================================================*/
/* Table: ProductCategories                                     */
/*==============================================================*/
create table ProductCategories (
   ProdCatID            bigint               not null,
   ProdCatDesc          nvarchar(255)        not null,
   constraint PK_PRODUCTCATEGORIES primary key (ProdCatID)
)
go

/*==============================================================*/
/* Table: ProductPrices                                         */
/*==============================================================*/
create table ProductPrices (
   ProductID            bigint               identity,
   EffectiveDate        datetime             not null,
   Price                decimal(18,2)        null,
   constraint PK_PRODUCTPRICES primary key (ProductID, EffectiveDate)
)
go

/*==============================================================*/
/* Table: Products                                              */
/*==============================================================*/
create table Products (
   ProductID            bigint               identity,
   ProductName          nvarchar(255)        null,
   ProdCatID            bigint               null,
   Description          nvarchar(255)        null,
   Price                decimal(18,2)        null,
   StockQuantity        integer              null,
   constraint PK_PRODUCTS primary key (ProductID)
)
go

/*==============================================================*/
/* Table: TransactionTypes                                      */
/*==============================================================*/
create table TransactionTypes (
   TransType            int                  identity,
   TransTypeName        nvarchar(100)        not null,
   CreditDebitFlag      char(1)              not null default 'C'
      constraint CKC_CREDITDEBITFLAG_TRANSACT check (CreditDebitFlag in ('C','D')),
   constraint PK_TRANSACTIONTYPES primary key (TransType)
)
go

SET IDENTITY_INSERT TransactionTypes ON;

INSERT INTO TransactionTypes (TransType, TransTypeName, CreditDebitFlag) VALUES
(1, 'Sale', 'D'),
(2, 'Purchase', 'C'),
(3, 'Return', 'C'),
(4, 'Damage', 'D'),
(5, 'Adjustment', 'C');

SET IDENTITY_INSERT TransactionTypes OFF;

/*==============================================================*/
/* View: ViewCustomerOrders                                     */
/*==============================================================*/
create view ViewCustomerOrders as
select
    c.CustomerID,
    c.FullName,
    o.OrderDate,
    sum(o.TotalAmount) as SumOfTotalAmount
from Customers c
join Orders o on o.CustomerID = c.CustomerID
where o.StatusID = 2 -- Completed
group by c.CustomerID,
    c.FullName,
    o.OrderDate
go

alter table CustomerAccountBalance
   add constraint FK_CUSTOMER_REFERENCE_CUSTOMER foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table FactSales
   add constraint FK_FACTSALE_REFERENCE_DIMDATE foreign key (DateKey)
      references DimDate (DateKey)
go

alter table FactSales
   add constraint FK_FACTSALE_REFERENCE_CUSTOMER foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table FactSales
   add constraint FK_FACTSALE_REFERENCE_ORDERS foreign key (OrderID)
      references Orders (OrderID)
go

alter table FactSales
   add constraint FK_FACTSALE_REFERENCE_ORDERDET foreign key (OrderDetailID)
      references OrderDetails (OrderDetailID)
go

alter table FactSales
   add constraint FK_FACTSALE_REFERENCE_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table OrderDetails
   add constraint FK_ORDERDET_REFERENCE_ORDERS foreign key (OrderID)
      references Orders (OrderID)
go

alter table OrderDetails
   add constraint FK_ORDERDET_REFERENCE_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table Orders
   add constraint FK_ORDERS_REFERENCE_CUSTOMER foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table Orders
   add constraint FK_ORDERS_REFERENCE_ORDERSTA foreign key (StatusID)
      references OrderStatus (StatusID)
go

alter table ProducTransactions
   add constraint FK_PRODUCTR_REFERENCE_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table ProducTransactions
   add constraint FK_PRODUCTR_REFERENCE_TRANSACT foreign key (TransType)
      references TransactionTypes (TransType)
go

alter table ProductPrices
   add constraint FK_PRODUCTP_REFERENCE_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table Products
   add constraint FK_PRODUCTS_REFERENCE_PRODUCTC foreign key (ProdCatID)
      references ProductCategories (ProdCatID)
go


create procedure usp_OrderToFactSales as
begin
    delete FactSales where DateKey = CONVERT(NUMERIC(8,0), CONVERT(CHAR(8), getdate(), 112))
    --
    insert FactSales (OrderID, OrderDetailID, CustomerID, ProductID, DateKey, Quantity, SalesAmount)
    select o.OrderID, od.OrderDetailID, c.CustomerID, p.ProductID, dd.DateKey, 
    	sum(od.Quantity) as Quantity,
    	sum(od.LineAmount) as SalesAmount
    from DimDate dd 
    join Orders o on o.OrderDate = dd.FullDate
    join Customers c on o.CustomerID = c.CustomerID 
    join OrderDetails od on od.OrderID = o.OrderID 
    join Products p on p.ProductID = od.ProductID 
    where o.StatusID = 2 --completed
    and dd.FullDate = Cast(getdate() as Date)
    group by o.OrderID, od.OrderDetailID, c.CustomerID, p.ProductID, dd.DateKey
end
go


CREATE PROCEDURE usp_PopulateDimDate
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON
    --
    -- Create DimDate table if it doesn't exist
    IF OBJECT_ID('DimDate', 'U') IS NULL
    BEGIN
        CREATE TABLE DimDate (
            DateKey INT PRIMARY KEY,         -- Format: YYYYMMDD
            FullDate DATE NOT NULL,
            Day INT NOT NULL,
            Month INT NOT NULL,
            Year INT NOT NULL,
            Week INT NOT NULL,
            Quarter INT NOT NULL,
            DayName NVARCHAR(20),
            MonthName NVARCHAR(20),
            IsWeekend BIT,
            IsHoliday BIT
        )
    END
    --
    DECLARE @CurrentDate DATE = @StartDate
    --
    WHILE @CurrentDate <= @EndDate
    BEGIN
        DECLARE @IsHoliday BIT = CASE
            WHEN EXISTS (
                SELECT 1 FROM Holidays WHERE HolidayDate = @CurrentDate
            ) THEN 1 ELSE 0 END;

        INSERT INTO DimDate (
            DateKey, FullDate, Day, Month, Year, Week, Quarter,
            DayName, MonthName, IsWeekend, IsHoliday
        )
        VALUES (
            CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
            @CurrentDate,
            DAY(@CurrentDate),
            MONTH(@CurrentDate),
            YEAR(@CurrentDate),
            DATEPART(WEEK, @CurrentDate),
            DATEPART(QUARTER, @CurrentDate),
            DATENAME(WEEKDAY, @CurrentDate),
            DATENAME(MONTH, @CurrentDate),
            CASE WHEN DATENAME(WEEKDAY, @CurrentDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
            @IsHoliday
        )
        --
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
    END
END
go

exec usp_PopulateDimDate '2025-01-01','2026-01-01'
go

