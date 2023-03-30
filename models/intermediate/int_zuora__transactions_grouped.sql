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

        {% if var('using_multicurrency', true) %}
        sum(invoice_amount_home_currency) as daily_invoice_amount,
        sum(invoice_amount_paid_home_currency) as daily_amount_paid,
        sum(invoice_amount_unpaid_home_currency) as daily_amount_unpaid,
        sum(tax_amount_home_currency) as daily_taxes,
        sum(credit_balance_adjustment_home_currency) as daily_credit_balance_adjustments,
        sum(discount_charges_home_currency) as daily_discounts,
        {% else %} 
        sum(invoice_amount) as daily_invoice_amount, 
        sum(invoice_amount_paid) as daily_amount_paid,
        sum(invoice_amount_unpaid) as daily_amount_unpaid,
        sum(tax_amount) as daily_taxes,
        sum(credit_balance_adjustment_amount) as daily_credit_balance_adjustments,
        sum(discount_charges) as daily_discounts,
        {% endif %}
        
        sum(refund_amount) as daily_refunds 

    from invoice_joined
    {{ dbt_utils.group_by(5) }}
)

select *
from transactions_grouped