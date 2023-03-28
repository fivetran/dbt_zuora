{% set fields = ['rolling_invoices','rolling_invoice_items','rolling_invoice_amount','rolling_invoice_amount_home_currency','rolling_amount_paid','rolling_amount_paid_home_currency','rolling_amount_unpaid','rolling_taxes','rolling_refunds','rolling_credit_balance_adjustments','rolling_credit_balance_adjustments_home_currency','rolling_discounts','rolling_discounts_home_currency'] %}

with account_partitions as (

    select * 
    from {{ ref('int_zuora__account_partitions') }}
),

account_running_totals as (

    select
        account_id,
        {{ dbt_utils.generate_surrogate_key(['account_id','date_day']) }} as account_daily_id,
        date_day,        
        date_week, 
        date_month, 
        date_year,  
        date_index, 
        coalesce(daily_invoices,0) as daily_invoices,
        coalesce(daily_invoice_items,0) as daily_invoice_items,
        coalesce(daily_invoice_amount,0) as daily_invoice_amount,
        coalesce(daily_invoice_amount_home_currency,0) as daily_invoice_amount_home_currency,
        coalesce(daily_amount_paid,0) as daily_amount_paid,
        coalesce(daily_amount_paid_home_currency,0) as daily_amount_paid_home_currency,
        coalesce(daily_amount_unpaid,0) as daily_amount_unpaid,
        coalesce(daily_taxes,0) as daily_taxes,
        coalesce(daily_refunds,0) as daily_refunds,
        coalesce(daily_credit_balance_adjustments,0) as daily_credit_balance_adjustments,
        coalesce(daily_credit_balance_adjustments_home_currency,0) as daily_credit_balance_adjustments_home_currency,
        coalesce(daily_discounts,0) as daily_discounts,
        coalesce(daily_discounts_home_currency,0) as daily_discounts_home_currency,
        
        {% for f in fields %}
        coalesce({{ f }},   
            first_value({{ f }}) over (partition by {{ f }}_partition order by date_day rows unbounded preceding)) as {{ f }}
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    from account_partitions
)

select *
from account_running_totals