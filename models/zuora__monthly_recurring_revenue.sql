with account_revenue_line_items as (

    select *
    from {{ ref('int_zuora__account_revenue_line_items') }}
),

mrr_by_account as (

    select 
        account_id,
        charge_id,
        charge_month,
        sum(gross_revenue) as gross_mrr,
        sum(discount_revenue) as discount_mrr,
        sum(net_revenue) as net_mrr
    from account_revenue
    {{ dbt_utils.group_by(3) }}
)

select * 
from mrr_by_account