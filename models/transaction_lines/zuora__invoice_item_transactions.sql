with invoice_item as (

    select * 
    from {{ var('invoice_item') }} 
),

invoice as (

    select * 
    from {{ var('invoice') }} 
),

account as (

    select * 
    from {{ var('account') }} 
),


contact as (

    select * 
    from {{ var('contact') }} 
),

payment_method as (

    select * 
    from {{ var('payment_method') }}
),

product as (

    select * 
    from {{ var('product') }}
),

product_rate_plan_charge as (

    select * 
    from {{ var('product_rate_plan_charge') }}
)

select 
    invoice_item_id as transaction_id,
    invoice_item.created_date as created_at,
    invoice_item.updated_date as updated_at,
    invoice_item.account_id,
    account.name as account_name,
    invoice_item.invoice_id,
    invoice.invoice_number,
    invoice_item.charge_name, 
    invoice_item.charge_amount as transaction_amount,
    invoice_item.transaction_currency,
    invoice_item.charge_amount_home_currency as transaction_home_currency_amount,
    home_currency as transaction_home_currency,
    case 
        when invoice_item.processing_type = '0' then 'charge'
        when invoice_item.processing_type = '1' then 'discount'
        when invoice_item.processing_type = '2' then 'prepayment'
        when invoice_item.processing_type = '3' then 'tax' end as transaction_type,
    invoice.status as invoice_state,
    invoice.source_type as invoice_type,
    invoice.created_date as invoice_created_at,
    invoice.due_date as invoice_due_date,
    invoice_item.accounting_code, 
    invoice_item.quantity,
    invoice_item.unit_price,
    invoice_item.service_start_date,
    invoice_item.service_end_date,
    invoice.default_payment_method_id as payment_method_id,
    payment_method.type as payment_method_type,
    product.name as product_name, 
    product.description as product_description,
    product.category as product_category,
    product_rate_plan_charge.charge_model as product_rate_plan_charge_model,
    product_rate_plan_charge.charge_type as product_rate_plan_charge_type,
    balance,
    tax_amount,
    uom,
    unit_price
from invoice_item
    left join invoice 
        on invoice_item.invoice_id = invoice.invoice_id
    left join account 
        on invoice_item.account_id = account.account_id
    left join contact
        on invoice_item.created_by_id = contact.contact_id
    left join payment_method
        on invoice_payment.payment_method_id = payment_method.payment_method_id
    left join product 
        on invoice_item.product_id = product.product_id
    left join product_rate_plan_charge
        on invoice_item.product_rate_plan_charge_id = product_rate_plan_charge.product_rate_plan_charge_id 