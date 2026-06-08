{{ config(enabled=var('zuora__using_credit_balance_adjustment', true)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='zuora_sources',
        single_source_name='zuora',
        single_table_name='credit_balance_adjustment'
    )
}}
