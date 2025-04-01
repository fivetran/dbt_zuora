{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select *
    except(invoice_amount, invoice_amount_home_currency, invoice_amount_paid, invoice_amount_unpaid, tax_amount,
        refund_amount, credit_balance_adjustment_amount, tax_amount_home_currency, invoice_amount_paid_home_currency,
        invoice_amount_unpaid_home_currency, discount_charges, discount_charges_home_currency)
    from {{ target.schema }}_zuora_prod.zuora__billing_history
),

dev as (
    select *
    except(invoice_amount, invoice_amount_home_currency, invoice_amount_paid, invoice_amount_unpaid, tax_amount,
        refund_amount, credit_balance_adjustment_amount, tax_amount_home_currency, invoice_amount_paid_home_currency,
        invoice_amount_unpaid_home_currency, discount_charges, discount_charges_home_currency)
    from {{ target.schema }}_zuora_dev.zuora__billing_history
), 

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final