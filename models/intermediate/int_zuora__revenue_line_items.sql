
with line_item_history as (

    select * 
    from {{ ref('zuora__line_item_history') }}
),

account_overview as (

    select 
        account_id,
        cast({{ dbt.date_trunc("day", "account_created_at") }} as date) as account_creation_day, 
        cast({{ dbt.date_trunc("day", "first_charge_processed_at") }} as date) as first_charge_day,
        account_status
    from {{ ref('zuora__account_overview') }}
),

revenue_line_items as (

    select 
        line_item_history.account_id,
        line_item_history.invoice_item_id as charge_id,
        line_item_history.rate_plan_charge_id as rate_plan_charge_id,
        account_overview.account_creation_day, 
        account_overview.first_charge_day,
        account_overview.account_status,
        line_item_history.charge_name,
        cast({{ dbt.date_trunc("day", "line_item_history.charge_date") }} as date) as charge_day,
        cast({{ dbt.date_trunc("week", "line_item_history.charge_date") }} as date) as charge_week,
        cast({{ dbt.date_trunc("month", "line_item_history.charge_date") }} as date) as charge_month,
        line_item_history.charge_segment,
        line_item_history.charge_billing_period,
        line_item_history.charge_effective_start_date,
        line_item_history.charge_effective_end_date,
        line_item_history.charge_model,
        line_item_history.charge_type,
        {% if var('using_multicurrency', true) %}
        line_item_history.charge_amount_home_currency as gross_revenue,
        line_item_history.discount_amount_home_currency as discount_revenue,
        line_item_history.charge_amount_home_currency - line_item_history.discount_amount_home_currency as net_revenue
        {% else %} 
        line_item_history.charge_amount as gross_revenue,
        line_item_history.discount_amount as discount_revenue,
        line_item_history.charge_amount - line_item_history.discount_amount as net_revenue
        {% endif %}
    from line_item_history
    left join account_overview on
        line_item_history.account_id = account_overview.account_id
)
 
 select * 
 from revenue_line_items