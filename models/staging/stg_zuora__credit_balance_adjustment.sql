{{ config(enabled=var('zuora__using_credit_balance_adjustment', true)) }}

with base as (

    select * 
    from {{ ref('stg_zuora__credit_balance_adjustment_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__credit_balance_adjustment_tmp')),
                staging_columns=get_credit_balance_adjustment_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as credit_balance_adjustment_id,
        account_id,
        account_receivable_accounting_code_id,
        accounting_code,
        adjustment_date,
        amount, 
        amount_home_currency,
        bill_to_contact_id,
        cast(cancelled_on as {{ dbt.type_timestamp() }}) as cancelled_on,
        comment,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        default_payment_method_id,
        exchange_rate,
        exchange_rate_date,
        home_currency,
        invoice_id,
        journal_entry_id, 
        number,
        parent_account_id, 
        reason_code,
        reference_id,
        sold_to_contact_id,
        source_transaction_id,
        source_transaction_number,
        source_transaction_type,
        status,
        transaction_currency,
        transferred_to_accounting,
        type,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
