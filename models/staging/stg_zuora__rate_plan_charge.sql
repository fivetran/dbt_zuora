
with base as (

    select * 
    from {{ ref('stg_zuora__rate_plan_charge_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_zuora__rate_plan_charge_tmp')),
                staging_columns=get_rate_plan_charge_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as rate_plan_charge_id,
        account_id,
        account_receivable_accounting_code_id,
        accounting_code,
        amended_by_order_on,
        amendment_id,
        apply_discount_to,
        bill_cycle_day,
        bill_cycle_type,
        bill_to_contact_id,
        bill_to_contact_snapshot_id,
        billing_period,
        billing_timing,
        booking_exchange_rate,
        booking_exchange_rate_date,
        charge_model,
        charge_number,
        charge_type,
        charged_through_date,
        created_by_id,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        credit_option,
        default_payment_method_id,
        deferred_revenue_accounting_code_id,
        description,
        discount_level,
        dmrc,
        dmrchome_currency,
        dtcv,
        dtcvhome_currency,
        effective_end_date,
        effective_start_date,
        end_date_condition,
        exchange_rate,
        exchange_rate_date, 
        home_currency,  
        is_prepaid,
        is_processed,  
        mrr,
        mrrhome_currency,
        name,
        number_of_periods,
        original_id,
        original_order_date,
        price_change_option,
        price_increase_percentage,
        processed_through_date,
        product_id,
        product_rate_plan_charge_id,
        product_rate_plan_id,
        quantity,
        rate_plan_id, 
        recognized_revenue_accounting_code_id,
        segment,
        sold_to_contact_id,
        specific_billing_period,
        specific_end_date,
        specific_list_price_base,
        subscription_id, 
        tcv, 
        tcvhome_currency,
        transaction_currency,
        trigger_date,
        trigger_event,
        uom,
        up_to_periods,
        up_to_periods_type,
        updated_by_id,
        cast(updated_date as {{ dbt.type_timestamp() }}) as updated_date,
        version,
        weekly_bill_cycle_day,
        row_number() over (partition by id order by updated_date desc) = 1 as is_most_recent_record

        {{ fivetran_utils.fill_pass_through_columns('zuora_rate_plan_charge_pass_through_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
