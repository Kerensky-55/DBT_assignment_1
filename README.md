# Assignment 1

## Assignment Overview

This dbt assignment focuses on transforming raw retail transaction data stored in **Snowflake** ❄️ into structured, analytics-ready models for reporting and insights. The dataset, **Online Retail II**, contains transactions from a UK-based online retail company between **December 1, 2009, and December 9, 2011**. The company specializes in unique, all-occasion giftware, with many customers being wholesalers.

The primary goal of this project is to build efficient data models that support key analytical use cases, including:

- **📊 Customer Segmentation**: Grouping customers based on their purchasing behavior using **RFM (Recency, Frequency, Monetary) analysis**.
- **📈 Sales Performance Analysis**: Tracking revenue trends, customer lifetime value, and product demand patterns.
- **⚡ Incremental Data Processing**: Implementing dbt’s incremental strategies to optimize performance and minimize data processing costs.
- **✅ Data Quality & Governance**: Using dbt’s testing, sources, and macros to ensure clean and reliable data.

By structuring the data into **staging, intermediate, fact, and dimension models**, this project enables deeper insights and faster decision-making, ultimately enhancing business intelligence and reporting capabilities.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Macros & Hooks](#macros--hooks)
- [Sources (`src`)](#sources-src)
- [Staging (`stg`)](#staging-stg)
- [Intermediate Models (`int`)](#intermediate-models-int)
- [Fact & Dimension Models (`marts`)](#fact--dimension-models-marts)
- [Key Transformations](#key-transformations)
- [DAG & Data Lineage](#dag--data-lineage)
- [Performance Optimization](#performance-optimization)
- [Setup Instructions](#setup-instructions)
- [Conclusion](#conclusion)

---

## Tech Stack

- **<img src="assets/emoji.png" alt="emoji" width="20">dbt Cloud**: For transformation and modeling
- **❄️ Snowflake**: Data warehouse for storage and processing
- **🧩 Jinja**: For dynamic SQL generation
- **📊 Looker Studio**: For data visualization and reporting

---

## Project Directory Structure

```plaintext
/dbt_project
│── models
│   ├── marts
│   │   ├── fct_sales.sql
│   │   ├── fct_rfm.sql
│   │   ├── fct_customer_segmentation.sql
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   ├── intermediate
│   │   ├── int_customer_lifetime.sql
│   │   ├── int_customer_spendings.sql
│   ├── staging
│   │   ├── stg_raw_retail_schema__raw_retail_data.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   ├── sources
│   │   ├── src_retail_data.sql
│── macros
│── seeds
│── tests
│── snapshots
│── dbt_project.yml
```
---

## Macros

- **Pre & Post Hooks**: Implemented using macros to log model execution times. Pre-hooks insert a log entry before execution, and post-hooks update the log with completion time. These are defined in `audit_hooks.sql` and applied in `dbt_project.yml`.
- **Custom Macros**:
  - `audit_pre_hook(model_name)`: Inserts a log entry into `audit_log` before model execution.
  - `audit_post_hook(model_name)`: Updates the `audit_log` table with the model completion timestamp.
  - `create_audit_log()`: Creates an `audit_log` table to store execution logs.
  - `get_column_names(table_name)`: Dynamically retrieves column names from the information schema for a given table.
  - `print_audit_logs(model_name)`: Fetches and prints the latest audit log entry for a specific model.
  - `analyze_snowflake_queries(days_back=7, limit=20)`: Retrieves and analyzes Snowflake query execution logs, providing insights into execution time, resource consumption, partition scanning, and credit usage.

---

## Sources (`src`)

Sources represent the raw tables ingested from **Snowflake** ❄️. Defining sources in dbt provides better organization, documentation, and ensures data lineage tracking. They also help in implementing tests at the source level before transformations occur.

## Staging (`stg`)

Staging models clean and standardize the raw data from sources, ensuring consistency across the data pipeline. This includes handling null values, formatting text fields, and normalizing customer details.

## Intermediate Models (`int`)

Intermediate models serve as bridge tables, performing pre-aggregations and transformations before finalizing fact and dimension tables. These include calculations like **customer lifetime value** and **customer spending trends**.

---

## Fact & Dimension Models (`marts`)

- **📊 Fact Tables**: Contain aggregated sales data to analyze performance trends and revenue metrics.
  - `fct_sales.sql`: Captures transactional revenue data.
  - `fct_rfm.sql`: Computes recency, frequency, and monetary values for customer segmentation.
  - `fct_customer_segmentation.sql`: Assigns customers to segments based on RFM analysis.

- **🗂️ Dimension Tables**: Store descriptive attributes for customers and products to enable slicing and dicing of data.
  - `dim_customers.sql`: Contains customer profiles and purchasing behavior.
  - `dim_products.sql`: Stores product details and categories.

---

## Key Transformations

- **⚡ Ephemeral Models**: Implemented in `intermediate` to create temporary tables that do not persist in the database, improving query efficiency.
- **🔄 Incremental Loading**: Implemented in `stg_raw_retail_schema__raw_retail_data` and `fct_sales` to optimize performance and reduce processing time.
- **📊 Window Functions & Aggregations**: Used for customer segmentation and **RFM analysis**.
- **🔍 Normalization**: Cleaning and structuring customer details and product descriptions.

---

## DAG & Data Lineage

The project follows a structured **DAG (Directed Acyclic Graph)**, ensuring dependencies are well-defined, and each model builds upon previous transformations. The DAG optimizes query performance by clustering **Snowflake** ❄️ tables efficiently.

---

## Performance Optimization

- **📌 Snowflake Clustering**: Applied to large tables to improve query performance.
- **🕒 Pre & Post Hooks**: Implemented using macros to log model execution times. **Pre-hooks** insert a log entry before execution, and **post-hooks** update the log with completion time to analyze execution performance and optimize models.
- **📊 Snowflake Query Monitoring**: Implemented through the `analyze_snowflake_queries` macro, which retrieves query history and performance metrics such as execution time, partition scanning efficiency, and resource consumption. This helps in identifying and optimizing slow or resource-intensive queries.

---

## Setup Instructions

1. **🛠️ Clone the dbt repository**.
2. **🔧 Configure dbt Cloud** to connect with **Snowflake** ❄️.
3. **✅ Run `dbt debug`** to validate the setup.
4. **🏗️ Execute `dbt build`** to transform data and validate data integrity.
5. **📊 Deploy Looker Studio dashboards** for visualization.

---

## Conclusion

This **dbt Cloud** 🚀 project efficiently transforms raw retail data into meaningful insights through structured models, ensuring optimal performance and data accuracy. It leverages best practices in **data warehousing, incremental processing, and analytics modeling** to support business decision-making.

---

