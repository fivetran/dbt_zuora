with invoice_item_enriched as (

    select 
        invoice_id,
        count(distinct invoice_item_id) as invoice_items,
        count(distinct product_id) as products,
        count(distinct subscription_id) as subscriptions,
        sum(case when processing_type = '1' then charge_amount else 0 end) as discount_charges,
        sum(case when processing_type = '1' then charge_amount_home_currency else 0 end) as discount_charges_home_currency,
        sum(quantity) as units,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        min(service_start_date) as invoice_service_start_date,
        max(service_end_date) as invoice_service_end_date
    from {{ var('invoice_item') }} 
    {{ dbt_utils.group_by(1) }}
)

select * 
from invoice_item_enriched
