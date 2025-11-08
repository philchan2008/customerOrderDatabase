--Data Preparation
SET IDENTITY_INSERT ProductCategories ON;

insert ProductCategories (ProdCatID, ProdCatDesc)
SELECT id, category_name
from tmp_amazon_cat tac 
;

SET IDENTITY_INSERT ProductCategories OFF;
go