with invoice_item as (

    select * 
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

line_item_history as (

    select 
        invoice_item.invoice_item_id,
        invoice_item.account_id,
        invoice_item.amendment_id,
        invoice_item.balance,
        invoice_item.charge_amount,
        invoice_item.charge_amount_home_currency,
        invoice_item.charge_date,
        invoice_item.charge_name,
        invoice_item.home_currency,
        invoice_item.invoice_id,
        invoice_item.product_id,
        invoice_item.product_rate_plan_id,
        invoice_item.product_rate_plan_charge_id,
        invoice_item.rate_plan_charge_id,
        invoice_item.sku,
        invoice_item.tax_amount,
        invoice_item.transaction_currency,
        invoice_item.unit_price,
        invoice_item.uom,
        invoice.invoice_number,
        invoice.invoice_date,
        case when invoice_item.processing_type = '1' 
            then invoice_item.charge_amount else 0 end as discount_amount,
        case when invoice_item.processing_type = '1' 
            then invoice_item.charge_amount_home_currency else 0 end as discount_amount_home_currency,
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
        rate_plan_charge.segment as charge_segment

    from invoice_item
        left join invoice on
            invoice_item.invoice_id = invoice.invoice_id
        left join product on
            invoice_item.product_id = product.product_id
        left join product_rate_plan on
            invoice_item.product_rate_plan_id = product_rate_plan.product_rate_plan_id 
        left join rate_plan_charge on 
            invoice_item.rate_plan_charge_id = rate_plan_charge.rate_plan_charge_id
)       

select * 
from line_item_history