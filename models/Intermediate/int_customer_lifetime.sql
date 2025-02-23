with transactions as (
    select * from {{ ref('stg_raw_retail_data__transactions') }}
),

customer_lifetime as (
    select
        customer_id,
        min(invoice_date) as first_purchase,
        max(invoice_date) as latest_purchase,
        datediff(day, min(invoice_date), max(invoice_date)) as customer_lifetime_days
    from transactions
    group by customer_id
)

select * from customer_lifetime