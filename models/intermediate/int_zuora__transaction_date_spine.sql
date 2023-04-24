
with spine as (

    {% if execute %}
    {% if not var('zuora_first_date', None) or not var('zuora_last_date', None) %}
        {% set date_query %}
        select 
            min( invoice_date ) as min_date,
            max( invoice_date ) as max_date
        from {{ source('zuora', 'invoice') }}
        {% endset %}

        {% set calc_first_date = run_query(date_query).columns[0][0]|string %}
        {% set calc_last_date = run_query(date_query).columns[1][0]|string %}
    {% endif %}

    {# If only compiling, creates range going back 1 year #}
    {% else %} 
        {% set calc_first_date = dbt.dateadd("year", "-1", "current_date") %}
        {% set calc_last_date = dbt.current_timestamp_backcompat() %}
    {% endif %}

    {# Prioritizes variables over calculated dates #}
    {% set first_date = var('zuora_first_date', calc_first_date)|string %}
    {% set last_date = var('zuora_last_date', calc_last_date)|string %}

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
        end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
        )
    }}
),

account_overview as (

    select 
        account_id,
        account_created_at
    from {{ ref('zuora__account_overview') }}
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

    select 
        distinct account_overview.account_id,
        date_spine.date_day,
        date_spine.date_week,
        date_spine.date_month,
        date_spine.date_year,
        date_spine.date_index
    from account_overview
    cross join date_spine
    where cast({{ dbt.date_trunc('day', 'account_overview.account_created_at') }} as date) <= date_spine.date_day
)

select * 
from final