
with base as (

    select * 
    from {{ ref('stg_zuora__payment_method_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__payment_method_tmp')),
                staging_columns=get_payment_method_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as payment_method_id,
        account_id,
        ach_account_type,
        active,
        bank_transfer_account_type,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        credit_card_type,
        cast(last_failed_sale_transaction_date as {{ dbt.type_timestamp() }}) as last_failed_sale_transaction_date,
        cast(last_transaction_date_time as {{ dbt.type_timestamp() }}) as last_transaction_date_time,
        last_transaction_status,
        max_consecutive_payment_failures,
        name,
        num_consecutive_failures,
        payment_method_status,
        paypal_type,
        sub_type,
        total_number_of_error_payments,
        total_number_of_processed_payments,
        type,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
