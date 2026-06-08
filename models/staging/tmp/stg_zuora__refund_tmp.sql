{{ config(enabled=var('zuora__using_refund', true)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='zuora_sources',
        single_source_name='zuora',
        single_table_name='refund'
    )
}}