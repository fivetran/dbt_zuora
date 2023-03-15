with account as (

    select * 
    from {{ var('account') }} 
),

contact as (

    select * 
    from {{ var('contact') }} 
),

invoice_item as (

    select * 
    from {{ var('invoice_item') }} 
),

/*
select
    account_id,
    balance,
    name,
    currency
    unapplied_amount as total_amount_not_paid,
    credit_balance

from account
*/

subscription as (

    select * 
    from {{ var('subscription') }} 
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
        count(distinct subscription_id) as subscriptions,
        sum(case when status = 'Active' then 1 
            else 0 end) as active_subscriptions
    from subscription
    {{ dbt_utils.group_by(1) }}
)


select 
    account.account_id, 
    account.account_created_date as account_created_at,
    contact.city as account_city,
    account.name as account_name,
    contact.country as account_country,
    contact.work_email as account_email,
    contact.first_name as account_first_name, 
    contact.last_name as account_last_name,
    contact.postal_code as account_postal_code,
    contact.state as account_state,
    invoice_charge_count,
    invoice_count,
    subscriptions,
    active_subscriptions
from account
    left join contact 
        on account.account_id = contact.account_id
    left join account_invoice_data
        on account.account_id = account_invoice_data.account_id 
