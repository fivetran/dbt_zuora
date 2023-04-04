{% set sum_cols = ['invoice_amount', 'invoice_amount_paid', 'invoice_amount_unpaid', 'tax_amount', 'credit_balance_adjustment_amount', 'discount_charges'] %}
  
with invoice_joined as (

    select *
    from {{ ref('zuora__billing_history') }}
),

transactions_grouped as (

    select 
        account_id, 
        invoice_date as date_day,             
        cast({{ dbt.date_trunc("week", "invoice_date") }} as date) as date_week, 
        cast({{ dbt.date_trunc("month", "invoice_date") }} as date) as date_month, 
        cast({{ dbt.date_trunc("year", "invoice_date") }} as date) as date_year, 
        count(distinct invoice_id) as daily_invoices,
        sum(invoice_items) as daily_invoice_items,

        {% for col in sum_cols %}
        {% if var('using_multicurrency', true) %}
            sum({{ col }}_home_currency) as daily_{{ col }},
        {% else %} 
            sum({{ col }}) as daily_{{ col }},
        {% endif %}
        {% endfor %}
        
        sum(refund_amount) as daily_refunds 

    from invoice_joined
    {{ dbt_utils.group_by(5) }}
)

select *
from transactions_grouped
