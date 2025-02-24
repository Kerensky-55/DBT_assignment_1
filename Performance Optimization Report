# Performance Optimization Report

## Key Performance Techniques Used

### 1. **Incremental Materialization**

- Implemented incremental strategies (`delete+insert`) to reduce redundant data processing.
- Used `is_incremental()` to ensure only new records are processed, improving efficiency.
- Example:
  ```sql
  {{ config(
      materialized='incremental',
      incremental_strategy='delete+insert',
      unique_key=['invoice_no', 'stock_code']
  ) }}
  ```
- Filters only new records:
  ```sql
  and invoice_date > (select max(invoice_date) from {{ this }})
  ```

### 2. **Clustering and Partitioning**

- Used `cluster_by` on key columns like `invoice_date`, `customer_id`, and `revenue` to improve query performance.
- Example:
  ```sql
  {{ config(
      cluster_by=['invoice_date','revenue']
  ) }}
  ```

### 3. **Window Functions for Efficient Data Aggregation**

- Used `row_number()` for retrieving latest records efficiently.
- Used `ntile(4)` to segment customers efficiently in RFM analysis.
- Example:
  ```sql
  row_number() over (partition by customer_id order by invoice_date desc) as rn
  ```
  ```sql
  ntile(4) over (order by recency asc) as recency_score
  ```

### 4. **Common Table Expressions (CTEs) for Modular Queries**

- Structured queries using CTEs to break down complex logic and improve readability.
- Example:
  ```sql
  with transactions as (
      select * from {{ ref('stg_raw_retail_data__transactions') }}
  ),
  customer_lifetime as (
      select
          customer_id,
          min(invoice_date) as first_purchase,
          max(invoice_date) as latest_purchase
      from transactions
      group by customer_id
  )
  ```

### 5. **Data Cleaning and Filtering for Accuracy**

- Applied filters to remove invalid transactions (negative quantity, returns, and null values).
- Used regex `rlike '^[0-9]+$'` to exclude non-numeric stock codes.
- Example:
  ```sql
  where
      left(invoice_no, 1) != 'C'
      and quantity > 0
      and unit_price > 0
  ```

## **Audit Logging Mechanism**

### **Macros Implemented**

#### **1. Pre-hook Audit Logging (**``**)**

- Inserts an entry in the `audit_logs` table before model execution.
- Logs the model name and start time.
- Example:
  ```sql
  insert into {{ target.database }}.{{ target.schema }}.audit_logs
  (model_name, start_time)
  select '{{ model_name }}', current_timestamp;
  ```

#### **2. Post-hook Audit Logging (**``**)**

- Updates the log entry with `end_time` after execution.
- Calculates execution duration.
- Example:
  ```sql
  update {{ target.database }}.{{ target.schema }}.audit_logs
  set end_time = current_timestamp
  where model_name = '{{ model_name }}'
  ```

#### **3. Audit Log Retrieval (**``**)**

- Fetches the latest audit log and calculates execution time.
- Displays structured logs with execution duration in milliseconds.
- Example:
  ```sql
  select model_name, start_time, end_time,
         timestampdiff(millisecond, start_time, end_time) as execution_time_ms
  from {{ target.database }}.{{ target.schema }}.audit_logs
  ```

## **Conclusion**

By implementing incremental strategies, clustering, efficient aggregations, and audit logging, we have significantly optimized the performance of our dbt models. The audit macros ensure transparency and traceability in execution times, aiding performance monitoring and debugging.

