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
        account_overview.first_charge_processed_at,
        
        {{ fivetran_utils.persist_pass_through_columns('zuora_account_pass_through_columns', identifier='account_overview') }}  
       
        account_running_totals.account_daily_id,
        account_running_totals.date_day,        
        account_running_totals.date_week, 
        account_running_totals.date_month, 
        account_running_totals.date_year,  
        account_running_totals.date_index, 
        daily_invoices,
        daily_invoice_items,
        daily_invoice_amount,
        daily_amount_paid,
        daily_amount_unpaid,
        daily_taxes,
        daily_credit_balance_adjustments,
        daily_discounts,
        daily_refunds,
        rolling_invoices,
        rolling_invoice_items,
        rolling_invoice_amount,
        rolling_amount_paid,
        rolling_amount_unpaid,
        rolling_taxes,
        rolling_credit_balance_adjustments,
        rolling_discounts,
        rolling_refunds

    from account_running_totals
    left join account_overview
        on account_running_totals.account_id = account_overview.account_id
)

select * 
from account_daily_overview