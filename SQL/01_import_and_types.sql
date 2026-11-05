/* =====================================================================
   01_import_and_types.sql
   Project : IKEA Gifting - Customer Analytics and RFM Segmentation
   Purpose : Validate raw imports, fix data types and mixed date
             formats, and combine both sheets into one table.
   Source  : Online Retail II (UCI) imported as two tables:
             dbo.[Year 2009-2010] and dbo.[Year 2010-2011]
   ===================================================================== */

USE EcommerceCustomerAnalytics;
GO

/* ---------------------------------------------------------------------
   STEP 1 - Check raw row counts (should total 1,067,371 rows)
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS Rows_2009_2010 FROM dbo.[Year 2009-2010];
SELECT COUNT(*) AS Rows_2010_2011 FROM dbo.[Year 2010-2011];


/* ---------------------------------------------------------------------
   STEP 2 - Inspect column data types of the raw tables
   --------------------------------------------------------------------- */
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Year 2009-2010', 'Year 2010-2011')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


/* ---------------------------------------------------------------------
   STEP 3 - Find rows where InvoiceDate cannot be converted
   (the dataset has mixed date formats, e.g. yyyy-mm-dd and dd-mm-yyyy)
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS Unconverted_Dates_2009_2010
FROM dbo.[Year 2009-2010]
WHERE TRY_CONVERT(datetime2, InvoiceDate, 120) IS NULL
  AND TRY_CONVERT(datetime2, InvoiceDate, 105) IS NULL;

SELECT COUNT(*) AS Unconverted_Dates_2010_2011
FROM dbo.[Year 2010-2011]
WHERE TRY_CONVERT(datetime2, InvoiceDate, 120) IS NULL
  AND TRY_CONVERT(datetime2, InvoiceDate, 105) IS NULL;


/* ---------------------------------------------------------------------
   STEP 4 - Combine both sheets into one typed table
   - COALESCE tries format 120 (yyyy-mm-dd hh:mi:ss) first,
     then format 105 (dd-mm-yyyy)
   - TRY_CONVERT returns NULL instead of failing on bad values
   - SourceSheet keeps track of which sheet each row came from
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS dbo.RetailCombined;
GO

SELECT
    Invoice,
    StockCode,
    Description,
    TRY_CONVERT(int, Quantity) AS Quantity,
    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,
    TRY_CONVERT(decimal(10,2), Price) AS Price,
    Customer_ID,
    Country,
    'Year 2009-2010' AS SourceSheet
INTO dbo.RetailCombined
FROM dbo.[Year 2009-2010]

UNION ALL

SELECT
    Invoice,
    StockCode,
    Description,
    TRY_CONVERT(int, Quantity) AS Quantity,
    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,
    TRY_CONVERT(decimal(10,2), Price) AS Price,
    Customer_ID,
    Country,
    'Year 2010-2011' AS SourceSheet
FROM dbo.[Year 2010-2011];
GO


/* ---------------------------------------------------------------------
   STEP 5 - Validate: combined count must equal the sum of both sheets
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS Total_Rows_RetailCombined FROM dbo.RetailCombined;

SELECT SourceSheet, COUNT(*) AS Rows_Per_Sheet
FROM dbo.RetailCombined
GROUP BY SourceSheet;

-- Any dates or prices that still failed conversion?
SELECT
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS Null_InvoiceDate,
    SUM(CASE WHEN Price       IS NULL THEN 1 ELSE 0 END) AS Null_Price,
    SUM(CASE WHEN Quantity    IS NULL THEN 1 ELSE 0 END) AS Null_Quantity
FROM dbo.RetailCombined;

/* NOTE:
   If your raw columns were imported with different data types
   (e.g. Customer_ID as float), adjust the conversions above to match
   what you see in STEP 2. */
