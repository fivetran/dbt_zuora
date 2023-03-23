with line_items_joined as (

    select *
    from {{ ref('zuora__line_item_history') }}
),

final as (

    select 
        account_id,
        home_currency,
        transaction_currency,
        charge_date as charge_date,
        cast({{ dbt.date_trunc("day", "charge_date") }} as date) as date_day,             
        cast({{ dbt.date_trunc("week", "charge_date") }} as date) as date_week, 
        cast({{ dbt.date_trunc("month", "charge_date") }} as date) as date_month, 
        cast({{ dbt.date_trunc("year", "charge_date") }} as date) as date_year, 
        count(distinct invoice_item_id) as daily_line_items,
        count(distinct invoice_id) as daily_invoices, 
        sum(balance) as daily_invoice_balance,
        sum(charge_amount) as daily_charges,
        sum(charge_amount_home_currency) as daily_charges_home_currency,
        sum(quantity) as daily_invoice_item_units,
        sum(tax_amount) as daily_taxes,
        sum(case when processing_type = '1' then charge_amount else 0 end) as daily_discounts,
        sum(case when processing_type = '1' then charge_amount_home_currency else 0 end) as daily_discounts_home_currency
    from line_items_joined

    {{ dbt_utils.group_by(8) }}
)
