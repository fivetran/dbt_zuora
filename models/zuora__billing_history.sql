with invoice as (

    select
        invoice_id,
        account_id,
        created_date as created_at,
        invoice_number,
        invoice_date,
        amount as invoice_amount,
        amount_home_currency as invoice_amount_home_currency,
        payment_amount as invoice_amount_paid,
        amount - payment_amount as invoice_amount_unpaid,
        tax_amount,
        refund_amount,
        credit_balance_adjustment_amount,
        transaction_currency,
        home_currency,
        exchange_rate_date,
        due_date,
        status,
        source_type as purchase_type,
        sum(case when cast({{ dbt.date_trunc('day', dbt.current_timestamp_backcompat()) }} as date) > due_date
                and amount != payment_amount
                then balance else 0 end) as total_amount_past_due
    from {{ var('invoice') }} 
    {{ dbt_utils.group_by(18) }}
),

billing_enriched as (

    select * 
    from {{ ref('int_zuora__billing_enriched') }} 
), 

refund as (

    select 
        amount as refund_amount,
        refund_id,
        refund_number,
        refund_date,
        status as refund_status,
        type as refund_type, 
        payment_method_id
    from {{ var('refund') }} 
),

billing_history as (

    select 
        invoice.invoice_id,
        invoice.account_id,
        invoice.created_at,
        invoice.invoice_number,
        invoice.invoice_date,
        invoice.invoice_amount,
        invoice.invoice_amount_home_currency,
        invoice.invoice_amount_paid,
        invoice.invoice_amount_unpaid,
        invoice.tax_amount,
        invoice.refund_amount,
        invoice.credit_balance_adjustment_amount,
        invoice.transaction_currency,
        invoice.home_currency,
        invoice.exchange_rate_date,
        invoice.due_date,
        invoice.status,
        invoice.purchase_type,
        billing_enriched.payment_id,
        billing_enriched.payment_number,
        billing_enriched.payment_date,
        billing_enriched.payment_status,
        billing_enriched.payment_type, 
        billing_enriched.invoice_amount_paid_home_currency,
        invoice.invoice_amount_home_currency - billing_enriched.invoice_amount_paid_home_currency as invoice_amount_unpaid_home_currency,
        billing_enriched.payment_method_id,
        billing_enriched.payment_method_type,
        billing_enriched.payment_method_subtype,
        billing_enriched.is_payment_method_active, 
        billing_enriched.credit_balance_adjustment_id,
        billing_enriched.credit_balance_adjustment_number,
        billing_enriched.credit_balance_adjustment_reason_code,
        billing_enriched.credit_balance_adjustment_home_currency,
        billing_enriched.credit_balance_adjustment_date, 
        billing_enriched.tax_amount_home_currency,
        billing_enriched.invoice_items,
        billing_enriched.products,
        billing_enriched.subscriptions,
        billing_enriched.discount_charges,
        billing_enriched.discount_charges_home_currency,
        billing_enriched.units,
        billing_enriched.first_charge_date,
        billing_enriched.most_recent_charge_date,
        billing_enriched.invoice_service_start_date,
        billing_enriched.invoice_service_end_date
    from invoice
    left join billing_enriched on 
        invoice.invoice_id = billing_enriched.invoice_id
)

select * 
from billing_history