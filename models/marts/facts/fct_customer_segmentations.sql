with rfm as (
    select
        customer_id,
        recency,
        frequency,
        monetary_value
    from {{ ref("fct_rfm") }}
),

rfm_score as (
    select
        customer_id,
        recency,
        frequency,
        monetary_value,
        ntile(4) over (order by recency asc) as recency_score, 
        ntile(4) over (order by frequency desc) as frequency_score,
        ntile(4) over (order by monetary_value desc) as monetary_score
    from rfm
),

rfm_tiers as (
    select
        customer_id,
        recency, 
        concat('R-tier-', recency_score) as recency_tier,
        frequency, 
        concat('F-tier-', frequency_score) as frequency_tier,
        monetary_value,
        concat('M-tier-', monetary_score) as monetary_tier,
        recency_score,
        frequency_score,
        monetary_score
    from rfm_score
),

customer_segments as (
    select
        customer_id,
        recency,
        recency_tier,
        frequency,
        frequency_tier,
        monetary_value,
        monetary_tier,
        case 
            when recency_score = 1 and frequency_score = 1 and monetary_score = 1 then 'Best Customer'
            when recency_score = 1 and frequency_score = 4 and monetary_score in (1, 2) then 'High-Spending New Customer'
            when recency_score = 1 and frequency_score = 1 and monetary_score in (3, 4) then 'Lowest-Spending Active Loyal Customer'
            when recency_score = 4 and frequency_score in (1, 2) and monetary_score in (1, 2) then 'Churned Best Customer'
            else 'Normal Customer'
        end as customer_segment
    from rfm_tiers
)

select * from customer_segments