{{ config(enabled=var('zuora__using_taxation_item', true)) }}

select * 
from {{ var('taxation_item') }}