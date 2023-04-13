with line_item_history as (

    select *
    from {{ ref('zuora__line_item_history') }}  
),


subscription as (

    select *
    from {{ var('subscription') }}  
    where is_most_recent_record
),

subscription_overview as (

    select 
        line_item_history.invoice_item_id,
        line_item_history.account_id,
        rate_plan_charge_name,
        charge_billing_period,
        charge_billing_timing,
        charge_model,
        charge_type,
        charge_effective_start_date,
        charge_effective_end_date,
        charge_segment,
        subscription.subscription_id,
        subscription.auto_renew,
        subscription.cancel_reason,
        subscription.cancelled_date,
        subscription.current_term,
        subscription.initial_term,
        subscription.is_latest_version,
        subscription.previous_subscription_id,
        subscription.service_activation_date,
        subscription.status,
        subscription_end_date,
        subscription_start_date,
    from line_item_history
    left join subscription
        on 
)


