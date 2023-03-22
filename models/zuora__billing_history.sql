with invoice as (

    select * 
    from {{ var('invoice') }} 
),

invoice_item_enriched as (

    select * 
    from {{ ref('int_zuora__billing_enriched') }} 
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

invoice_payment as (

    select 
        invoice_id,
        payment_id
    from {{ var('invoice_payment') }} 
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

refund as (

    select 
        refund_id,
        refund_number,
        refund_date,
        status as refund_status,
        type as refund_type, 
        payment_method_id
    from {{ var('refund') }} 
),

payment_method as (
    
    select 
        payment_method_id,
        type as payment_method_type,
        coalesce(ach_account_type, bank_transfer_account_type, credit_card_type, paypal_type, sub_type) as payment_method_subtype,
        active as is_payment_method_active
    from {{ var('payment_method') }} 
),

final as (

    select 
        invoice.invoice_id,
        invoice.account_id,
        invoice.invoice_number,
        invoice.invoice_date,
        invoice.amount as invoice_amount,
        invoice.amount_home_currency as invoice_amount_home_currency,
        invoice.payment_amount,
        invoice.tax_amount,
        invoice.refund_amount,
        invoice.credit_balance_adjustment_amount,
        invoice.balance,
        invoice.transaction_currency,
        invoice.home_currency,
        invoice.exchange_rate_date,
        invoice.due_date,
        invoice.status,
        invoice.source_type as purchase_type,
        payment.payment_id,
        payment_number,
        payment_date,
        payment_status,
        payment_type, 
        payment_amount_home_currency, 
        credit_balance_adjustment_id,
        credit_balance_adjustment_number,
        credit_balance_adjustment_reason_code,
        credit_balance_adjustment_home_currency,
        credit_balance_adjustment_date,
        payment_method.payment_method_id,
        payment_method_type,
        payment_method_subtype,
        is_payment_method_active,
        invoice_item_enriched.invoice_items,
        invoice_item_enriched.products,
        invoice_item_enriched.subscriptions,
        invoice_item_enriched.discount_charges,
        invoice_item_enriched.units,
        invoice_item_enriched.first_charge_date,
        invoice_item_enriched.most_recent_charge_date

    from invoice
    left join invoice_payment on 
        invoice.invoice_id = invoice_payment.invoice_id
    left join payment on 
        invoice_payment.payment_id = payment.payment_id 
    left join credit_balance_adjustment on 
        credit_balance_adjustment.invoice_id = invoice.invoice_id
    left join invoice_item_enriched on  
        invoice.invoice_id = invoice_item_enriched.invoice_id
    left join payment_method on 
        payment.payment_method_id = payment_method.payment_method_id
)

select * 
from final