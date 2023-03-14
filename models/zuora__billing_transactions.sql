with credit_balance_adjustment_transactions as (

    select * 
    from {{ ref('zuora__credit_balance_adjustment_transactions') }} 
),

invoice_item_transactions as (

    select * 
    from {{ ref('zuora__invoice_item_transactions') }} 
),

payment_transactions as (

    select * 
    from {{ ref('zuora__payment_transactions') }} 
),