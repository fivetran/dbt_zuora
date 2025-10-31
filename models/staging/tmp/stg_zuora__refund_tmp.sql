{{ config(enabled=var('zuora__using_refund', true)) }}

{{
    zuora.zuora_union_connections(
        connection_dictionary='zuora_sources',
        single_source_name='zuora',
        single_table_name='refund'
    )
}}