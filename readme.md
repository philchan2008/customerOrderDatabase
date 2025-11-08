# Modifications

- ID fields used bigint (or GUID depends on the requirements)
- Date fields used `date` type
- Quantity used `integer` type
- Money (amount/cost) fields used `decimal(18,2)`
- Split OrderStatus into master table and keep the StatusID in Orders table
- Master tables like Customers, Products added `CreatedBy, CeatedAt, UpdatedBy and UpdatedAt` fields for audit trail purpose
- Split the transaction fields such as AccountBalance, StockQuantity into transaction tables. At the same time I also keep the latest values in master table for getting the values easier and have better performance.
- Add default values to Quantity, Date fields so that they will not be null
- Indexes added, such as indexes for customers phone, email, postcode city, products price, name, qty
  - Created targeted indexes on frequently queried fields like customer contact details and product attributes.
  - Applied predictive indexing for fields commonly used in WHERE, JOIN, or ORDER BY clauses.
  - Used SQL Server Tuning Advisor with sample data to identify and address missing or underused indexes.
- Created `rpt_CustomerProductByOrder` for reporting
  - --List customers who has order in the system
    `exec dbo.rpt_CustomerProductByOrder '2025-09-01','2025-09-30', 0;`
  - --List all customers
    `exec dbo.rpt_CustomerProductByOrder '2025-09-01','2025-09-30', 1;`
