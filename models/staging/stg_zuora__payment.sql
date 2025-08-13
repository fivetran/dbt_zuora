
with base as (

    select * 
    from {{ ref('stg_zuora__payment_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__payment_tmp')),
                staging_columns=get_payment_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as payment_id,
        account_id,
        accounting_code,
        amount,
        amount_home_currency,
        applied_amount,
        applied_credit_balance_amount,
        bill_to_contact_id,
        cast(cancelled_on as {{ dbt.type_timestamp() }}) as cancelled_on,
        comment,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        currency,
        effective_date,
        exchange_rate,
        exchange_rate_date,
        home_currency,
        parent_account_id,
        payment_method_id,
        payment_number,
        refund_amount,
        cast(settled_on as {{ dbt.type_timestamp() }}) as settled_on, 
        sold_to_contact_id,
        status,
        cast(submitted_on as {{ dbt.type_timestamp() }}) as submitted_on,
        transaction_currency,
        transferred_to_accounting,
        type,
        unapplied_amount,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
