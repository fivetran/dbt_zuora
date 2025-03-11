{{ config(
    materialized='table',
    alias='combined_line_item_history',
    sort_key='invoice_item_id',
    dist='even'
) }}
{% set zuora_1_table = 'zuora_dbt.zuora_zuora__line_item_history' %}
{% set zuora_2_table = 'zuora_dbt.zuora_dsa_zuora__line_item_history' %}

with zuora_1_line_items as (
    select
        *,
        'zuora_1' as source_schema
    from {{ zuora_1_table }}
),

zuora_2_line_items as (
    select
        *,
        'zuora_2' as source_schema
    from {{ zuora_2_table }}
),

combined_line_items as (
    select * from zuora_1_line_items
    
    UNION ALL
    
    select * from zuora_2_line_items
)

select
    {{ dbt_utils.generate_surrogate_key(['invoice_item_id', 'source_schema']) }} as combined_id,
    *
from combined_line_items