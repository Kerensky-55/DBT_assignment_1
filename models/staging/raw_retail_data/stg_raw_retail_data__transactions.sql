{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['invoice_no', 'stock_code']
    )
}}

{%- set table_name = source('raw_retail', 'transactions').identifier.split('.')[-1] -%}
{%- set columns = get_column_names(table_name) -%}

with source as (
    select * from {{ source('raw_retail', 'transactions') }}
),

cleaned as (
    select
    invoiceno as invoice_no, 
    stockcode as stock_code, 
    trim(description) as description, 
    quantity, 
    TO_DATE(invoicedate) AS invoice_date,
    unitprice as unit_price, 
    customerid as customer_id, 
    country
from source
where
    left(invoice_no, 1) != 'C' 
    and
    quantity > 0 
    and
    unit_price > 0 
    and
{%- for column in columns %}
    {{ column }} is not null
    {% if not loop.last -%}
        and
    {%- endif -%}
{%- endfor -%}
    and 
    stock_code rlike '^[0-9]+$'
    {%- if is_incremental() %}
    and 
    invoice_date > (select max(invoice_date) from {{ this }})
    {% endif %}
)

select * from cleaned