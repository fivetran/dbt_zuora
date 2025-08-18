
with base as (

    select * 
    from {{ ref('stg_zuora__product_rate_plan_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__product_rate_plan_tmp')),
                staging_columns=get_product_rate_plan_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as product_rate_plan_id,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        description,
        effective_end_date,
        effective_start_date, 
        name,
        product_id, 
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
