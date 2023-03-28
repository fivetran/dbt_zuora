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
        invoice_item.sku,
        invoice_item.tax_amount,
        invoice_item.transaction_currency,
        invoice_item.unit_price,
        invoice_item.uom,
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
        product_rate_plan_charge.name as product_rate_plan_charge_name,
        product_rate_plan_charge.charge_model as product_rate_plan_charge_model,
        product_rate_plan_charge.charge_type as product_rate_plan_charge_type,
        product_rate_plan_charge.billing_period as product_rate_plan_charge_billing_period
    from invoice_item
        left join invoice on
            invoice_item.invoice_id = invoice.invoice_id
        left join product on
            invoice_item.product_id = product.product_id
        left join product_rate_plan on
            invoice_item.product_rate_plan_id = product_rate_plan.product_rate_plan_id
        left join product_rate_plan_charge on
            invoice_item.product_rate_plan_charge_id = product_rate_plan_charge.product_rate_plan_charge_id
)       

select * 
from line_item_history