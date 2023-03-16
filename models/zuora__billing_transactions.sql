with invoice as (

    select * 
    from {{ var('invoice') }} 
),

invoice_item as (

    select * 
    from {{ var('invoice_item') }} 
),

invoice_payment as  (

    select * 
    from {{ var('invoice_payment') }} 
),

account as (

    select * 
    from {{ var('account') }} 
),  a

select 
    invoice.invoice_id,
    invo

from invoice