with line_items as (

    select * 
    from {{ var('invoice_item')}}
    where is_most_recent_record 

), accounts as (

    select * 
    from {{ var('account') }}
    where is_most_recent_record 

), contacts as (

    select * 
    from {{ var('contact') }}
    where is_most_recent_record 

), invoices as (

    select * 
    from {{ var('invoice') }}
    where is_most_recent_record 

), invoice_payments as (

    select * 
    from {{ var('invoice_payment') }}
    where is_most_recent_record 

), payments as (

    select * 
    from {{ var('payment') }}
    where is_most_recent_record

), payment_methods as (

    select * 
    from {{ var('payment_method') }}
    where is_most_recent_record

), products as (

    select * 
    from {{ var('product') }}
    where is_most_recent_record

), subscriptions as (

    select *
    from {{ var('subscription') }} 
    where is_most_recent_record

), enhanced as (
select
    cast(line_items.invoice_id as {{ dbt.type_string() }}) as header_id,
    cast(line_items.invoice_item_id as {{ dbt.type_string() }}) as line_item_id,
    cast(row_number() over (partition by line_items.invoice_id order by line_items.invoice_item_id)
        as {{ dbt.type_int() }}) as line_item_index,
    line_items.created_date as line_item_created_at,
    invoices.created_date as invoice_created_at,
    invoices.status as header_status,
    invoices.source_type as billing_type,
    line_items.transaction_currency as currency,
    cast(line_items.product_id as {{ dbt.type_string() }}) as product_id,
    cast(products.name as {{ dbt.type_string() }}) as product_name,
    cast(products.category as {{ dbt.type_string() }}) as product_type,
    cast(case 
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '0' then 'charge'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '1' then 'discount'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '2' then 'prepayment'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '3' then 'tax'
        end as {{ dbt.type_string() }}) as transaction_type,
    line_items.quantity,
    cast(line_items.unit_price as {{ dbt.type_numeric() }}) as unit_amount,
    cast(case when cast(line_items.processing_type as {{ dbt.type_string() }}) = '1' 
        then line_items.charge_amount else 0 
        end as {{ dbt.type_numeric() }}) as discount_amount,
    cast(line_items.tax_amount as {{ dbt.type_numeric() }}) as tax_amount,
    cast(line_items.charge_amount as {{ dbt.type_numeric() }}) as total_amount,
    invoice_payments.payment_id as payment_id,
    invoice_payments.payment_method_id,
    payment_methods.name as payment_method,
    payments.effective_date as payment_at,
    cast(invoices.refund_amount as {{ dbt.type_numeric() }}) as refund_amount,
    line_items.subscription_id,
    subscriptions.subscription_start_date as subscription_period_started_at,
    subscriptions.subscription_end_date as subscription_period_ended_at,
    subscriptions.status as subscription_status,
    line_items.account_id as customer_id,
    'customer' as customer_level,
    accounts.name as customer_company,
    {{ dbt.concat(["contacts.first_name", "' '", "contacts.last_name"]) }} as customer_name,
    contacts.work_email as customer_email,
    contacts.city as customer_city,
    contacts.country as customer_country

from line_items

left join invoices
    on invoices.invoice_id = line_items.invoice_id

left join invoice_payments
    on invoice_payments.invoice_id = invoices.invoice_id

left join payments
    on payments.payment_id = invoice_payments.payment_id

left join payment_methods
    on payment_methods.payment_method_id = payments.payment_method_id

left join accounts
    on accounts.account_id = line_items.account_id

left join contacts
    on contacts.contact_id = line_items.bill_to_contact_id

left join products
    on products.product_id = line_items.product_id

left join subscriptions
    on subscriptions.subscription_id = line_items.subscription_id

), final as (

    select 
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        line_item_created_at as created_at,
        header_status,
        billing_type,
        currency,
        product_id,
        product_name,
        product_type,
        transaction_type,
        quantity,
        unit_amount,
        discount_amount,
        tax_amount,
        total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_numeric() }}) as refund_amount,
        subscription_id,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country,
        cast(null as {{ dbt.type_numeric() }}) as fee_amount
    from enhanced

    union all

    -- Refund information is only reliable at the invoice header. Therefore the below operation creates a new line to track the refund values.
    select
        header_id,
        cast(null as {{ dbt.type_string() }}) as line_item_id,
        cast(0 as {{ dbt.type_int() }}) as line_item_index,
        'header' as record_type,
        invoice_created_at as created_at,
        header_status,
        billing_type,
        currency,
        cast(null as {{ dbt.type_string() }}) as product_id,
        cast(null as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_string() }}) as transaction_type,
        cast(null as {{ dbt.type_numeric() }}) as quantity,
        cast(null as {{ dbt.type_numeric() }}) as unit_amount,
        cast(null as {{ dbt.type_numeric() }}) as discount_amount,
        cast(null as {{ dbt.type_numeric() }}) as tax_amount,
        cast(null as {{ dbt.type_numeric() }}) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        refund_amount,
        cast(null as {{ dbt.type_string() }}) as subscription_id,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_started_at,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_ended_at,
        cast(null as {{ dbt.type_string() }}) as subscription_status,
        customer_id,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country,
        cast(null as {{ dbt.type_numeric() }}) as fee_amount
    from enhanced
    where line_item_index = 1
)

select *
from final