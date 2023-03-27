{% set fields = ['invoices', 'invoice_items', 'invoice_amount', 'invoice_amount_home_currency', 'amount_paid', 'amount_paid_home_currency', 'amount_unpaid', 'taxes', 'refunds', 'credit_balance_adjustments', 'credit_balance_adjustments_home_currency', 'discounts', 'discounts_home_currency'] %}


with invoice_periods as (

    select * 
    from {{ ref('int__zuora_invoice_date_spine') }}
),

transactions_grouped as (

    select *
    from {{ ref('int__zuora_transactions_grouped') }}
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
        coalesce(account_rolling.account_id, invoice_periods.account_id) as account_id,
        coalesce(account_rolling.date_day, invoice_periods.date_day) as date_day,
        coalesce(account_rolling.date_week, invoice_periods.date_week) as date_week,
        coalesce(account_rolling.date_month, invoice_periods.date_month) as date_month,
        coalesce(account_rolling.date_year, invoice_periods.date_year) as date_year,
        account_rolling.rolling_invoices,
        account_rolling.rolling_invoice_items,
        account_rolling.rolling_invoice_amount,
        account_rolling.rolling_invoice_amount_home_currency,
        account_rolling.rolling_amount_paid,
        account_rolling.rolling_amount_paid_home_currency, 
        account_rolling.rolling_amount_unpaid, 
        account_rolling.rolling_taxes, 
        account_rolling.rolling_refunds, 
        account_rolling.rolling_credit_balance_adjustments, 
        account_rolling.rolling_credit_balance_adjustments_home_currency, 
        account_rolling.rolling_discounts, 
        account_rolling.rolling_discounts_home_currency
        {% for f in fields %}
        case when account_rolling.rolling_{{ f }} is null and date_index = 1
            then 0
            else account_rolling.rolling_{{ f }}
            end as {{ f }},
        {% endfor %}
        invoice_periods.date_index
    from invoice_periods 
    left join account_rolling
        on account_rolling.account_id = invoice_periods.account_id 
        and account_rolling.date_day = invoice_periods.date_day
        and account_rolling.date_week = invoice_periods.date_week
        and account_rolling.date_month = invoice_periods.date_month
        and account_rolling.date_year = invoice_periods.date_year
)

select * 
from account_rolling_totals