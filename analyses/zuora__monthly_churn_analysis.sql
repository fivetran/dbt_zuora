--to be migrated to analysis
with month_spine as (

    select 
        account_id,
        date_month as account_month
    from {{ ref('zuora__account_daily_overview') }}  
    {{ dbt_utils.group_by(2) }}
),

line_items as (

    select *
    from {{ ref('zuora__line_item_history') }}
),

account_current_month as (

    select coalesce(month_spine.account_id, line_items.account_id) as account_id,
      coalesce(month_spine.account_month, line_items.charge_month) as account_month,
      count(distinct rate_plan_charge_id) as rate_plan_charges,
      case when count(distinct rate_plan_charge_id) = 0 then 'inactive'
        else 'active'
        end as current_month_account_state
    from month_spine
    left join line_items  
      on month_spine.account_id = line_items.account_id
      and month_spine.account_month = line_items.charge_month 
    {{ dbt_utils.group_by(2) }}
),

account_previous_month as (

    select *, 
      lag(rate_plan_charges) over (partition by account_id order by account_month) as rate_plan_charges_last_month,
      lag(current_month_account_state) over (partition by account_id order by account_month) as previous_month_account_state
    from account_current_month
)

select * 
from account_previous_month