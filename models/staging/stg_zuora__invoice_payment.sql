
with base as (

    select * 
    from {{ ref('stg_zuora__invoice_payment_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__invoice_payment_tmp')),
                staging_columns=get_invoice_payment_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as invoice_payment_id,
        account_id,
        account_receivable_accounting_code_id,
        accounting_period_id,
        amount,
        amount_currency_rounding,
        amount_home_currency,
        bill_to_contact_id,
        cash_accounting_code_id,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        default_payment_method_id,
        exchange_rate,
        exchange_rate_date,
        home_currency, 
        invoice_id,
        journal_entry_id,
        journal_run_id,
        parent_account_id,
        payment_id,
        payment_method_id,
        provider_exchange_rate_date,
        refund_amount,
        sold_to_contact_id,
        transaction_currency,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
