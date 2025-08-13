
with base as (

    select * 
    from {{ ref('stg_zuora__product_rate_plan_charge_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__product_rate_plan_charge_tmp')),
                staging_columns=get_product_rate_plan_charge_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as product_rate_plan_charge_id,
        account_receivable_accounting_code_id,
        accounting_code,
        apply_discount_to,
        bill_cycle_day,
        bill_cycle_type,
        billing_period,  
        charge_model,
        charge_type,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        default_quantity,
        deferred_revenue_accounting_code_id,
        description,
        discount_class_id,
        discount_level,
        end_date_condition,
        exclude_item_billing_from_revenue_accounting,
        exclude_item_booking_from_revenue_accounting,
        included_units,
        is_stacked_discount, 
        list_price_base,
        max_quantity,
        min_quantity,
        name,
        product_id,
        product_rate_plan_id, 
        specific_billing_period,
        tax_mode,
        taxable,
        trigger_event,
        uom,
        up_to_periods,
        up_to_periods_type,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        use_discount_specific_accounting_code,
        weekly_bill_cycle_day,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
