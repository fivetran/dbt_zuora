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
        sum(invoice_amount_home_currency) as total_invoice_balance_home_currency,
        max(payment_date) as most_recent_payment_date,
        max(credit_balance_adjustment_date) as most_recent_credit_balance_adjustment_date 
    from billing_history
    {{ dbt_utils.group_by(1) }}
),


account_invoice_data as (

    select 
        account_id,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        count(distinct invoice_item_id) as invoice_item_count,
        count(distinct invoice_id) as invoice_count
    from invoice_item
    {{ dbt_utils.group_by(1) }}
),

account_subscription_data as (

    select 
        account_id,
        count(distinct subscription_id) as subscription_count,
        sum(case when status = 'Active' then 1 else 0 end) as active_subscription_count
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
    account_totals.most_recent_payment_date,
    account_totals.most_recent_credit_balance_adjustment_date, 
    account_invoice_data.first_charge_date,
    account_invoice_data.most_recent_charge_date,
    account_invoice_data.invoice_item_count,
    account_invoice_data.invoice_count,
    account_subscription_data.subscription_count,
    account_subscription_data.active_subscription_count,
    case when account_subscription_data.active_subscription_count = 0 then false else true end as is_current_subscriber
from account_totals
    left join account_invoice_data
        on account_totals.account_id = account_invoice_data.account_id
    left join account_subscription_data
        on account_totals.account_id = account_subscription_data.account_id
)

select * 
from account_cumulatives
