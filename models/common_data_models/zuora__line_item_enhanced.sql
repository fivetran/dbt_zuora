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

), products as (

    select * 
    from {{ var('product') }}
    where is_most_recent_record

{% if var('zuora__using_refund', true) %}
), refunds as (

    select *
    from {{ var('refund') }} 
    where is_most_recent_record
{% endif %}

), subscriptions as (

    select *
    from {{ var('subscription') }} 
    where is_most_recent_record

), enhanced as (
select
    line_items.invoice_id as header_id,
    line_items.invoice_item_id as line_item_id,
    row_number() over (partition by line_items.invoice_id, line_items.invoice_item_id 
        order by line_items.created_date) as line_item_index,
    line_items.created_date as created_at,
    line_items.transaction_currency as currency,
    -- need to add line_item_status
    invoices.status as header_status,
    line_items.product_id,
    products.name as products_name,
    -- need to create products_type,
    products.category as products_category,
    line_items.quantity,
    line_items.unit_price as unit_amount,
    case when cast(line_items.processing_type as {{ dbt.type_string() }}) = '1' 
        then line_items.charge_amount else 0 end as discount_amount,
    coalesce(line_items.tax_amount, 0) as tax_amount,
    line_items.charge_amount as total_amount,
    {{ dbt_utils.safe_divide('line_items.tax_amount', 'line_items.charge_amount') }} as tax_rate,
    invoice_payments.payment_id as payment_id,
    invoice_payments.payment_method_id as payment_method,
    payments.effective_date as payment_at,
-- fee_amount
    invoices.refund_amount,

    {% if var('zuora__using_refund', true) %}
    refunds.refund_id,
    refunds.refund_date as refunded_at,
    {% else %}
    {{ cast(null as dbt.type_string()) }} as refund_id,
    {{ cast(null as dbt.type_timestamp()) }} as refunded_at,
    {% endif %}

    line_items.subscription_id,
    subscriptions.subscription_start_date as subscriptions_period_started_at,
    subscriptions.subscription_end_date as subscriptions_period_ended_at,
    subscriptions.status as subscriptions_status,
    line_items.account_id as customer_id,
-- customer_level
    accounts.name as customer_company,
    concat(contacts.first_name, ' ', contacts.last_name) as customer_name,
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

{% if var('zuora__using_refund', true) %}
left join refunds
    on refunds.payment_method_id = payments.payment_method_id
{% endif %}

left join accounts
    on accounts.account_id = line_items.account_id

left join contacts
    on contacts.contact_id = line_items.bill_to_contact_id

left join products
    on products.product_id = line_items.product_id

left join subscriptions
    on subscriptions.subscription_id = line_items.subscription_id

), final as (
    {# select
        'line_item' as record_type,
    from enhanced

    union all

    select
        'header' as record_type
    from enhanced
    where line_item_index = 1 #}
    select *
    from enhanced

)

select *
from final