{% macro get_credit_balance_adjustment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_receivable_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "accounting_code", "datatype": dbt.type_string()},
    {"name": "adjustment_date", "datatype": "date"},
    {"name": "amount", "datatype": dbt.type_float()}, 
    {"name": "amount_home_currency", "datatype": dbt.type_float()},
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "cancelled_on", "datatype": dbt.type_timestamp()},
    {"name": "comment", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "default_payment_method_id", "datatype": dbt.type_string()},
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "exchange_rate_date", "datatype": "date"},
    {"name": "home_currency", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "journal_entry_id", "datatype": dbt.type_string()},
    {"name": "number", "datatype": dbt.type_string()},
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "reason_code", "datatype": dbt.type_string()},
    {"name": "reference_id", "datatype": dbt.type_string()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "source_transaction_id", "datatype": dbt.type_string()},
    {"name": "source_transaction_number", "datatype": dbt.type_string()},
    {"name": "source_transaction_type", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "transaction_currency", "datatype": dbt.type_string()},
    {"name": "transferred_to_accounting", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
