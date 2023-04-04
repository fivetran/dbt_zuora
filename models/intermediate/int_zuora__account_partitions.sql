{% set fields = ['rolling_invoices','rolling_invoice_items','rolling_invoice_amount','rolling_invoice_amount_paid','rolling_invoice_amount_unpaid','rolling_tax_amount','rolling_credit_balance_adjustment_amount','rolling_discount_charges','rolling_refunds'] %}

with account_rolling_totals as (

    select * 
    from {{ ref('int_zuora__account_rolling_totals') }}
),

account_partitions as (

    select
        *,

        {% for f in fields %}
        sum(case when {{ f }} is null  
            then 0  
            else 1  
                end) over (order by account_id, date_day rows unbounded preceding) as {{ f }}_partition
        {%- if not loop.last -%},{%- endif -%}
        {% endfor %}              

    from account_rolling_totals
)

select * 
from account_partitions