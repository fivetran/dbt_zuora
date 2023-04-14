with invoice_item_enhanced as (

    select *,
        cast({{ dbt.date_trunc("day", "charge_date") }} as date) as charge_day,
        cast({{ dbt.date_trunc("week", "charge_date") }} as date) as charge_week,
        cast({{ dbt.date_trunc("month", "charge_date") }} as date) as charge_month,
        case when processing_type = '1' 
            then charge_amount_home_currency else 0 end as discount_amount_home_currency,
        case when processing_type = '1' 
            then charge_amount else 0 end as discount_amount,
        cast({{ dbt.date_trunc("day", "service_start_date") }} as date) as service_start_day,
        cast({{ dbt.date_trunc("week", "service_start_date") }} as date) as service_start_week,
        cast({{ dbt.date_trunc("month", "service_start_date") }} as date) as service_start_month
    from {{ var('invoice_item') }}
    where is_most_recent_record 
),

invoice as (

    select * 
    from {{ var('invoice') }}
    where is_most_recent_record 
),

product as (

    select * 
    from {{ var('product') }}
    where is_most_recent_record
),

product_rate_plan as (

    select * 
    from {{ var('product_rate_plan') }} 
    where is_most_recent_record
),

product_rate_plan_charge as (

    select * 
    from {{ var('product_rate_plan_charge') }} 
    where is_most_recent_record
), 

rate_plan_charge as (

    select * 
    from {{ var('rate_plan_charge') }} 
    where is_most_recent_record
), 

subscription as (

    select *
    from {{ var('subscription') }} 
    where is_most_recent_record
),

amendment as (

    select *
    from {{ var('amendment') }} 
    where is_most_recent_record
),

taxation_item as (

    select 
        invoice_item_id,
        tax_amount_home_currency
    from {{ var('taxation_item') }}
    where is_most_recent_record
), 

account_enhanced as (

    select  
        account_id,
        cast({{ dbt.date_trunc("day", "account_created_at") }} as date) as account_creation_day, 
        cast({{ dbt.date_trunc("day", "first_charge_processed_at") }} as date) as first_charge_day,
        account_status,
    from {{ ref('zuora__account_daily_overview') }}
    {{ dbt_utils.group_by(4) }}
),

invoice_revenue_items as (

    select
        invoice_item_id, 
        {% if var('using_multicurrency', true) %}
        charge_amount_home_currency as gross_revenue,
        case when processing_type = '1' 
            then charge_amount_home_currency else 0 end as discount_revenue
        {% else %} 
        charge_amount as gross_revenue,
        case when processing_type = '1' 
            then charge_amount else 0 end as discount_revenue
        {% endif %}
    from invoice_item_enhanced
),


line_item_history as (

    select 
        invoice_item_enhanced.invoice_item_id, 
        invoice_item_enhanced.account_id,  
        account_enhanced.account_creation_day, 
        account_enhanced.account_status,
        invoice_item_enhanced.amendment_id,
        invoice_item_enhanced.balance,
        invoice_item_enhanced.charge_amount,
        invoice_item_enhanced.charge_amount_home_currency,
        invoice_item_enhanced.charge_date,
        invoice_item_enhanced.charge_day,
        invoice_item_enhanced.charge_week,
        invoice_item_enhanced.charge_month,
        invoice_item_enhanced.charge_name,
        invoice_item_enhanced.discount_amount,
        invoice_item_enhanced.discount_amount_home_currency,
        account_enhanced.first_charge_day,
        invoice_item_enhanced.home_currency,
        invoice_item_enhanced.invoice_id,
        invoice_item_enhanced.product_id,
        invoice_item_enhanced.product_rate_plan_id,
        invoice_item_enhanced.product_rate_plan_charge_id,
        invoice_item_enhanced.rate_plan_charge_id,
        invoice_item_enhanced.service_start_day,
        invoice_item_enhanced.service_start_week,
        invoice_item_enhanced.service_start_month,
        invoice_item_enhanced.service_end_date,
        invoice_item_enhanced.subscription_id,
        invoice_item_enhanced.sku,
        invoice_item_enhanced.tax_amount,
        taxation_item.tax_amount_home_currency,
        invoice_item_enhanced.transaction_currency,
        invoice_item_enhanced.unit_price,
        invoice_item_enhanced.uom,
        invoice.invoice_number,
        invoice.invoice_date,
        invoice.due_date as invoice_due_date,   
        subscription.auto_renew as subscription_auto_renew,
        subscription.cancel_reason as subscription_cancel_reason,
        subscription.cancelled_date as subscription_cancel_date, 
        subscription.service_activation_date as subscription_service_activation_date,
        subscription.status as subscription_status,
        subscription.subscription_start_date,
        subscription.subscription_end_date,
        subscription.term_start_date as subscription_term_start_date,
        subscription.term_end_date as subscription_term_end_date,
        subscription.term_type as subscription_term_type,
        subscription.version as subscription_version,
        rate_plan_charge.name as rate_plan_charge_name,
        rate_plan_charge.billing_period as charge_billing_period,
        rate_plan_charge.billing_timing as charge_billing_timing,
        rate_plan_charge.charge_model as charge_model,
        rate_plan_charge.charge_type as charge_type,
        rate_plan_charge.effective_start_date as charge_effective_start_date,
        rate_plan_charge.effective_end_date as charge_effective_end_date,
        rate_plan_charge.segment as charge_segment,
        rate_plan_charge.mrr as charge_mrr,
        rate_plan_charge.mrrhome_currency as charge_mrr_home_currency,
        amendment.name as amendment_name,
        amendment.type as amendment_type,
        amendment.status as amendment_status,
        product.name as product_name,
        product.category as product_category,
        product.description as product_description,
        product.effective_start_date as product_start_date,
        product.effective_end_date as product_end_date, 
        product_rate_plan.name as product_rate_plan_name,
        product_rate_plan.description as product_rate_plan_description,
        invoice_revenue_items.gross_revenue,
        invoice_revenue_items.discount_revenue,
        invoice_revenue_items.gross_revenue - invoice_revenue_items.discount_revenue as net_revenue
    from invoice_item_enhanced
        left join invoice
            on invoice_item_enhanced.invoice_id = invoice.invoice_id
        left join subscription
            on invoice_item_enhanced.subscription_id = subscription.subscription_id
        left join rate_plan_charge 
            on invoice_item_enhanced.rate_plan_charge_id = rate_plan_charge.rate_plan_charge_id
        left join amendment
            on invoice_item_enhanced.amendment_id = amendment.amendment_id
        left join product
            on invoice_item_enhanced.product_id = product.product_id
        left join product_rate_plan
            on invoice_item_enhanced.product_rate_plan_id = product_rate_plan.product_rate_plan_id 
        left join account_enhanced
            on invoice_item_enhanced.account_id = account_enhanced.account_id
        left join invoice_revenue_items
            on invoice_item_enhanced.invoice_item_id = invoice_revenue_items.invoice_item_id
        left join taxation_item 
            on invoice_item_enhanced.invoice_item_id = taxation_item.invoice_item_id
)

select * 
from line_item_history