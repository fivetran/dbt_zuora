with account_enriched as (

    select * 
    from {{ ref('int_zuora__account_enriched') }} 
),

contact as (

    select *,
    from {{ var('contact') }} 
    where is_most_recent_record
    and is_most_recent_account_contact 
),

account_overview as (
    
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
        account_enriched.account_active_months,
        account_enriched.first_charge_date as first_charge_processed_at,
        account_enriched.is_currently_subscribed,
        account_enriched.is_new_customer,
        account_enriched.invoice_item_count,
        account_enriched.invoice_count,
        account_enriched.active_subscription_count as number_of_active_subscriptions,
        account_enriched.total_subscription_count as number_of_subscriptions,
        account_enriched.total_invoice_amount as total_amount_of_charges,
        account_enriched.total_invoice_amount_home_currency as total_amount_of_charges_home_currency,
        account_enriched.total_taxes as total_amount_of_taxes,
        account_enriched.total_discounts as total_amount_of_discounts,
        account_enriched.total_amount_paid,
        account_enriched.total_amount_not_paid,
        account_enriched.total_amount_past_due,
        account_enriched.total_refunds,
        account_enriched.total_average_invoice_value,
        account_enriched.total_units_per_invoice,

        {% set agged_cols = ['subscription_count', 'invoice_amount', 'invoice_amount_home_currency', 'taxes', 'discounts', 'amount_paid', 'amount_not_paid', 'amount_past_due', 'refunds', 'average_invoice_value', 'units_per_invoice'] %}
        {% for col in agged_cols %}
            {{- dbt_utils.safe_divide('total_' ~ col, 'account_active_months') }} as monthly_average_{{ col }} -- calculates average over no. active mos
            {{ ',' if not loop.last -}}
        {% endfor %}

        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account') }}

    from account_enriched
    left join contact 
        on account_enriched.account_id = contact.account_id
)

select * 
from account_overview