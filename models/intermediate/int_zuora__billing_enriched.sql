with invoice_item_enriched as (

    select
        source_relation,
        invoice_id,
        count(distinct invoice_item_id) as invoice_items,
        count(distinct product_id) as products,
        count(distinct subscription_id) as subscriptions,
        sum(case when cast(processing_type as {{ dbt.type_string() }}) = '1' then charge_amount else 0 end) as discount_charges,
        sum(case when cast(processing_type as {{ dbt.type_string() }}) = '1' then charge_amount_home_currency else 0 end) as discount_charges_home_currency,
        sum(quantity) as units,
        min(charge_date) as first_charge_date,
        max(charge_date) as most_recent_charge_date,
        min(service_start_date) as invoice_service_start_date,
        max(service_end_date) as invoice_service_end_date
    from {{ ref('stg_zuora__invoice_item') }}
    where is_most_recent_record
    {{ dbt_utils.group_by(2) }}
),

invoice_payment as (

    select
        source_relation,
        invoice_id,
        payment_id,
        amount_home_currency as invoice_payment_amount_home_currency
    from {{ ref('stg_zuora__invoice_payment') }}
    where is_most_recent_record
),

payment as (

    select
        source_relation,
        payment_id,
        payment_number,
        effective_date as payment_date,
        status as payment_status,
        type as payment_type,
        payment_method_id
    from {{ ref('stg_zuora__payment') }}
    where is_most_recent_record
),

payment_method as (

    select
        source_relation,
        payment_method_id,
        type as payment_method_type,
        coalesce(ach_account_type, bank_transfer_account_type, credit_card_type, paypal_type, sub_type) as payment_method_subtype,
        active as is_payment_method_active
    from {{ ref('stg_zuora__payment_method') }}
    where is_most_recent_record
),

-- one row per invoice, so payments and credit balance adjustments don't multiply each other when joined
payments_aggregated as (

    select
        invoice_payment.source_relation,
        invoice_payment.invoice_id,
        count(distinct payment.payment_id) as payments,
        -- the amount applied to this invoice, not the full payment, which can span several invoices
        sum(case when payment.payment_id is not null then invoice_payment.invoice_payment_amount_home_currency end) as invoice_amount_paid_home_currency,
        min(payment.payment_date) as first_payment_date,
        max(payment.payment_date) as most_recent_payment_date,
        count(distinct payment_method.payment_method_id) as payment_methods

    from invoice_payment
    left join payment
        on invoice_payment.payment_id = payment.payment_id
        and invoice_payment.source_relation = payment.source_relation
    left join payment_method
        on payment.payment_method_id = payment_method.payment_method_id
        and payment.source_relation = payment_method.source_relation
    {{ dbt_utils.group_by(2) }}
),

{% if var('zuora__using_credit_balance_adjustment', true) %}
credit_balance_adjustment as (

    select
        source_relation,
        invoice_id,
        credit_balance_adjustment_id,
        number as credit_balance_adjustment_number,
        reason_code as credit_balance_adjustment_reason_code,
        amount_home_currency as credit_balance_adjustment_amount_home_currency,
        adjustment_date as credit_balance_adjustment_date
    from {{ ref('stg_zuora__credit_balance_adjustment') }}
    where is_most_recent_record
),

credit_balance_adjustments_aggregated as (

    select
        source_relation,
        invoice_id,
        count(distinct credit_balance_adjustment_id) as credit_balance_adjustments,
        sum(credit_balance_adjustment_amount_home_currency) as credit_balance_adjustment_amount_home_currency,
        min(credit_balance_adjustment_date) as first_credit_balance_adjustment_date,
        max(credit_balance_adjustment_date) as most_recent_credit_balance_adjustment_date

    from credit_balance_adjustment
    {{ dbt_utils.group_by(2) }}
),
{% endif %}

{% if var('zuora__using_taxation_item', true) %}
taxes as (

    select
        source_relation,
        invoice_id,
        sum(tax_amount_home_currency) as tax_amount_home_currency
    from {{ ref('stg_zuora__taxation_item') }}
    where is_most_recent_record
    {{ dbt_utils.group_by(2) }}
),
{% endif %}

billing_enriched as (

    select
        invoice_item_enriched.source_relation,
        invoice_item_enriched.invoice_id,
        invoice_item_enriched.invoice_items,
        invoice_item_enriched.products,
        invoice_item_enriched.subscriptions,
        invoice_item_enriched.discount_charges,
        invoice_item_enriched.discount_charges_home_currency,
        invoice_item_enriched.units,
        invoice_item_enriched.first_charge_date,
        invoice_item_enriched.most_recent_charge_date,
        invoice_item_enriched.invoice_service_start_date,
        invoice_item_enriched.invoice_service_end_date,

        {% if var('zuora__using_taxation_item', true) %}
        taxes.tax_amount_home_currency,
        {% endif %}

        coalesce(payments_aggregated.payments, 0) as payments,
        payments_aggregated.invoice_amount_paid_home_currency,
        payments_aggregated.first_payment_date,
        payments_aggregated.most_recent_payment_date,
        coalesce(payments_aggregated.payment_methods, 0) as payment_methods

        {% if var('zuora__using_credit_balance_adjustment', true) %}
        , coalesce(credit_balance_adjustments_aggregated.credit_balance_adjustments, 0) as credit_balance_adjustments
        , credit_balance_adjustments_aggregated.credit_balance_adjustment_amount_home_currency
        , credit_balance_adjustments_aggregated.first_credit_balance_adjustment_date
        , credit_balance_adjustments_aggregated.most_recent_credit_balance_adjustment_date
        {% endif %}

    from invoice_item_enriched
    left join payments_aggregated
        on invoice_item_enriched.invoice_id = payments_aggregated.invoice_id
        and invoice_item_enriched.source_relation = payments_aggregated.source_relation

    {% if var('zuora__using_credit_balance_adjustment', true) %}
    left join credit_balance_adjustments_aggregated
        on invoice_item_enriched.invoice_id = credit_balance_adjustments_aggregated.invoice_id
        and invoice_item_enriched.source_relation = credit_balance_adjustments_aggregated.source_relation
    {% endif %}

    {% if var('zuora__using_taxation_item', true) %}
    left join taxes
        on invoice_item_enriched.invoice_id = taxes.invoice_id
        and invoice_item_enriched.source_relation = taxes.source_relation
    {% endif %}
)

select * 
from billing_enriched