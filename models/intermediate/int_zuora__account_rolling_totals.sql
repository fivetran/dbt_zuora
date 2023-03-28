{% set fields = ['invoices','invoice_items','invoice_amount','amount_paid','amount_unpaid','taxes','credit_balance_adjustments',  'discounts','refunds'] %}

with invoice_date_spine as (

    select * 
    from {{ ref('int_zuora__invoice_date_spine') }}
),

transactions_grouped as (

    select *
    from {{ ref('int_zuora__transactions_grouped') }}
), 

account_rolling as (
    
    select 
        *,
        {% for f in fields %}
        sum(daily_{{ f }}) over (partition by account_id order by date_day, account_id rows unbounded preceding) as rolling_{{ f }}
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}  
    from transactions_grouped
),

account_rolling_totals as (

    select 
        coalesce(account_rolling.account_id, invoice_date_spine.account_id) as account_id,
        coalesce(account_rolling.date_day, invoice_date_spine.date_day) as date_day,
        coalesce(account_rolling.date_week, invoice_date_spine.date_week) as date_week,
        coalesce(account_rolling.date_month, invoice_date_spine.date_month) as date_month,
        coalesce(account_rolling.date_year, invoice_date_spine.date_year) as date_year,
        account_rolling.daily_invoices,
        account_rolling.daily_invoice_items,
        account_rolling.daily_invoice_amount,
        account_rolling.daily_amount_paid,
        account_rolling.daily_amount_unpaid,
        account_rolling.daily_taxes,
        account_rolling.daily_credit_balance_adjustments,
        account_rolling.daily_discounts,
        account_rolling.daily_refunds,
        {% for f in fields %}
        case when account_rolling.rolling_{{ f }} is null and date_index = 1
            then 0
            else account_rolling.rolling_{{ f }}
            end as rolling_{{ f }},
        {% endfor %}
        invoice_date_spine.date_index
    from invoice_date_spine 
    left join account_rolling
        on account_rolling.account_id = invoice_date_spine.account_id 
        and account_rolling.date_day = invoice_date_spine.date_day
        and account_rolling.date_week = invoice_date_spine.date_week
        and account_rolling.date_month = invoice_date_spine.date_month
        and account_rolling.date_year = invoice_date_spine.date_year
)

select * 
from account_rolling_totals