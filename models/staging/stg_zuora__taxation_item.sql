{{ config(enabled=var('zuora__using_taxation_item', true)) }}

with base as (

    select * 
    from {{ ref('stg_zuora__taxation_item_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__taxation_item_tmp')),
                staging_columns=get_taxation_item_columns()
            )
        }}
    from base
),

final as (
    
    select  
        id as taxation_item_id,
        account_id,
        account_receivable_accounting_code_id,
        accounting_code, 
        amendment_id,
        balance,
        bill_to_contact_id,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        credit_amount,
        exchange_rate,
        cast(exchange_rate_date as {{ dbt.type_timestamp() }}) as exchange_rate_date,
        exempt_amount, 
        exempt_amount_home_currency, 
        home_currency,
        invoice_id,
        invoice_item_id,
        journal_entry_id,   
        name,
        payment_amount,
        product_id,
        product_rate_plan_charge_id,
        product_rate_plan_id, 
        rate_plan_charge_id,
        rate_plan_id,
        sales_tax_payable_accounting_code_id, 
        sold_to_contact_id,
        subscription_id,
        tax_amount, 
        tax_amount_home_currency,
        cast(tax_date as {{ dbt.type_timestamp() }}) as tax_date,
        tax_description,
        tax_mode,
        tax_rate,
        tax_rate_type, 
        transaction_currency,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
