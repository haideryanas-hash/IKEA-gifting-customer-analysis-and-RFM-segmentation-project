# IKEA Gifting: Customer Analytics and RFM Segmentation

*An end-to-end data analytics project using SQL, Python and Power BI*

![Dashboard Preview](dashboard/page2.png)

---

## Disclaimer

**IKEA Gifting** is a fictional company name used only for this educational portfolio project. It is not affiliated with, endorsed by, or representative of the real IKEA corporation. All figures, customer counts and business metrics come from a public, anonymized transactional dataset and do not reflect any real company's performance. The IKEA-style branding in the dashboard is for design and storytelling purposes only.

## Credits

- **Dataset:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online-retail-ii), UCI Machine Learning Repository, donated by Daqing Chen. Licensed under CC BY 4.0.
- **Project guidance:** built by following the tutorial series by **Mansi G.** on YouTube ([channel](https://www.youtube.com/@Mansi.goel.offical)).

---

## Project Overview

This project simulates a real-world analytics engagement for a fictional UK-based gifting and home decor ecommerce brand. The goal is to take raw, messy transactional data all the way to a decision-ready dashboard:

1. Define the business problem (BRD)
2. Clean and validate the data in **SQL**
3. Build segmentation logic in **Python**
4. Deliver insights through an interactive **Power BI** report

## Business Problem

The business wants to identify its most valuable customers and reduce churn among customers who are at risk of leaving. Leadership has no structured view of customer value, so retention efforts are reactive instead of targeted.

## Business Questions Answered

- Who are the most valuable customers, and how much revenue do they contribute?
- Which customers have gone quiet and are at risk of churning?
- How do customer value and retention trend by month, quarter and year?
- How do customer value and churn differ across countries?
- What actions should the business take for each customer segment?

## Key Findings

- **Champions** are roughly 22% of customers but generate close to **68% of total revenue**.
- Overall churn is **50.86%** (90-day inactivity threshold), so retention is a significant business risk.
- Average customer value ranges from a few hundred (Lost) to several thousand (Champions).
- Revenue peaks in **Q4**, consistent with a gifting-focused business.

---

## Tools and Tech Stack

| Tool | Purpose |
|---|---|
| SQL Server / SSMS | Data import, type fixing, deduplication and quality checks on 1M+ rows |
| Python (pandas) | RFM calculation, scoring, segmentation and churn flagging |
| Jupyter Notebook | Interactive Python development |
| Power BI Desktop | Interactive multi-page dashboard |
| DAX | Measures for customers, revenue, churn % and average customer value |

## Concepts Demonstrated

- **RFM Analysis:** scoring customers on Recency, Frequency and Monetary value
- **Customer Segmentation:** Champions, Loyal, At Risk, New, Needs Attention, Lost
- **Churn Flagging:** customers inactive for more than 90 days
- **Data Quality Handling:** mixed date formats, missing IDs, negative quantities, duplicate detection with window functions
- **BI Design:** slicers, bookmark-based toggles, conditional formatting, custom theme

---

## Repository Structure

```
IKEA/
├── README.md
├── docs/
│   └── IKEA Gifting BRD.docx
├── 01_sql/
│   ├── 01_import_and_types.sql
│   ├── 02_data_quality_checks.sql
│   └── 03_deduplicate_RetailCleaned.sql
├── 02_python/
│   └── RFM_Segmentation.ipynb
├── 03_powerbi/
│   ├── IKEA Dashboard.pbix
│   └── IKEA Project Theme.json
└── dashboard/
    └── Ikea Dashboard as PDF.pdf
```

---

## Project Workflow

**Step 1: Business Requirements Document.** Defined scope, business questions, key definitions and success criteria before touching the data.

**Step 2: SQL, cleaning and exploration.**
- Imported both raw sheets into SQL Server and combined them into `RetailCombined`
- Fixed data types and a mixed date format issue using `TRY_CONVERT` with multiple styles
- Ran data quality checks (missing Customer ID, negative quantity, missing description, duplicates)
- Removed **32,907 exact duplicate rows** using `ROW_NUMBER()`
- Validated row counts at every step against the published UCI total

**Step 3: Python, RFM segmentation.**
- Loaded the cleaned data into pandas
- Calculated Recency, Frequency and Monetary value per customer
- Scored each dimension from 1 to 5 using quintiles
- Assigned **5,881 customers** to six segments
- Added a 90-day churn flag
- Merged results back onto transactions and exported a single analysis-ready file

**Step 4: Power BI dashboard.** Built a three-page interactive report on the merged table.

---

## Dashboard Structure

**Page 1, Home:** project title, navigation to the report pages, and a glossary (Recency, Frequency, Monetary, Churned %).

**Page 2, Business Overview:** KPIs for total customers, total revenue, churn % and average customer value; customer/revenue toggle using bookmarks; segment breakdowns; month, quarter and year trends. Filterable by month, quarter, year, country, segment and churn status.

**Page 3, RFM Analysis:** segment performance table (customers, revenue, average R/F/M scores), average customer value by segment, country performance summary with conditional formatting, and churn trend over time.

---

## Sample Code

**SQL: handling mixed date formats**

```sql
SELECT
    Invoice, StockCode, Description,
    COALESCE(
        TRY_CONVERT(datetime2, InvoiceDate, 120),
        TRY_CONVERT(datetime2, InvoiceDate, 105)
    ) AS InvoiceDate,
    TRY_CONVERT(decimal(10,2), Price) AS Price,
    Customer_ID, Country
FROM dbo.[Year 2009-2010];
```

**Python: RFM scoring**

```python
rfm['R_Score'] = pd.qcut(rfm['Recency'], 5, labels=[5, 4, 3, 2, 1]).astype(int)
rfm['F_Score'] = pd.qcut(rfm['Frequency'].rank(method='first'), 5, labels=[1, 2, 3, 4, 5]).astype(int)
rfm['M_Score'] = pd.qcut(rfm['Monetary'], 5, labels=[1, 2, 3, 4, 5]).astype(int)
```

**DAX: churn %**

```dax
Churned % =
DIVIDE(
    CALCULATE(DISTINCTCOUNT('Sheet1'[Customer_ID]), 'Sheet1'[IsChurned] = TRUE()),
    DISTINCTCOUNT('Sheet1'[Customer_ID])
)
```

---

## How to Reproduce

1. Download the **Online Retail II** dataset from the [UCI repository](https://archive.ics.uci.edu/dataset/502/online-retail-ii) and import both sheets into SQL Server as `[Year 2009-2010]` and `[Year 2010-2011]`.
2. Run the scripts in `01_sql` in order to create `RetailCombined` and `RetailCleaned`.
3. Export `RetailCleaned` to CSV and run the notebook in `02_python` to generate the segmented dataset (`EcommerceDashboardData.xlsx`).
4. Open the `.pbix` file in `03_powerbi`, point it to the exported Excel file and refresh.

> The large CSV and Excel files are not included in this repo because of GitHub's file size limits.
