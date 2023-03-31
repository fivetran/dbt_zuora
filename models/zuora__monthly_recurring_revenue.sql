with revenue_line_items as (

    select *
    from {{ ref('int_zuora__revenue_line_items') }}
),

account_daily_overview as (

    select 
        account_id,
        date_month
    from {{ ref('zuora__account_daily_overview') }}
    {{ dbt_utils.group_by(2) }}
),

coalesce_date_spine as (

    select 
        coalesce(account_daily_overview.account_id, revenue_line_items.account_id) as account_id, 
        coalesce(account_daily_overview.date_month, revenue_line_items.charge_month) as account_month,
        charge_type,
        gross_revenue,
        discount_revenue,
        net_revenue
    from account_daily_overview
    left join revenue_line_items
        on account_daily_overview.account_id = revenue_line_items.account_id
        and account_daily_overview.date_month = revenue_line_items.charge_month 
),

mrr_by_account as (

    select 
        account_id,
        account_month,
        {{ dbt_utils.generate_surrogate_key(['account_id', 'account_month']) }} as account_monthly_id,
        row_number() over (partition by account_id order by account_month) as account_month_number,
        sum(case when charge_type = 'Recurring' then gross_revenue else 0 end) as gross_current_month_mrr,
        sum(case when charge_type = 'Recurring' then discount_revenue else 0 end) as discount_current_month_mrr,
        sum(case when charge_type = 'Recurring' then net_revenue else 0 end) as net_current_month_mrr,
        sum(case when charge_type != 'Recurring' then gross_revenue else 0 end) as gross_current_month_non_mrr,
        sum(case when charge_type != 'Recurring' then discount_revenue else 0 end) as discount_current_month_non_mrr,
        sum(case when charge_type != 'Recurring' then net_revenue else 0 end) as net_current_month_non_mrr
    from coalesce_date_spine
    {{ dbt_utils.group_by(3) }}
),

current_vs_previous_mrr as (
    
    select 
        *,
        lag(gross_current_month_mrr) over (partition by account_id order by account_month) as gross_previous_month_mrr,
        lag(discount_current_month_mrr) over (partition by account_id order by account_month) as discount_previous_month_mrr,
        lag(net_current_month_mrr) over (partition by account_id order by account_month) as net_previous_month_mrr,
        lag(gross_current_month_non_mrr) over (partition by account_id order by account_month) as gross_previous_month_non_mrr,
        lag(discount_current_month_mrr) over (partition by account_id order by account_month) as discount_previous_month_non_mrr,
        lag(net_current_month_mrr) over (partition by account_id order by account_month) as net_previous_month_non_mrr
    from mrr_by_account
),

mrr_type as (

    select 
        *,   
        case when net_current_month_mrr > net_previous_month_mrr then 'expansion'
            when net_current_month_mrr < net_previous_month_mrr then 'contraction'
            when net_current_month_mrr = net_previous_month_mrr then 'unchanged'
            when net_previous_month_mrr is null then 'new'
            when (net_current_month_mrr = 0.0 or net_current_month_mrr is null)
                and (net_previous_month_mrr != 0.0)
                then 'churned'
            when (net_previous_month_mrr = 0.0 and net_current_month_mrr > 0.0 
                and account_month_number >= 3) 
                then 'reactivation'
            else null
            end as mrr_type
    from current_vs_previous_mrr
)

select * 
from mrr_type