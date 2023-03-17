with account as (

    select * 
    from {{ var('account') }} 
),

contact as (

    select * 
    from {{ var('contact') }} 
),

account_enriched as (

    select * 
    from {{ ref('int_zuora__account_enriched') }} 
)

select 
    account.account_id, 
    account.created_date as account_created_at,
    case when {{ dbt.datediff("account.created_date", dbt.current_timestamp(), "day") }} <= 30
        then true else false end as is_new_account,
    account.name as account_name,
    account.account_number,
    account.balance as account_balance,
    account.total_invoice_balance,
    account.credit_balance,
    account.unapplied_balance,
    account.mrr as account_mrr,
    account.status as account_status,
    account.auto_pay as is_auto_pay,
    contact.country as account_country,
    contact.city as account_city,
    contact.work_email as account_email,
    contact.first_name as account_first_name, 
    contact.last_name as account_last_name,
    contact.postal_code as account_postal_code,
    contact.state as account_state,
    account_enriched.first_charge_date,
    account_enriched.invoice_item_count,
    account_enriched.invoice_count,
    account_enriched.subscription_count,
    account_enriched.active_subscription_count,
    account_enriched.is_current_subscriber
    
    {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account') }},


from account
    left join contact 
        on account.account_id = contact.account_id
    left join account_enriched
        on account.account_id = account_enriched.account_id 
