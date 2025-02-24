{{ config(
    cluster_by=['customer_id']
    )
}}

with customer_lifetime as (
    select
        customer_id,
        first_purchase,
        latest_purchase
    from {{ ref("int_customer_lifetime") }}
),
customer_spendings as (
    select
        customer_id,
        latest_country,
        total_amount_spent,
        total_orders
    from {{ ref("int_customer_spendings") }}
),
customer_segments as (
    select
        customer_id,
        customer_segment
    from {{ ref('fct_customer_segmentations') }}
),
customers as (
    select
        cl.customer_id,
        cl.first_purchase,
        cl.latest_purchase,
        cs.latest_country,
        cs.total_amount_spent,
        cs.total_orders,
        seg.customer_segment
    from customer_lifetime cl
    join customer_spendings cs on cl.customer_id = cs.customer_id
    join customer_segments seg on cl.customer_id = seg.customer_id
)
select * from customers