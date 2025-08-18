{{ config(enabled=var('zuora__using_refund', true)) }}

select * 
from {{ var('refund') }}