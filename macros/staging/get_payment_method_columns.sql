{% macro get_payment_method_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "ach_account_type", "datatype": dbt.type_string()},
    {"name": "active", "datatype": "boolean"},
    {"name": "bank_transfer_account_type", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "credit_card_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_failed_sale_transaction_date", "datatype": dbt.type_timestamp()},
    {"name": "last_transaction_date_time", "datatype": dbt.type_timestamp()},
    {"name": "last_transaction_status", "datatype": dbt.type_string()},
    {"name": "max_consecutive_payment_failures", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "num_consecutive_failures", "datatype": dbt.type_int()},
    {"name": "payment_method_status", "datatype": dbt.type_string()},
    {"name": "paypal_type", "datatype": dbt.type_string()},
    {"name": "sub_type", "datatype": dbt.type_string()},
    {"name": "total_number_of_error_payments", "datatype": dbt.type_int()},
    {"name": "total_number_of_processed_payments", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()},
] %}

{{ return(columns) }}

{% endmacro %}
