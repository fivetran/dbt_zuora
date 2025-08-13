
with base as (

    select * 
    from {{ ref('stg_zuora__invoice_item_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__invoice_item_tmp')),
                staging_columns=get_invoice_item_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as invoice_item_id,
        account_id,
        account_receivable_accounting_code_id,
        accounting_code, 
        amendment_id,
        applied_to_invoice_item_id,
        balance,
        bill_to_contact_id, 
        charge_amount, 
        charge_amount_home_currency,
        cast(charge_date as {{ dbt.type_timestamp() }}) as charge_date,
        charge_name,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        deferred_revenue_accounting_code_id,
        exchange_rate,
        exchange_rate_date,
        home_currency,
        invoice_id,
        journal_entry_id,
        parent_account_id,
        processing_type,
        product_id,
        product_rate_plan_charge_id,
        product_rate_plan_id,
        quantity,
        rate_plan_charge_id,
        rate_plan_id,
        recognized_revenue_accounting_code_id,
        rev_rec_start_date,
        service_end_date,
        service_start_date,
        sku,
        sold_to_contact_id,
        source_item_type,
        subscription_id,
        tax_amount,
        tax_mode,
        transaction_currency,
        unit_price,
        uom,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
