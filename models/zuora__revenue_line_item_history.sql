with invoice_item_enhanced as (

    select *,
        cast({{ dbt.date_trunc("day", "charge_date") }} as date) as charge_day,
        cast({{ dbt.date_trunc("week", "charge_date") }} as date) as charge_week,
        cast({{ dbt.date_trunc("month", "charge_date") }} as date) as charge_month,
        case when processing_type = '1' 
            then charge_amount_home_currency else 0 end as discount_amount_home_currency,
        case when processing_type = '1' 
            then charge_amount else 0 end as discount_amount  
    from {{ var('invoice_item') }}
),

invoice as (

    select * 
    from {{ var('invoice') }} 
),

product as (

    select * 
    from {{ var('product') }} 
),

product_rate_plan as (

    select * 
    from {{ var('product_rate_plan') }} 
),

product_rate_plan_charge as (

    select * 
    from {{ var('product_rate_plan_charge') }} 
), 

rate_plan_charge as (

    select * 
    from {{ var('rate_plan_charge') }} 
), 

taxation_item as (

    select 
        invoice_item_id,
        tax_amount_home_currency
    from {{ var('taxation_item') }} 
), 


account_months as (

    select 
        account_id,
        cast({{ dbt.date_trunc("day", "account_created_at") }} as date) as account_creation_day, 
        cast({{ dbt.date_trunc("day", "first_charge_processed_at") }} as date) as first_charge_day,
        account_status,
        date_month as account_month
    from {{ ref('zuora__account_daily_overview') }}

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

revenue_line_item_history as (

    select 
        invoice_item_enhanced.invoice_item_id, 
        coalesce(account_months.account_id, invoice_item_enhanced.account_id) as account_id, 
        coalesce(account_months.account_month, invoice_item_enhanced.charge_month) as account_month,
        account_months.account_creation_day, 
        account_months.account_status,
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
        account_months.first_charge_day,
        invoice_item_enhanced.home_currency,
        invoice_item_enhanced.invoice_id,
        invoice_item_enhanced.product_id,
        invoice_item_enhanced.product_rate_plan_id,
        invoice_item_enhanced.product_rate_plan_charge_id,
        invoice_item_enhanced.rate_plan_charge_id,
        invoice_item_enhanced.sku,
        invoice_item_enhanced.tax_amount,
        taxation_item.tax_amount_home_currency,
        invoice_item_enhanced.transaction_currency,
        invoice_item_enhanced.unit_price,
        invoice_item_enhanced.uom,
        invoice.invoice_number,
        invoice.invoice_date,
        invoice.due_date as invoice_due_date,
        product.name as product_name,
        product.category as product_category,
        product.description as product_description,
        product.effective_start_date,
        product.effective_end_date,
        product_rate_plan.name as product_rate_plan_name,
        product_rate_plan.description as product_rate_plan_description,
        rate_plan_charge.name as rate_plan_charge_name,
        rate_plan_charge.billing_period as charge_billing_period,
        rate_plan_charge.billing_timing as charge_billing_timing,
        rate_plan_charge.charge_model as charge_model,
        rate_plan_charge.charge_type as charge_type,
        rate_plan_charge.effective_start_date as charge_effective_start_date,
        rate_plan_charge.effective_end_date as charge_effective_end_date,
        rate_plan_charge.segment as charge_segment,
        invoice_revenue_items.gross_revenue,
        invoice_revenue_items.discount_revenue,
        invoice_revenue_items.gross_revenue - invoice_revenue_items.discount_revenue as net_revenue
    from invoice_item_enhanced
        left join invoice
            on invoice_item_enhanced.invoice_id = invoice.invoice_id
        left join product
            on invoice_item_enhanced.product_id = product.product_id
        left join product_rate_plan
            on invoice_item_enhanced.product_rate_plan_id = product_rate_plan.product_rate_plan_id 
        left join rate_plan_charge 
            on invoice_item_enhanced.rate_plan_charge_id = rate_plan_charge.rate_plan_charge_id
        left join account_months 
            on invoice_item_enhanced.account_id = account_months.account_id
            and invoice_item_enhanced.charge_month = account_months.account_month
        left join invoice_revenue_items
            on invoice_item_enhanced.invoice_item_id = invoice_revenue_items.invoice_item_id
        left join taxation_item 
            on invoice_item_enhanced.invoice_item_id = taxation_item.invoice_item_id
)       

select * 
from revenue_line_item_history