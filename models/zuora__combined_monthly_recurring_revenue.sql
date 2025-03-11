{{ config(
    materialized='table',
    alias='combined_monthly_recurring_revenue',
    sort_key='account_id, account_month',
    dist='even'
) }}
{% set zuora_1_table = 'zuora_dbt.zuora_zuora__monthly_recurring_revenue' %}
{% set zuora_2_table = 'zuora_dbt.zuora_dsa_zuora__monthly_recurring_revenue' %}

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
    {{ dbt_utils.generate_surrogate_key(['account_id', 'account_month']) }} as combined_id,
    *
from combined_line_items