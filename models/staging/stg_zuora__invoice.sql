
with base as (

    select * 
    from {{ ref('stg_zuora__invoice_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__invoice_tmp')),
                staging_columns=get_invoice_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as invoice_id,
        account_id,
        adjustment_amount,
        amount, 
        amount_home_currency,
        amount_without_tax, 
        amount_without_tax_home_currency,
        auto_pay,
        balance,
        bill_to_contact_id,
        comments,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        credit_balance_adjustment_amount,
        credit_memo_amount,
        default_payment_method_id,
        due_date,
        exchange_rate,
        exchange_rate_date,
        home_currency,
        includes_one_time,
        includes_recurring,
        includes_usage,
        invoice_date,
        invoice_number,
        cast(last_email_sent_date as {{ dbt.type_timestamp() }}) as last_email_sent_date,
        parent_account_id,
        payment_amount,
        payment_term,
        posted_by,
        cast(posted_date as {{ dbt.type_timestamp() }}) as posted_date, 
        refund_amount, 
        sold_to_contact_id,
        source,
        source_id,
        source_type,
        status,
        target_date,
        tax_amount,
        tax_status, 
        transaction_currency,
        transferred_to_accounting,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
