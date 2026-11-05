/* =====================================================================
   03_deduplicate_RetailCleaned.sql
   Project : IKEA Gifting - Customer Analytics and RFM Segmentation
   Purpose : Remove exact duplicate rows and produce the final
             cleaned table, dbo.RetailCleaned.
   Note    : dbo.RetailCombined is left untouched.
   ===================================================================== */

USE EcommerceCustomerAnalytics;
GO

-- Allow the script to be re-run safely
DROP TABLE IF EXISTS dbo.RetailCleaned;
GO

-- DEDUPLICATE AND PRODUCE THE FINAL CLEANED TABLE
WITH Deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
            ORDER BY (SELECT NULL)
        ) AS RowNum
    FROM dbo.RetailCombined
)
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
WHERE RowNum = 1;
GO


/* ---------------------------------------------------------------------
   VALIDATION - Rows removed should equal the duplicates found in
   02_data_quality_checks.sql (32,907 in this project)
   --------------------------------------------------------------------- */
SELECT
    (SELECT COUNT(*) FROM dbo.RetailCombined) AS Rows_Before,
    (SELECT COUNT(*) FROM dbo.RetailCleaned)  AS Rows_After,
    (SELECT COUNT(*) FROM dbo.RetailCombined)
      - (SELECT COUNT(*) FROM dbo.RetailCleaned) AS Duplicates_Removed;

-- Confirm no exact duplicates remain
SELECT COUNT(*) AS Remaining_Duplicate_Groups
FROM (
    SELECT 1 AS x
    FROM dbo.RetailCleaned
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
    HAVING COUNT(*) > 1
) AS d;

/* NEXT STEP:
   Export dbo.RetailCleaned to CSV (SSMS > Tasks > Export Data) and use
   it as the input for the Python notebook in 02_python. */
