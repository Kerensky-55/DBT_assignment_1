{% snapshot dim_customer_snapshot %}

{% set new_schema = target.schema + '_snapshot' %}

{{
    config(
        target_schema= new_schema,
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='latest_purchase'
    )
}}

select * from {{ ref("dim_customers") }}

{% endsnapshot %}
