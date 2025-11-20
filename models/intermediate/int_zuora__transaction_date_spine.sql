-- depends_on: {{ ref('stg_zuora__invoice_tmp') }}
with spine as (

    {% if execute and flags.WHICH in ('run', 'build') and (not var('zuora_daily_overview_first_date', None) or not var('zuora_daily_overview_last_date', None)) %}
        {%- set first_date_query %}
            select 
                cast(min(invoice_date) as date) as min_date
        from {{ ref('stg_zuora__invoice_tmp') }}
        {% endset %}

        {%- set last_date_query %}
            select 
                cast(max(invoice_date) as date) as max_date
            from {{ ref('stg_zuora__invoice_tmp') }}
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
    {%- set first_date = var('zuora_daily_overview_first_date', dbt_utils.get_single_value(first_date_query))|string %}
    {%- set last_date = var('zuora_daily_overview_first_date', dbt_utils.get_single_value(last_date_query))|string %}

    {{ dbt_utils.date_spine(
        datepart = "day",
        start_date = "cast('" ~ first_date ~ "' as date)",
        end_date = "cast('" ~ last_date ~ "' as date)"
    ) }}
),

account_first_invoice as (

    select
        source_relation,
        account_id,
        min(invoice_date) as first_invoice_date
    from {{ ref('zuora__billing_history') }}
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
        account_first_invoice.source_relation,
        account_first_invoice.account_id,
        date_spine.date_day,
        date_spine.date_week,
        date_spine.date_month,
        date_spine.date_year,
        date_spine.date_index
    from account_first_invoice
    cross join date_spine
    where cast({{ dbt.date_trunc('day', 'account_first_invoice.first_invoice_date') }} as date) <= date_spine.date_day
)

select * 
from final