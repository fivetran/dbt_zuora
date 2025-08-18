{{ config(enabled=var('zuora__using_refund_invoice_payment', true)) }}

select * 
from {{ var('refund_invoice_payment') }}
