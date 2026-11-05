/* =====================================================================
   02_data_quality_checks.sql
   Project : IKEA Gifting - Customer Analytics and RFM Segmentation
   Purpose : Profile data quality issues in dbo.RetailCombined before
             cleaning. These checks only READ data, nothing is changed.
   ===================================================================== */

USE EcommerceCustomerAnalytics;
GO

-- CHECK 1 - MISSING CUSTOMER ID
SELECT COUNT(*) AS Missing_CustomerID
FROM dbo.RetailCombined WHERE Customer_ID IS NULL;


-- CHECK 2 - NEGATIVE OR ZERO QUANTITY
SELECT COUNT(*) AS Negative_Qty
FROM dbo.RetailCombined WHERE Quantity <= 0;


-- CHECK 3 - MISSING DESCRIPTION
SELECT COUNT(*) AS Missing_Description
FROM dbo.RetailCombined
WHERE Description IS NULL;


-- CHECK 4 - EXACT DUPLICATE ROWS
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
       COUNT(*) AS ExactDupeCount
FROM dbo.RetailCombined
GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
HAVING COUNT(*) > 1;


/* ---------------------------------------------------------------------
   OPTIONAL - Total number of duplicate rows that will be removed
   (each group keeps one copy, so extras = count - 1)
   --------------------------------------------------------------------- */
SELECT SUM(ExactDupeCount - 1) AS Total_Duplicate_Rows_To_Remove
FROM (
    SELECT COUNT(*) AS ExactDupeCount
    FROM dbo.RetailCombined
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
    HAVING COUNT(*) > 1
) AS d;
