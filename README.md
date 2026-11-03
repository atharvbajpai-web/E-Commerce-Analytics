# E-Commerce Sales & Customer Analytics

**Author:** Atharv Bajpai | **Tools:** PostgreSQL, Power BI | **Period:** January 2021 to December 2025

An end-to-end analysis of an online retailer's 138,116 orders from 24,911 customers. SQL was used to explore the data, Power BI to build a four-page dashboard, and a written report to turn the results into recommendations.

The business is profitable (43% margin) but revenue has been flat. This project looks at where growth stalls and where profit is lost. The questions it answers are in `Problem_Statement.pdf`.

## Key findings

- Revenue is $177.1M and profit $76.1M, but yearly revenue fell slightly from $35.7M (2021) to $35.1M (2025).
- 17.8% of orders (24,557) were cancelled, returned or left pending, worth $32.9M of booked revenue.
- Margin drops from 50.7% to 10.1% as discounts rise from under 10% to 40% or more.
- Premium and VIP customers get a 20% average discount against about 15.7% for others, with no larger orders.
- Electronics is the largest category ($41M) but has the lowest margin (34.3%).
- November and December bring in roughly 25% of annual revenue.
- Delayed orders rate 3.22 against 3.73 on time, and about 14.9% of completed orders arrive late.

## SQL analysis

`Ecommerce_SQL_Analysis.sql` has 21 PostgreSQL queries covering data checks, headline KPIs, sales trends, product and discount performance, customers, marketing and payments, and delivery and returns.

## Dashboard

| Page | Content |
|---|---|
| Business Overview | KPIs, order outcome, revenue and profit by year |
| Sales Trends | Monthly revenue and profit, sales channels, year-over-year summary |
| Customers & Marketing | Segments, country, marketing channel, rating by delivery outcome |
| Category & Discount Analysis | Margin and revenue by category, margin by discount band |

**Data model:** `customer_master` (1) to `orders` (many), `orders` (1) to `order_items` (many), and `product_catalog` (1) to `order_items` (many). Order-level measures use `orders` and product-level measures use `order_items`, since their totals differ by about 8%.

## Dataset

| File | Rows |
|---|---|
| `ecommerce_sales_customer_analytics_150k.csv` (orders) | 138,116 |
| `order_items.csv` | 397,569 |
| `product_catalog.csv` | 1,175 |
| `customer_master.csv` | 25,000 |

`net_sales` is the amount charged after discount, including tax and shipping, and is used as revenue. `profit` is `net_sales` minus product cost and shipping cost.

## Project structure

```
Ecommerce-analytics-project/
├── 01_data/
│   ├── customer_master.csv
│   ├── dataset_statistics.csv
│   ├── ecommerce_sales_customer_analytics_150k.csv
│   ├── order_items.csv
│   └── product_catalog.csv
├── 02_sql/
│   └── Ecommerce_SQL_Analysis.sql
├── 03_dashboard/
│   ├── 01_overview.png
│   ├── 02_sales trend.png
│   ├── 03_customers & marketing.png
│   └── 04_category & discount.png
├── 04_Problem_Statement/
│   └── Problem_Statement.pdf
├── 05_report/
│   └── Ecommerce_Insights_Report.pdf
└── README.md
```

## How to reproduce

1. **SQL:** create four tables in PostgreSQL named `orders`, `order_items`, `products` and `customers`, import the matching CSVs, then run the queries. Use `NUMERIC` for money columns and store `order_date` as text (`YYYY-MM-DD`).
2. **Dashboard:** import the four CSVs into Power BI, create the relationships above, and add the measures and the `Discount Band` column.

## Limitations

Revenue includes tax and shipping, mixed currencies are summed without conversion, and the data has no marketing spend. Results are very uniform, so the dataset may be synthetic.
