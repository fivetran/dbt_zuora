with account_enriched as (

    select * 
    from {{ ref('int_zuora__account_enriched') }} 
),

contact as (

    select *,
        row_number() over (partition by account_id order by created_date desc) = 1 as is_most_recent_record
    from {{ var('contact') }} 
    
)

select 
    account_enriched.account_id, 
    account_enriched.created_date as account_created_at,
    account_enriched.name as account_name,
    account_enriched.account_number,
    account_enriched.credit_balance as account_credit_balance,
    account_enriched.mrr as account_mrr,
    account_enriched.status as account_status,
    account_enriched.auto_pay as is_auto_pay,
    contact.country as account_country,
    contact.city as account_city,
    contact.work_email as account_email,
    contact.first_name as account_first_name, 
    contact.last_name as account_last_name,
    contact.postal_code as account_postal_code,
    contact.state as account_state,
    account_enriched.first_charge_date as first_charge_processed_at,
    account_enriched.is_currently_subscribed,
    account_enriched.is_new_customer,
    account_enriched.invoice_item_count,
    account_enriched.invoice_count,
    account_enriched.active_subscription_count as number_of_active_subscriptions,
    account_enriched.subscription_count as number_of_subscriptions,
    account_enriched.total_invoice_amount as total_amount_of_charges,
    account_enriched.total_invoice_amount_home_currency as total_amount_of_charges_home_currency,
    account_enriched.total_taxes as total_amount_of_taxes,
    account_enriched.total_discounts as total_amount_of_discounts,
    account_enriched.total_amount_paid,
    account_enriched.total_amount_not_paid,
    account_enriched.total_amount_past_due,
    account_enriched.total_refunds,
    account_enriched.average_invoice_value,
    account_enriched.units_per_invoice,
    safe_divide(account_enriched.active_subscription_count, account_enriched.account_active_months) as active_subscriptions_per_month,
    safe_divide(account_enriched.subscription_count, account_enriched.account_active_months) as subscriptions_per_month,
    safe_divide(account_enriched.total_invoice_amount, account_enriched.account_active_months) as charges_per_month,
    safe_divide(account_enriched.total_invoice_amount_home_currency, account_enriched.account_active_months) as home_currency_charges_per_month,
    safe_divide(account_enriched.total_taxes, account_enriched.account_active_months) as taxes_per_month, 
    safe_divide(account_enriched.total_discounts, account_enriched.account_active_months) as discounts_per_month,
    safe_divide(account_enriched.total_amount_paid, account_enriched.account_active_months) as amount_paid_per_month,
    safe_divide(account_enriched.total_amount_not_paid, account_enriched.account_active_months) as amount_not_paid_per_month,
    safe_divide(account_enriched.total_amount_past_due, account_enriched.account_active_months) as amount_past_due_per_month,
    safe_divide(account_enriched.total_refunds, account_enriched.account_active_months) as refunds_per_month,
    safe_divide(account_enriched.average_invoice_value, account_enriched.account_active_months) as invoice_value_per_month, 
    safe_divide(account_enriched.units_per_invoice, account_enriched.account_active_months) as units_per_invoice_per_month
    
    {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account') }}

from account_enriched
    left join contact 
        on account_enriched.account_id = contact.account_id
        where contact.is_most_recent_record = true