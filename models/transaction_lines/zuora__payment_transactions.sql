with payment as (

    select * 
    from {{ var('payment') }} 
),

account as (

    select * 
    from {{ var('account') }} 
),

contact as (

    select * 
    from {{ var('contact') }} 
),

invoice_item as (

    select * 
    from {{ var('invoice_item') }} 
),

select 
    payment_id as transaction_id,
    payment_number as transaction_number,
    effective_date as transaction_date,
    payment.status as transaction_status,
    created_date as transaction_created_at,
    payment.amount as transaction_amount,
    payment.transaction_currency,
    payment.amount_home_currency as transaction_home_currency_amount,
    home_currency as transaction_home_currency,
    payment.type as transaction_type,
    cast(null as {{ dbt.type_string() }}) as invoice_due_date,
    cast(null as {{ dbt.type_string() }}) as invoice_id,
    account.id as account_id,
    account.name as account_name,
    accounting_code,
    cast(null as {{ dbt.type_string() }}) as balance,
    cast(null as {{ dbt.type_string() }}) as charge_name,
    contact.work_email as created_by_email,
    cast(null as {{ dbt.type_string() }}) as quantity,
    cast(null as {{ dbt.type_string() }}) as tax_amount,
    cast(null as {{ dbt.type_string() }}) as uom,
    cast(null as {{ dbt.type_string() }}) as unit_price
from payment
    left join account 
        on payment.account_id = account.account_id
    left join invoice_item 
        on payment.invoice_id = invoice_item.invoice_id
    left join contact
        on payment.created_by_id = contact.contact_id