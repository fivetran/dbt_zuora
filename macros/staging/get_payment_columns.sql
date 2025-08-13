{% macro get_payment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "accounting_code", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()}, 
    {"name": "amount_home_currency", "datatype": dbt.type_float()},
    {"name": "applied_amount", "datatype": dbt.type_float()},
    {"name": "applied_credit_balance_amount", "datatype": dbt.type_float()}, 
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "cancelled_on", "datatype": dbt.type_timestamp()},
    {"name": "comment", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "currency", "datatype": dbt.type_string()}, 
    {"name": "effective_date", "datatype": "date"},
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "exchange_rate_date", "datatype": "date"}, 
    {"name": "home_currency", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()}, 
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "payment_method_id", "datatype": dbt.type_string()},
    {"name": "payment_number", "datatype": dbt.type_string()},
    {"name": "refund_amount", "datatype": dbt.type_float()}, 
    {"name": "settled_on", "datatype": dbt.type_timestamp()}, 
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()}, 
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "submitted_on", "datatype": dbt.type_timestamp()},
    {"name": "transaction_currency", "datatype": dbt.type_string()},
    {"name": "transferred_to_accounting", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "unapplied_amount", "datatype": dbt.type_float()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
