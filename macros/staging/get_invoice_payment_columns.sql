{% macro get_invoice_payment_columns() %}

{% set columns = [ 
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_receivable_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "accounting_period_id", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "amount_currency_rounding", "datatype": dbt.type_float()},
    {"name": "amount_home_currency", "datatype": dbt.type_float()},
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "cash_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "default_payment_method_id", "datatype": dbt.type_string()},
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "exchange_rate_date", "datatype": "date"},
    {"name": "home_currency", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "journal_entry_id", "datatype": dbt.type_string()},
    {"name": "journal_run_id", "datatype": dbt.type_string()},
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "payment_id", "datatype": dbt.type_string()},
    {"name": "payment_method_id", "datatype": dbt.type_string()},
    {"name": "provider_exchange_rate_date", "datatype": "date"},
    {"name": "refund_amount", "datatype": dbt.type_float()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "transaction_currency", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
