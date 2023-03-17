with billing_history as (

    select * 
    from {{ ref('zuora__billing_history') }}
), 

subscription as (

    select * 
    from {{ var('subscription') }} 
), 

invoice_item as (

    select * 
    from {{ var('invoice_item')}}
),

account_totals as (

    select 
        account_id,
        sum(tax_amount) as total_taxes,
        sum(refund_amount) as total_refunds,
        sum(discount_charges) as total_discounts,
        sum(invoice_amount_home_currency) as total_invoice_balance_home_currency
    from billing_history
    {{ dbt_utils.group_by(1) }}
),


account_invoice_data as (

    select 
        account_id,
        count(distinct invoice_charge_id) as invoice_charge_count,
        count(distinct invoice_id) as invoice_count
    from invoice_item
    {{ dbt_utils.group_by(1) }}
),

account_subscription_data as (

    select 
        account_id,
        count(distinct subscription_id) as subscription_count,
        sum(case when status = 'Active' then 1 
            else 0 end) as active_subscription_count
    from subscription
    {{ dbt_utils.group_by(1) }}
),

account_cumulatives as (
    
select 
    account_totals.account_id,
    account_totals.total_taxes,
    account_totals.total_refunds,
    account_totals.total_discounts,
    account_totals.total_invoice_balance_home_currency,
    account_invoice_data.invoice_charge_count,
    account_invoice_data.invoice_count,
    account_subscription_data.subscription_count,
    account_subscription_data.active_subscription_count
from account_totals
    left join account_invoice_data
        on account_totals.account_id = account_invoice_data.account_id
    left join account_subscription_data
        on account_totals.account_id = account_subscription_data.account_id
)

select * 
from account_cumulatives
