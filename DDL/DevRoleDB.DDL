/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2005                    */
/* Created on:     11/8/2025 5:35:32 PM                         */
/*==============================================================*/


/*==============================================================*/
/* Table: CustomerAccountBalanceTransactions                    */
/*==============================================================*/
create table CustomerAccountBalanceTransactions (
   TransactionID        bigint               identity,
   CustomerID           bigint               null,
   TransactionDate      datetime             null,
   AccountBalance       decimal(18,2)        null,
   TransactionAmount    decimal(18,2)        null,
   Reference            xml                  null,
   Notes                nvarchar(1000)       null,
   constraint PK_CUSTOMERACCOUNTBALANCETRANS primary key nonclustered (TransactionID)
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
   AccountBalance       decimal(18,2)        null default 0,
   CreatedBy            varchar(50)          null default user,
   CreatedAt            datetime             null default getdate(),
   UpdatedBy            varchar(50)          null,
   UpdatedAt            datetime             null,
   constraint PK_CUSTOMERS primary key (CustomerID)
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSPHONE                                     */
/*==============================================================*/
create index IX_CUSTOMERSPHONE on Customers (
PhoneNumber ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOEMRSEMAIL                                     */
/*==============================================================*/
create index IX_CUSTOEMRSEMAIL on Customers (
EmailAddress ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSPOSTCODE                                  */
/*==============================================================*/
create index IX_CUSTOMERSPOSTCODE on Customers (
Postcode ASC
)
go

/*==============================================================*/
/* Index: IX_CUSTOMERSCITY                                      */
/*==============================================================*/
create index IX_CUSTOMERSCITY on Customers (
City ASC
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
/* Table: OrderDetails                                          */
/*==============================================================*/
create table OrderDetails (
   OrderDetailID        bigint               identity,
   OrderID              bigint               null,
   ProductID            bigint               null,
   ProductName          nvarchar(255)        null,
   Quantity             integer              null,
   UnitPrice            decimal(18,2)        null,
   LineTotal            decimal(18,2)        null,
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
   OrderDate            date                 null,
   TotalAmount          decimal(18,2)        null,
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
   TransDate            datetime             null default getdate(),
   ProductID            bigint               null,
   OldPrice             decimal(18,2)        null,
   NewPrice             decimal(18,2)        null,
   constraint PK_PRODUCTPRICEHISTORY primary key (PriceHistoryID)
)
go

/*==============================================================*/
/* Table: ProductTransactions                                   */
/*==============================================================*/
create table ProductTransactions (
   TransactionID        bigint               identity,
   ProductID            bigint               not null,
   TransDate            datetime             not null,
   TransType            int                  null,
   TransQuantity        int                  null,
   StockQuantity        int                  null,
   UnitPrice            decimal(18,2)        null,
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
   Price                decimal(18,2)        null default 0,
   StockQuantity        int                  null default 0,
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
/* View: ViewCustomerProductByOrder                             */
/*==============================================================*/
create view ViewCustomerProductByOrder as
with result1 (CustomerID, CustomerFullName, OrderDate, OrderID, 
    ProductID, ProductName, TotalQtyByOrder, TotalCostByOrder) as (
    select
        c.CustomerID,
		c.FullName as CustomerFullName,
        o.OrderDate,
        o.OrderID, --for getting total cost of each order
        p.ProductID,
        p.ProductName,
        sum(od.Quantity) as TotalQtyByOrder,
        sum(od.LineTotal) as TotalCostByOrder
    from Customers c
    right join Orders o on o.CustomerID = c.CustomerID
    join OrderDetails od on od.OrderID = o.OrderID
    join Products p on p.ProductID = od.ProductID
    where o.StatusID = 2 -- Completed
     group by c.CustomerID,
		c.FullName,
        o.OrderDate,
        o.OrderID,
        p.ProductID,
        p.ProductName
)
select c.CustomerID , c.FullName as CustomerFullName, r.OrderDate, 
                r.OrderID, r.ProductName, r.TotalQtyByOrder, r.TotalCostByOrder
from Customers c 
left join result1 r on c.CustomerID = r.CustomerID
go

/*==============================================================*/
/* View: ViewLatestCustomerBalance                              */
/*==============================================================*/
create view ViewLatestCustomerBalance as
SELECT
    C.CustomerID,
    C.FullName,
    T.AccountBalance,
    T.TransactionDate,
    T.TransactionAmount,
    T.TransactionID
FROM Customers C
OUTER APPLY (
    SELECT TOP 1 *
    FROM CustomerAccountBalanceTransactions T
    WHERE T.CustomerID = C.CustomerID
    ORDER BY T.TransactionDate DESC, T.TransactionID DESC
) T
go

alter table CustomerAccountBalanceTransactions
   add constraint FK_CUSTOMER_REF_CUSTO_CUSTOMER foreign key (CustomerID)
      references Customers (CustomerID)
go

alter table OrderDetails
   add constraint FK_ORDERDET_REF_ORDER_ORDERS foreign key (OrderID)
      references Orders (OrderID)
go

alter table OrderDetails
   add constraint FK_ORDERDET_REF_PRODU_PRODUCTS foreign key (ProductID)
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
   add constraint FK_PRODUCTP_REF_PRODU_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table ProductTransactions
   add constraint FK_PRODUCTT_REF_PRODU_PRODUCTS foreign key (ProductID)
      references Products (ProductID)
go

alter table ProductTransactions
   add constraint FK_PRODUCTT_REF_TRANS_TRANSACT foreign key (TransType)
      references TransactionTypes (TransType)
go


create procedure rpt_CustomerProductByOrder
    @fromDate date,
    @toDate date,
    @showAllCustomers bit
as
begin
	set NOCOUNT ON
    select
        c.CustomerID,
		c.FullName as CustomerFullName,
        o.OrderDate,
        o.OrderID, --for getting total cost of each order
        p.ProductID,
        p.ProductName,
        sum(od.Quantity) as TotalQtyByOrder,
        sum(od.LineTotal) as TotalCostByOrder
    into #tmpResult
    from Customers c
    right join Orders o on o.CustomerID = c.CustomerID
    join OrderDetails od on od.OrderID = o.OrderID
    join Products p on p.ProductID = od.ProductID
    where o.StatusID = 2 -- Completed
    and o.OrderDate >= @fromDate
    and o.OrderDate <= @toDate
     group by c.CustomerID,
		c.FullName,
        o.OrderDate,
        o.OrderID,
        p.ProductID,
        p.ProductName
                
    if @showAllCustomers = 1
    begin
        select c.CustomerID , c.FullName as CustomerFullName, r.OrderDate, 
                r.OrderID, r.ProductName, r.TotalQtyByOrder, r.TotalCostByOrder
        from Customers c 
        left join #tmpResult r on c.CustomerID = r.CustomerID
     end
     --
     if @showAllCustomers = 0
     begin
         select * from #tmpResult
     end
end
go


create trigger trg_UpdateCustomerBalance
on CustomerAccountBalanceTransactions for insert
as
begin
    set NOCOUNT ON;

    -- Update each affected customer's balance
    update c
    set c.AccountBalance = isnull(c.AccountBalance,0) + isnull(i.TransactionAmount,0)
    from Customers c
    join inserted i on i.CustomerID = c.CustomerID
END;
go


create trigger trg_hist_price on Products for insert, update as
begin
    if update(Price)
    begin
        insert ProductPriceHistory (ProductID, TransDate, OldPrice, NewPrice)
        select i.ProductID, getdate(), d.Price, i.Price
        from inserted i
        left join deleted d on i.ProductID = d.ProductID
    end
end
go

