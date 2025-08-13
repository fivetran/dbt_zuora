{{ config(enabled=var('zuora__using_credit_balance_adjustment', true)) }}

select * 
from {{ var('credit_balance_adjustment') }}
