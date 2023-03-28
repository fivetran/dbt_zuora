with account_running_totals as (

    select *
    from {{ ref('int_zuora__account_running_totals') }}
),

account_overview as (

    select * 
    from {{ ref('zuora__account_overview') }}
),

account_daily_overview as (

    select 
        account_running_totals.account_id,
        account_overview.account_created_at,
        account_overview.account_name,
        account_overview.account_number,
        account_overview.account_status,
        account_overview.account_country,
        account_overview.account_email,
        account_overview.account_first_name,
        account_overview.account_last_name,
        account_overview.account_postal_code,
        account_overview.account_state, 
        account_overview.first_charge_processed_at
        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account_overview') }}  

    from account_running_totals
    left join account_overview
        on account_running_totals.account_id = account_overview.account_id
)

select * 
from account_daily_overview