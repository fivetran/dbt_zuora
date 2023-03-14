with account as (

    select * 
    from {{ var('account') }} 
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
)

select 
    account_id,
    count(distinct subscription_id) as subscriptions,
    sum(case when status = 'Active' then 1 
            else 0 end) as active_subscriptions
from subscription
group by 1