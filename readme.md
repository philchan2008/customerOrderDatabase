# Modifications

- ID fields used bigint (or GUID depends on the requirements)
- Date fields used `date` type
- Quantity used `integer` type
- Money (amount/cost) fields used `decimal(18,2)`
- Add checking on fields like Quantity, Amount/TotalAmount must be greater than or equals to 0.
- Use computed field for FullName = LastName + ' ' + FirstName, LineTotal = UnitPrice * Quantity
- Split OrderStatus into master table and keep the StatusID in Orders table
- Master tables like Customers, Products added `CreatedBy, CeatedAt, UpdatedBy and UpdatedAt` fields for audit trail purpose
- Split the transaction fields such as AccountBalance, StockQuantity into transaction tables. At the same time I also keep the latest values in master table for getting the values easier and have better performance.
- Split customerAddresses from Customers table so that it allows multiple addresses per customer such as billing and shipping, and provides effective and expiry dates for the address.
- Add default values to Quantity, Date fields so that they will not be null
- Async update on Products.StockQuantity and Customers.AccountBalance using Async Triggers via Service Broker
- Add update triggers in OrderDetails table to update Orders.TotalAmount
- Keys & Indexes added, such as indexes for customers phone, email, postcode city, products price, name, qty
  - Create Primary Keys, Foreign Keys
  - Created targeted indexes on frequently queried fields like customer contact details and product attributes.
  - Created Unique indexes for Customers.EmailAddress and Customers.PhoneNumber
  - Applied predictive indexing for fields commonly used in WHERE, JOIN, or ORDER BY clauses.
- Created `fn_CustomerProductByOrder` table function for reporting
  - --List customers who has order in the system
    `select * from dbo.fn_CustomerProductByOrder('2025-09-01','2025-09-30', 0);`
  - --List all customers
    `select * from dbo.fn_CustomerProductByOrder('2025-09-01','2025-09-30', 1);`


# Original Schema

![](https://raw.githubusercontent.com/philchan2008/customerOrderDatabase/refs/heads/main/Original%20DB.svg)

# Updated Schema
![](https://raw.githubusercontent.com/philchan2008/customerOrderDatabase/refs/heads/main/ER%20Diagrams.svg)