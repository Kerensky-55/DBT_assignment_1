with negative_revenue as (
    select 
        revenue  
    from {{ ref('fct_sales') }}
    where revenue < 0
)

select * from negative_revenue