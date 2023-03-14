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

select 
    invoice_item_id as transaction_id,
    invoice.invoice_number as transaction_number,
    invoice.invoice_date as transaction_date,
    invoice.status as transaction_status,
    invoice_item.charge_date as transaction_created_at,
    charge_amount as transaction_amount,
    transaction_currency,
    charge_amount_home_currency as transaction_home_currency_amount,
    home_currency as transaction_home_currency,
    'invoice item' as transaction_type,
    invoice.due_date as invoice_due_date,
    invoice_item.invoice_id,
    invoice_item.account_id,
    account.name as account_name,
    accounting_code, 
    balance,
    charge_name,
    contact.work_email as created_by_email,
    quantity,
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