with credit_balance_adjustment as (

    select * 
    from {{ var('credit_balance_adjustment') }} 
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
    credit_balance_adjustment_id as transaction_id,
    number as transaction_number,
    adjustment_date as transaction_date,
    status as transaction_status,
    created_date as transaction_created_at,
    amount as transaction_amount,
    transaction_currency,
    amount_home_currency as transaction_home_currency_amount,
    home_currency as transaction_home_currency,
    type as transaction_type,
    invoice.due_date as invoice_due_date,
    credit_balance_adjustment.invoice_id,
    credit_balance_adjustment.account_id,
    account.name as account_name,
    accounting_code,
    cast(null as {{ dbt.type_string() }}) as balance,
    cast(null as {{ dbt.type_string() }}) as charge_name,
    contact.work_email as created_by_email,
    cast(null as {{ dbt.type_string() }}) as quantity,
    cast(null as {{ dbt.type_string() }}) as tax_amount,
    cast(null as {{ dbt.type_string() }}) as uom,
    cast(null as {{ dbt.type_string() }}) as unit_price

from credit_balance_adjustment
    left join account on 
        credit_balance_adjustment.account_id = account.account_id
    left join invoice on 
        credit_balance_adjustment.invoice_id = invoice.invoice_id
    left join contact
        on credit_balance_adjustment.created_by_id = contact.contact_id