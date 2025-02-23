with transactions as (
    select
        customer_id,
        country,
        invoice_date,
        quantity,
        unit_price,
        invoice_no
    from {{ ref('stg_raw_retail_data__transactions') }}
),

latest_country as (
    select distinct customer_id, country
    from (
        select 
            customer_id, 
            country, 
            invoice_date, 
            row_number() over (partition by customer_id order by invoice_date desc) as rn
        from transactions
    ) 
    where rn = 1
),

customer_spendings as (
    select
        customer_id,
        round(sum(quantity * unit_price), 2) as total_amount_spent,
        count(distinct invoice_no) as total_orders
    from transactions
    group by customer_id
),

customer_spending as (
    select 
        lc.customer_id,
        lc.country as latest_country,
        cs.total_amount_spent,
        cs.total_orders
    from latest_country lc
    join customer_spendings cs 
        on lc.customer_id = cs.customer_id
    order by total_amount_spent desc
)

select * from customer_spending