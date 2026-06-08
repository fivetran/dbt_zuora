{{ config(enabled=var('zuora__using_refund_invoice_payment', true)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='zuora_sources',
        single_source_name='zuora',
        single_table_name='refund_invoice_payment'
    )
}}
