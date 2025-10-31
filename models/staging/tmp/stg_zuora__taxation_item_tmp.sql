{{ config(enabled=var('zuora__using_taxation_item', true)) }}

{{
    zuora.zuora_union_connections(
        connection_dictionary='zuora_sources',
        single_source_name='zuora',
        single_table_name='taxation_item'
    )
}}