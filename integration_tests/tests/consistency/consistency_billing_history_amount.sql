{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (

    select *
    from {{ target.schema }}_zuora_prod.zuora__billing_history
),

dev as (
    select *
    from {{ target.schema }}_zuora_dev.zuora__billing_history
), 

final as (

    select 
        prod.invoice_id as prod_invoice_id,
        dev.invoice_id as dev_invoice_id,
        prod.invoice_amount as prod_invoice_amount,
        dev.invoice_amount as dev_invoice_amount,
        prod.invoice_amount_home_currency as prod_invoice_amount_home_currency,
        dev.invoice_amount_home_currency as dev_invoice_amount_home_currency,
        prod.invoice_amount_paid as prod_invoice_amount_paid,
        dev.invoice_amount_paid as dev_invoice_amount_paid,
        prod.invoice_amount_unpaid as prod_invoice_amount_unpaid,
        dev.invoice_amount_unpaid as dev_invoice_amount_unpaid,
        prod.tax_amount as prod_tax_amount,
        dev.tax_amount as dev_tax_amount,
        prod.refund_amount as prod_refund_amount,
        dev.refund_amount as dev_refund_amount,
        prod.credit_balance_adjustment_amount as prod_credit_balance_adjustment_amount,
        dev.credit_balance_adjustment_amount as dev_credit_balance_adjustment_amount,
        prod.tax_amount_home_currency as prod_tax_amount_home_currency,
        dev.tax_amount_home_currency as dev_tax_amount_home_currency,
        prod.invoice_amount_paid_home_currency as prod_invoice_amount_paid_home_currency,
        dev.invoice_amount_paid_home_currency as dev_invoice_amount_paid_home_currency,
        prod.invoice_amount_unpaid_home_currency as prod_invoice_amount_unpaid_home_currency, 
        dev.invoice_amount_unpaid_home_currency as dev_invoice_amount_unpaid_home_currency,
        prod.discount_charges as prod_discount_charges,
        dev.discount_charges as dev_discount_charges,
        prod.discount_charges_home_currency as prod_discount_charges_home_currency,
        dev.discount_charges_home_currency as dev_discount_charges_home_currency
    from prod
    full outer join dev 
        on prod.invoice_id = dev.invoice_id
)

select *
from final
where prod_invoice_id != dev_invoice_id
    and abs(prod_invoice_amount - dev_invoice_amount) < 0.01
    and abs(prod_invoice_amount_home_currency - dev_invoice_amount_home_currency) < 0.01
    and abs(prod_invoice_amount_paid - dev_invoice_amount_paid) < 0.01
    and abs(prod_invoice_amount_unpaid - dev_invoice_amount_unpaid) < 0.01
    and abs(prod_tax_amount - dev_tax_amount) < 0.01
    and abs(prod_refund_amount - dev_refund_amount) < 0.01
    and abs(prod_credit_balance_adjustment_amount - dev_credit_balance_adjustment_amount) < 0.01
    and abs(prod_tax_amount_home_currency - dev_tax_amount_home_currency) < 0.01
    and abs(prod_invoice_amount_paid_home_currency - dev_invoice_amount_paid_home_currency) < 0.01
    and abs(prod_invoice_amount_unpaid_home_currency - dev_invoice_amount_unpaid_home_currency) < 0.01
    and abs(prod_discount_charges - dev_discount_charges) < 0.01
    and abs(prod_discount_charges_home_currency - dev_discount_charges_home_currency) < 0.01