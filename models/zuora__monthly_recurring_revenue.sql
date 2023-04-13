with line_items as (

    select *
    from {{ ref('zuora__line_item_history') }}
),

month_spine as (

    select 
        account_id,
        date_month as account_month
    from {{ ref('zuora__account_daily_overview') }}
    {{ dbt_utils.group_by(2) }}
),

mrr_by_account as (

    select 
        coalesce(month_spine.account_id, line_items.account_id) as account_id,
        coalesce(month_spine.account_month, line_items.charge_month) as account_month,
        {% set sum_cols = ['gross', 'discount', 'net'] %}
        {% for col in sum_cols %} 
            sum(case when charge_type = 'Recurring' then {{col}}_revenue else 0 end) as {{col}}_current_month_mrr,
            sum(case when charge_type != 'Recurring' then {{col}}_revenue else 0 end) as {{col}}_current_month_non_mrr
            {{ ',' if not loop.last }}
        {% endfor %}
    from month_spine
    left join line_items
        on month_spine.account_month = line_items.charge_month
        and month_spine.account_id = line_items.account_id
    {{ dbt_utils.group_by(2) }}
),

current_vs_previous_mrr as (
    
    select 
        *,
        {% set sum_cols = ['gross', 'discount', 'net'] %}
        {% for col in sum_cols %} 
            lag({{col}}_current_month_mrr) over (partition by account_id order by account_month) as {{col}}_previous_month_mrr,
            lag({{col}}_current_month_non_mrr) over (partition by account_id order by account_month) as {{col}}_previous_month_non_mrr,
        {% endfor %}
        row_number() over (partition by account_id order by account_month) as account_month_number
    from mrr_by_account
    {{ dbt_utils.group_by(8) }}
),

mrr_type as (

    select 
        {{ dbt_utils.generate_surrogate_key(['account_id', 'account_month']) }} as account_monthly_id,
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