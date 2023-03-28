with invoice_item_enriched as (

    select 
        invoice_id,
        count(distinct invoice_item_id) as invoice_items,
        count(distinct product_id) as products,
        count(distinct subscription_id) as subscriptions,
        sum(case when processing_type = '1' then charge_amount else 0 end) as discount_charges,
        sum(case when processing_type = '1' then charge_amount_home_currency else 0 end) as discount_charges_home_currency,
        sum(quantity) as units,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        min(service_start_date) as invoice_service_start_date,
        max(service_end_date) as invoice_service_end_date
    from {{ var('invoice_item') }} 
    {{ dbt_utils.group_by(1) }}
),

invoice_payment as (

    select 
        invoice_id,
        payment_id
    from {{ var('invoice_payment') }} 
),

payment as (

    select
        payment_id,
        payment_number,
        effective_date as payment_date,
        status as payment_status,
        type as payment_type, 
        amount_home_currency as payment_amount_home_currency,
        payment_method_id
    from {{ var('payment') }} 
),

payment_method as (
    
    select 
        payment_method_id,
        type as payment_method_type,
        coalesce(ach_account_type, bank_transfer_account_type, credit_card_type, paypal_type, sub_type) as payment_method_subtype,
        active as is_payment_method_active
    from {{ var('payment_method') }} 
),

credit_balance_adjustment as (

    select 
        invoice_id,
        credit_balance_adjustment_id,
        number as credit_balance_adjustment_number,
        reason_code as credit_balance_adjustment_reason_code,
        amount_home_currency as credit_balance_adjustment_home_currency,
        adjustment_date as credit_balance_adjustment_date
    from {{ var('credit_balance_adjustment') }} 
),

taxes as (

    select
        invoice_id, 
        sum(tax_amount_home_currency) as tax_amount_home_currency
    from {{ var('taxation_item') }} 
    {{ dbt_utils.group_by(1) }}
),

billing_enriched as (

    select 
        invoice_item_enriched.invoice_id,
        payment.payment_id,
        payment_number,
        payment_date,
        payment_status,
        payment_type, 
        payment_amount_home_currency as invoice_amount_paid_home_currency,
        payment_method.payment_method_id,
        payment_method_type,
        payment_method_subtype,
        is_payment_method_active, 
        credit_balance_adjustment_id,
        credit_balance_adjustment_number,
        credit_balance_adjustment_reason_code,
        credit_balance_adjustment_home_currency,
        credit_balance_adjustment_date, 
        taxes.tax_amount_home_currency,
        invoice_item_enriched.invoice_items,
        invoice_item_enriched.products,
        invoice_item_enriched.subscriptions,
        invoice_item_enriched.discount_charges,
        invoice_item_enriched.discount_charges_home_currency,
        invoice_item_enriched.units,
        invoice_item_enriched.first_charge_date,
        invoice_item_enriched.most_recent_charge_date,
        invoice_item_enriched.invoice_service_start_date,
        invoice_item_enriched.invoice_service_end_date
    from invoice_item_enriched
    left join invoice_payment 
        on invoice_item_enriched.invoice_id = invoice_payment.invoice_id
    left join payment
        on invoice_payment.payment_id = payment.payment_id
    left join payment_method
        on payment.payment_method_id = payment_method.payment_method_id
    left join credit_balance_adjustment
        on invoice_item_enriched.invoice_id = credit_balance_adjustment.invoice_id 
    left join taxes
        on invoice_item_enriched.invoice_id = taxes.invoice_id
)

select * 
from billing_enriched