{% macro get_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "accounting_code", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "cancelled_on", "datatype": dbt.type_timestamp()},
    {"name": "comment", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()}, 
    {"name": "method_type", "datatype": dbt.type_string()},
    {"name": "payment_method_id", "datatype": dbt.type_string()}, 
    {"name": "refund_date", "datatype": "date"},
    {"name": "refund_number", "datatype": dbt.type_string()},
    {"name": "refund_transaction_time", "datatype": dbt.type_timestamp()}, 
    {"name": "settled_on", "datatype": dbt.type_timestamp()}, 
    {"name": "source_type", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "submitted_on", "datatype": dbt.type_timestamp()},
    {"name": "transferred_to_accounting", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
