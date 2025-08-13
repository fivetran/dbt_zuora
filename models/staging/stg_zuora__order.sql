
with base as (

    select * 
    from {{ ref('stg_zuora__order_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__order_tmp')),
                staging_columns=get_order_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as order_id,
        account_id,
        bill_to_contact_id,
        category,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        default_payment_method_id,
        description,
        error_code,
        error_message,
        order_date,
        order_number,
        response,
        scheduled_date, 
        sold_to_contact_id,
        state,
        status,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
