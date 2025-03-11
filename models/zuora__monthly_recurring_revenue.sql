{{ config(
    materialized='table',
    alias=var('schema_map')[var('schema')] ~ '__monthly_recurring_revenue'
) }}

{% set source_name = var('staging_map')[var('schema', 'zuora_1')] %}
{% set int_name = var('int_map')[var('schema', 'zuora_1')] %}

{% if var('schema', 'zuora_1') == 'zuora_1' %}
    {% set line_item_table = 'zuora_dbt.zuora_zuora__line_item_history' %}
{% elif var('schema', 'zuora_1') == 'zuora_2' %}
    {% set line_item_table = 'zuora_dbt.zuora_dsa_zuora__line_item_history' %}
{% else %}
    {% set line_item_table = 'zuora_dbt.zuora_zuora__line_item_history' %}
{% endif %}

with line_items as (
    select *
    from {{ line_item_table }}
),

month_spine as (
    select
        account_id,
        date_month as account_month
    from {{ source(int_name, 'int_zuora__mrr_date_spine') }}
    {{ dbt_utils.group_by(2) }}
),

mrr_by_account as (
    select
        coalesce(month_spine.account_id, line_items.account_id) as account_id,
        coalesce(month_spine.account_month, line_items.service_start_month) as account_month,

        {% if true %}  -- Changed from var('zuora__using_multicurrency', false)
        sum(case when charge_mrr is null then 0 else charge_mrr end) as mrr_expected_current_month,
        {% else %}
        sum(case when charge_mrr_home_currency is null then 0 else charge_mrr_home_currency end) as mrr_expected_current_month,
        {% endif %}

        {% set sum_cols = ['gross', 'discount', 'net'] %}
        {% for col in sum_cols %}
            sum(case when lower(charge_type) = 'recurring' and {{col}}_revenue is not null then {{col}}_revenue else 0 end) as {{col}}_current_month_mrr,
            sum(case when lower(charge_type) != 'recurring' and {{col}}_revenue is not null then {{col}}_revenue else 0 end) as {{col}}_current_month_non_mrr
            {{ ',' if not loop.last }}
        {% endfor %}

    from month_spine
    left join line_items
        on month_spine.account_month = line_items.service_start_month
        and month_spine.account_id = line_items.account_id
    {{ dbt_utils.group_by(2) }}

),

current_vs_previous_mrr as (
    select
        account_id,
        account_month,
        gross_current_month_mrr,
        discount_current_month_mrr,
        net_current_month_mrr,
        gross_current_month_non_mrr,
        discount_current_month_non_mrr,
        net_current_month_non_mrr,
        mrr_expected_current_month,
        lag(mrr_expected_current_month) over (partition by account_id order by account_month) as mrr_expected_previous_month,

        {% set sum_cols = ['gross', 'discount', 'net'] %}
        {% for col in sum_cols %}
            lag({{ col }}_current_month_mrr) over (partition by account_id order by account_month) as {{ col }}_previous_month_mrr,
            lag({{ col }}_current_month_non_mrr) over (partition by account_id order by account_month) as {{ col }}_previous_month_non_mrr,
        {% endfor %}

        row_number() over (partition by account_id order by account_month) as account_month_number,
        (gross_current_month_mrr - gross_previous_month_mrr) as delta_gross_mrr_mom,
        (net_current_month_mrr - net_previous_month_mrr) as delta_net_mrr_mom
    from mrr_by_account
    {{ dbt_utils.group_by(9) }}
),

mrr_type as (
    select
        {{ dbt_utils.generate_surrogate_key(['account_id', 'account_month']) }} as account_monthly_id,
        *,
        case
            when (gross_current_month_mrr = 0.0 or gross_current_month_mrr is null)
                and (gross_previous_month_mrr > 0.0) then 'churned'
            when gross_current_month_mrr > gross_previous_month_mrr then 'expansion'
            when gross_current_month_mrr < gross_previous_month_mrr then 'contraction'
            when gross_current_month_mrr = gross_previous_month_mrr then 'unchanged'
            when gross_previous_month_mrr is null then 'new'
            when (gross_previous_month_mrr = 0.0 and gross_current_month_mrr > 0.0
                and account_month_number >= 3) then 'reactivation'
            else null
        end as gross_mrr_type,

        case
            when (net_current_month_mrr = 0.0 or net_current_month_mrr is null)
                and (net_previous_month_mrr > 0.0) then 'churned'
            when net_current_month_mrr > net_previous_month_mrr then 'expansion'
            when net_current_month_mrr < net_previous_month_mrr then 'contraction'
            when net_current_month_mrr = net_previous_month_mrr then 'unchanged'
            when net_previous_month_mrr is null then 'new'
            when (net_previous_month_mrr = 0.0 and net_current_month_mrr > 0.0
                and account_month_number >= 3) then 'reactivation'
            else null
        end as net_mrr_type
    from current_vs_previous_mrr
)

select * 
from mrr_type
