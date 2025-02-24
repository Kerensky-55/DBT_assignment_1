with invalid_tiers as (
    select 
        customer_id, 
        recency_tier, 
        frequency_tier, 
        monetary_tier
    from {{ ref('fct_customer_segmentations') }}
    where recency_tier not in ('R-tier-1', 'R-tier-2', 'R-tier-3', 'R-tier-4')
       or frequency_tier not in ('F-tier-1', 'F-tier-2', 'F-tier-3', 'F-tier-4')
       or monetary_tier not in ('M-tier-1', 'M-tier-2', 'M-tier-3', 'M-tier-4')
)

select * from invalid_tiers
