with month_spine as (

    select
        source_relation,
        account_id,
        date_month as account_month
    from {{ ref('zuora__account_daily_overview') }}
    {{ dbt_utils.group_by(3) }}
),

line_items as (

    select *
    from {{ ref('zuora__line_item_history') }}
),

account_current_month as (

    select
      coalesce(month_spine.source_relation, line_items.source_relation) as source_relation,
      coalesce(month_spine.account_id, line_items.account_id) as account_id,
      coalesce(month_spine.account_month, line_items.service_start_month) as account_month,
      count(distinct rate_plan_charge_id) as rate_plan_charges,
      case when count(distinct rate_plan_charge_id) != 0 then true
        else false
        end as is_current_month_active
    from month_spine
    left join line_items
      on month_spine.source_relation = line_items.source_relation
      and month_spine.account_id = line_items.account_id
      and month_spine.account_month = line_items.service_start_month
    {{ dbt_utils.group_by(3) }}
),

account_previous_month as (

    select *,
      lag(rate_plan_charges) over (partition by account_id {{ zuora.partition_by_source_relation() }} order by account_month) as rate_plan_charges_last_month,
      lag(is_current_month_active) over (partition by account_id {{ zuora.partition_by_source_relation() }} order by account_month) as is_previous_month_active
    from account_current_month
),

churn_month as (

    select *,
        case when is_current_month_active = false and is_previous_month_active = true
          then true 
          else false
        end as is_churned_month
    from account_previous_month
)

select * 
from churn_month