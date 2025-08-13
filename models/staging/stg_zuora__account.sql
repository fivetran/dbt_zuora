
with base as (

    select * 
    from {{ ref('stg_zuora__account_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__account_tmp')),
                staging_columns=get_account_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as account_id,
        account_number,
        auto_pay,
        balance,
        batch, 
        bill_cycle_day,
        bill_to_contact_id,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        credit_balance,
        crm_id,
        currency,
        default_payment_method_id,
        cast(last_invoice_date as {{ dbt.type_timestamp() }}) as last_invoice_date,
        mrr,
        name,
        notes,
        parent_account_id,
        payment_term,
        sold_to_contact_id,
        status, 
        cast(tax_exempt_effective_date as {{ dbt.type_timestamp() }}) as tax_exempt_effective_date, 
        cast(tax_exempt_expiration_date as {{ dbt.type_timestamp() }}) as tax_exempt_expiration_date, 
        tax_exempt_status, 
        total_debit_memo_balance,
        total_invoice_balance,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        vatid,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record

        {{ fivetran_utils.fill_pass_through_columns('zuora_account_pass_through_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
