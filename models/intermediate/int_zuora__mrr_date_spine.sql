-- depends_on: {{ ref('stg_zuora__invoice_item_tmp') }}
with spine as (

    {% if execute and flags.WHICH in ('run', 'build') and (not var('zuora_mrr_first_date', None) or not var('zuora_mrr_last_date', None)) %}
        {%- set first_date_query %}
            select
                cast(min(service_start_date) as date) as min_date
        from {{ ref('stg_zuora__invoice_item_tmp') }}
        {% endset %}

        {%- set last_date_query %}
            select
                cast(max(service_start_date) as date) as max_date
            from {{ ref('stg_zuora__invoice_item_tmp') }}
        {% endset -%}

    {# If only compiling, creates range going back 1 year #}
    {% else %}
        {%- set first_date_query %}
            select cast({{ dbt.dateadd("year", -1, dbt.current_timestamp() ) }} as date) as min_date
        {% endset -%}

        {%- set last_date_query %}
            select cast({{ dbt.current_timestamp() }} as date) as max_date
        {% endset -%}
    {% endif %}

    {# Prioritizes variables over calculated dates #}
    {%- set first_date = var('zuora_mrr_first_date', dbt_utils.get_single_value(first_date_query))|string %}
    {%- set last_date = var('zuora_mrr_last_date', dbt_utils.get_single_value(last_date_query))|string %}

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
        end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
        )
    }}
),

account_service_history as (

    select
        source_relation,
        account_id,
        min(service_start_month) as first_service_month
    from {{ ref('zuora__line_item_history') }}
    {{ dbt_utils.group_by(2) }}
),

date_spine as (

    select
        cast({{ dbt.date_trunc("day", "date_day") }} as date) as date_day, 
        cast({{ dbt.date_trunc("week", "date_day") }} as date) as date_week, 
        cast({{ dbt.date_trunc("month", "date_day") }} as date) as date_month,
        cast({{ dbt.date_trunc("year", "date_day") }} as date) as date_year,  
        row_number() over (order by cast({{ dbt.date_trunc("day", "date_day") }} as date)) as date_index
    from spine
),

final as (

    select distinct
        account_service_history.source_relation,
        account_service_history.account_id,
        date_spine.date_day,
        date_spine.date_week,
        date_spine.date_month,
        date_spine.date_year,
        date_spine.date_index
    from account_service_history
    cross join date_spine
    where cast({{ dbt.date_trunc('day', 'account_service_history.first_service_month') }} as date) <= date_spine.date_day
)

select * 
from final